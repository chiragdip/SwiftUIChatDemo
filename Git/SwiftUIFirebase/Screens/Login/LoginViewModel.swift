//
//  LoginViewModel.swift
//  SwiftUIFirebase
//
//  Created by MAC215 on 24/02/21.
//

import SwiftUI
import Foundation
import Firebase
import FirebaseFirestoreSwift

final class LoginViewModel: ObservableObject {
    @Published var emailID              : String = ""
    @Published var password             : String = ""
    @Published var tappedOnLogin        : Bool   = false
    
    @Published var apiStatus            : APIResult?
    
    @State     var isUserLoggedIn       : Bool   = false
    
    var error                : NSError? = nil
    @Published var showAlert            : Bool   = false
    
    private let db = Firestore.firestore()
    
    func loginUser() {
        self.tappedOnLogin = true
        apiStatus = .loading
        Auth
            .auth()
            .signIn(withEmail: emailID, password: password) { [self] (result, error) in
                
                if let error = error as NSError? {
                    apiStatus = .failed
                    tappedOnLogin = false
                    showAlert = true
                    self.error = error
                    return
                }
                
                if let result = result {
                    self.getUserDetail(result.user.uid)
                }
            }
    }
    
    func getUserDetail(_ userID: String) {
        let query = db
            .collection("Users")
            .whereField("UserID", isEqualTo: userID)
        
        query.getDocuments { [self] (snapshot, error) in
            if let error = error as NSError?  {
                apiStatus = .failed
                self.error = error
                showAlert = true
            } else if snapshot!.isEmpty {
                apiStatus = .success
                tappedOnLogin = false
                return
            } else {
                apiStatus = .success
                let newUsers = snapshot!.documents.compactMap { UserModel($0.data()) }
                if let user = newUsers.first {
                    UserDefault.saveUser(user)
                }
            }
            tappedOnLogin = false
        }
    }
    
    func createUser(_ userID: String) {
        
    }
}


