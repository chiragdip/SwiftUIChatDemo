//
//  UserListViewModel.swift
//  SwiftUIFirebase
//
//  Created by MAC215 on 24/02/21.
//

import SwiftUI
import Foundation
import Firebase
import FirebaseFirestoreSwift
import Combine

enum LoginMode {
    case login
    case logOut
}

extension String {
    func hasSubString(_ string: String) -> Bool {
        return range(of: string, options: .caseInsensitive) != nil
    }
}

final class UserListViewModel: ObservableObject {
    
    private var subscription: Set<AnyCancellable> = []
    private var allUsers            = [UserModel]()
    @Published var filteredUsers    = [UserModel]()
    
    private let db = Firestore.firestore()
    private var lastDocumentSnapshot: DocumentSnapshot!
    @Published var showAlert            : Bool       = false
    @Published var searchText           : String     = ""
    @Published var userMode             : LoginMode?
    @Published var routeToChat          : Bool       = false
    var secondUser              : UserModel!
    
    var error                : NSError? = nil
    
    init() {
//        getUserList()
        $searchText
            .debounce(for: .milliseconds(800), scheduler: RunLoop.main)
            .removeDuplicates()
            .map({ (string) -> String? in
                if string.count < 1 {
                    self.filteredUsers = self.allUsers
                    return nil
                }
                
                return string
            })
            .compactMap({ $0 })
            .sink { (_) in
                //
            } receiveValue: { [self] searchField in
                filterUsers()
            }
            .store(in: &subscription)
    }
    
    func logOut() {
        UserDefault.logOut()
        userMode = .logOut
    }
    
    private func filterUsers(){
        filteredUsers = []
        guard !allUsers.isEmpty else { return }
        
        if !searchText.isEmpty {
            filteredUsers += allUsers.filter { $0.name.hasSubString(searchText) ||
                $0.company.hasSubString(searchText) ||
                ($0.address?.formattedAddress ?? "").hasSubString(searchText) ||
                $0.designation.hasSubString(searchText) ||
                $0.reportingPerson.hasSubString(searchText) }
        }else{
            filteredUsers = allUsers
        }
    }
    
    func getUserList() {
        guard let currentUser = UserDefault.getUser()  else { return }
        
        let query = db.collection("Users")
            .whereField("UserID", isNotEqualTo: currentUser.userID as Any)
            .order(by: "UserID", descending: false)
            .order(by: "Name", descending: false)
        
        query.getDocuments { [self] (snapshot, err) in
            addUserListener()
            if let error = err as NSError? {
                self.error = error
                showAlert = true
                return
            } else if snapshot!.isEmpty {
                return
            } else {
                let newUsers = snapshot!.documents.compactMap { UserModel($0.data()) }
                
                newUsers.forEach { (user) in
                    if !allUsers.contains(user) {
                        allUsers.append(user)
                    }
                }
                filterUsers()
                lastDocumentSnapshot = snapshot!.documents.last
            }
        }
    }
}

extension UserListViewModel {
    private func addUserListener(){
        db.collection("Users")
            .addSnapshotListener { [self] (snapShot, error) in
                guard let snapshot = snapShot else {
                    print("Error fetching snapshots: \(error!)")
                    self.error = error as NSError?
                    self.showAlert = true
                    return
                }
                
                snapshot.documentChanges.forEach { [self] diff in
                    let user = UserModel(diff.document.data())
                    if (diff.type == .added) {
                        
                        if !allUsers.contains(user) {
                            allUsers.append(user)
                        }else if !filteredUsers.contains(user){
                            filteredUsers.append(user)
                        }
                        
                        if let user = UserDefault.getUser() {
                            filteredUsers.removeAll(where: { $0.userID == user.userID })
                            allUsers.removeAll(where: { $0.userID == user.userID })
                        }
                    }
                    if (diff.type == .modified) {
                        print("Modified city: \(diff.document.data())")
                        if let index = filteredUsers.firstIndex(where: { $0.userID == user.userID }) {
                            filteredUsers.remove(at: index)
                            filteredUsers.insert(user, at: index)
                        }
                        if let index = allUsers.firstIndex(where: { $0.userID == user.userID }) {
                            allUsers.remove(at: index)
                            allUsers.insert(user, at: index)
                        }
                    }
                    if (diff.type == .removed) {
                        print("Removed city: \(diff.document.data())")
                        if let index = filteredUsers.firstIndex(where: { $0.userID == user.userID }) {
                            filteredUsers.remove(at: index)
                        }
                        
                        if let index = allUsers.firstIndex(where: { $0.userID == user.userID }) {
                            allUsers.remove(at: index)
                        }
                    }
                }
            }
    }
}

extension UserListViewModel {
    
    func delete(_ indexes: IndexSet) {
        indexes.forEach { (index) in
            let userID = filteredUsers[index].userID
            removeUserWith(userID ?? "")
        }
    }
    
    private func removeUserWith(_ userID: String) {
        
        guard !userID.isEmpty else { return }
        
        let query = db.collection("Users").whereField("UserID", isEqualTo: userID)
        
        query.getDocuments { [self] (snapshot, err) in
            if let err = err {
                print("\(err.localizedDescription)")
            } else {
                snapshot?.documents.forEach({ (document) in
                    db.collection("Users").document(document.documentID).delete() { [self] err in
                        if let err = err {
                            print("Error removing document: \(err)")
                        } else {
                            removeUserDocumentFor(userID)
                            print("Document successfully removed!")
                        }
                    }
                })
            }
        }
    }
    private func removeUserDocumentFor(_ userID: String) {
        let query = db.collection("CompanyAddress").whereField("UserID", isEqualTo: userID)
        query.getDocuments { [self] (snapShot, error) in
            if let error = error as NSError? {
                self.error = error
            }else{
                if let snapShot = snapShot,
                   let address = snapShot.documents.first(where: { $0["UserID"] as? String == userID })
                {
                    db.collection("CompanyAddress").document(address.documentID).delete() { [self] err in
                        if let error = err as NSError? {
                            self.error = error
                        } else {
                            print("Document successfully removed!")
                        }
                    }
                }
            }
        }
    }
}
