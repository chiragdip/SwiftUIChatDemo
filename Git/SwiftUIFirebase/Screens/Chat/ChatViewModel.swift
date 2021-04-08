//
//  ChatViewModel.swift
//  SwiftUIFirebase
//
//  Created by MAC215 on 25/02/21.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseStorageSwift

final class ChatViewModel: ObservableObject {
    @Published var messages    = [Message]()
    @Published var userMessage  : String  =  ""
    
    var shouldAnimateScrolling = false
    
    private var isChatCreated           : Bool   = false
    private var docReference: DocumentReference!
    var error                : NSError? = nil
    @Published var showAlertForImageSelection   : Bool   = false
    @Published var imagePickerType   : ImagePickerType?
    @Published var selectedImage   : UIImage? {
        didSet {
            if let image = selectedImage {
                uploadImage(image)
            }
        }
    }
    
    var secondUser : UserModel!
    
    // Points to the root reference
    
    private let storageRef = Firebase.Storage.storage().reference()
    private let db = Firestore.firestore()
    
    lazy private var currentUserID : String = {
        guard let user = UserDefault.getUser() else { return "" }
        return user.userID
    }()
    
    func isMyMessage(_ message: Message) -> Bool { message.senderID == currentUserID }
}

extension ChatViewModel {
    func openCamera() {
        imagePickerType = .Camera
    }
    
    func openGallery() {
        imagePickerType = .Gallery
    }
}

extension ChatViewModel {
    private func createNewChat() {
        let users = [currentUserID, secondUser?.userID]
        let data: [String: Any] = ["Participants":users]
        
        let collection = db.collection("Chat")
        collection.addDocument(data: data) { [self] (error) in
            if let error = error {
                print("Unable to create chat! \(error)")
                return
            } else {
                self.isChatCreated = true
                loadChat()
            }
        }
    }

    func loadChat() {
        //Fetch all the chats which has current user in it
        let document = db.collection("Chat")
            .whereField("Participants", arrayContainsAny: [currentUserID, secondUser?.userID as Any] as [Any])
        
        document.getDocuments { [self] (chatQuerySnap, error) in
            if let error = error {
                print("Error: \(error)")
                return
            } else {
                //Count the no. of documents returned
                guard let queryCount = chatQuerySnap?.documents.count else {
                    return
                }
                
                if queryCount == 0 {
                    //If documents count is zero that means there is no chat available and we need to create a new instance
                    if !isChatCreated {
                        createNewChat()
                    }
                }
                else if queryCount >= 1 {
                    //Chat(s) found for currentUser
                    for doc in chatQuerySnap!.documents {
                        
                        let chat = MessageChannel(doc.data())
                        //Get the chat which has user2 id
                        if (chat.participants.contains(secondUser!.userID)) {
                            docReference = doc.reference
                            //fetch it's thread collection
                            doc.reference.collection("Messages")
                                .order(by: "Time", descending: false)
                                .addSnapshotListener(includeMetadataChanges: true,
                                                     listener: { [self] (threadQuery, error) in
                                                        if let error = error as NSError? {
                                                            self.error = error
                                                            return
                                                        } else {
                                                            messages = []
                                                            let msgs = threadQuery!.documents.map({ Message($0.data()) })
                                                            messages.append(contentsOf: msgs)
                                                        }
                                                     })
                            return
                        } //end of if
                    } //end of for
                    if !isChatCreated {
                        createNewChat()
                    }
                } else {
                    print("Let's hope this error never prints!")
                }
            }
        }
    }
}

extension ChatViewModel {
    func uploadImage(_ image: UIImage) {
        let childName = "iOS_img_\(Date()).jpeg"
        let newChild = storageRef.child("\(childName)")
        newChild.putData(image.jpegData(compressionQuality: 0.5)!, metadata: nil) { (metadata, error) in
            if let _ = error {
                return
            }
            
            self.selectedImage = nil
            self.insertNewMessage(childName)
        }
    }
    
    func insertNewMessage(_ imageURI: String = "") {
        guard let user = UserDefault.getUser() else {
            return
        }
        
        let dict = ["ID": UUID().uuidString,
                    "Message": userMessage,
                    "SenderID": currentUserID,
                    "ReceiverID": secondUser.userID as Any,
                    "SenderName": user.name as Any,
                    "ReceiverName": secondUser.name as Any,
                    "Time": Timestamp(date: Date()),
                    "ImageURI": imageURI] as [String : Any]
        
        if docReference == nil {
            let query = db.collection("Chat").whereField("Participants", in: [currentUserID, secondUser.userID as Any])
            query.getDocuments { [self] (snapShot, error) in
                if let error = error as NSError? {
                    print("Error: \(error)")
                    self.error = error
                    return
                } else {
                    if let first = snapShot?.documents.first(where: { MessageChannel($0.data()).participants.contains(secondUser.userID) })?.reference {
                        docReference = first
                        docReference.collection("Messages").addDocument(data: dict) { [self] (error) in
                            if let error = error as NSError? {
                                print("Error occured.")
                                self.error = error
                                return
                            }
                            
                            addNewMessage(dict)
                        }
                    }
                }
            }
            
        }else{
            docReference.collection("Messages").addDocument(data: dict) { [self] (error) in
                if let error = error as NSError? {
                    print("Error occured.")
                    self.error = error
                    return
                }
                
                addNewMessage(dict)
            }
        }
    }
    
    private func addNewMessage(_ dict: [String : Any]) {
        messages.append(Message(dict))
        userMessage = ""
    }
}
