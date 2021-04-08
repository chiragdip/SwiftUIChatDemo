//
//  SwiftUIFirebaseApp.swift
//  SwiftUIFirebase
//
//  Created by MAC215 on 22/02/21.
//

import SwiftUI
import Firebase

@main
struct SwiftUIFirebaseApp: App {
    
    @Environment(\.scenePhase) private var scenePhase
    
    init() { configureFirebase() }
    
    private func configureFirebase() {
        FirebaseApp.configure()
        
        //Firebase Offline Cache settings
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        
        // Enable offline data persistence
        let db = Firestore.firestore()
        db.settings = settings
    }
    
    var body: some Scene {
        WindowGroup {
            if let _ = UserDefault.getUser() {
                NavigationView {
                    UserListView()
                }
            }else{
                NavigationView {
                    LoginView()
                }
            }
        }
        .onChange(of: scenePhase) { (phase) in
            switch phase {
            case .active:
                break
            case .background:
                break
            case .inactive:
                break
            @unknown default:
                break
            }
        }
    }
}
