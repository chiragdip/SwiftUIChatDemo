//
//  SignInViewModel.swift
//  SwiftUIFirebase
//
//  Created by MAC215 on 24/02/21.
//

import SwiftUI
import Foundation
import Firebase
import FirebaseStorageSwift

final class SignInViewModel: ObservableObject {
    @Published var emailID              : String = ""
    @Published var password             : String = ""
    @Published var confirmPassword      : String = ""
    
    @Published var name                 : String = ""
    @Published var company              : String = ""
    @Published var experience           : String = ""
    @Published var designation          : String = ""
    @Published var reportingPerson      : String = ""
    
    @Published var formattedAddress     : String = ""
    @Published var address1             : String = ""
    @Published var address2             : String = ""
    @Published var city                 : String = ""
    @Published var zipCode              : String = ""
    @Published var country              : String = ""
    @Published var state                : String = ""
    
    @Published var alertText            : String = ""
    
    @Published var apiStatus            : APIResult?
    @State     var isUserLoggedIn       : Bool   = false
    @Published var showAlert            : Bool   = false
    
    private let db = Firestore.firestore()
    
    func createUser() {
        if emailID.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            alertText = "Please enter valid user email and password"
            return
        }
        
        if password != confirmPassword {
            alertText = "Both passwords should be same."
            return
        }
        
        apiStatus = .loading
        Auth.auth().createUser(withEmail: emailID, password: password) { [self] (result, error) in
            if let error = error as NSError? {
                apiStatus = .failed
                alertText = error.localizedDescription
                showAlert = true
                return
            }
            
            if let result  = result {
                saveUserData(result.user)
            }
        }
    }
    
    private func saveUserData(_ user: User) {
        let dict = ["formattedAddress": formattedAddress,
                    "address1": address1,
                    "address2": address2,
                    "city": city,
                    "zipCode": zipCode,
                    "country": country,
                    "state": state] as [String: Any]
        
        let userDict = ["EmailID": user.email as Any,
                        "UserID": user.uid,
                        "Name" : name,
                        "Company": company,
                        "Experience": experience,
                        "Designation": designation,
                        "ReportingPerson": reportingPerson,
                        "Address": dict] as [String : Any]
        
        db.collection("Users").addDocument(data: userDict) { [self] (error) in
            if let error = error {
                apiStatus = .failed
                alertText = error.localizedDescription
                showAlert = true
            }else{
                let user = UserModel(userDict)
                UserDefault.saveUser(user)
                apiStatus = .success
                isUserLoggedIn = true
            }
        }
    }
}
