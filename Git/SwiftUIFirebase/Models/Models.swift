//
//  Models.swift
//  SwiftUIFirebase
//
//  Created by MAC215 on 24/02/21.
//

import Foundation
import Firebase
import FirebaseStorageSwift

struct UserModel {
    let userID          : String!
    let email           : String!
    let name            : String!
    let company         : String!
    let experience      : String!
    let designation     : String!
    let reportingPerson : String!
    
    var address     : Address?
    
    init(_ dict: [String : Any]) {
        userID          = dict["UserID"] as? String
        email           = dict["EmailID"] as? String
        name            = dict["Name"] as? String
        company         = dict["Company"] as? String
        experience      = dict["Experience"] as? String
        designation     = dict["Designation"] as? String
        reportingPerson = dict["ReportingPerson"] as? String
        
        if let addressDict = dict["Address"] as? [String: Any] {
            address = Address(addressDict)
        }
    }
}

extension UserModel: Equatable {
    static func == (lhs: UserModel, rhs: UserModel) -> Bool {
        return lhs.userID == rhs.userID
    }
}

extension UserModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(userID)
    }
}

extension UserModel: Codable {
    enum CodingKeys: String, CodingKey {
        case userID                 = "userID"
        case email                  = "email"
        case name                   = "name"
        case company                = "company"
        case experience             = "experience"
        case designation            = "designation"
        case reportingPerson        = "reportingPerson"
        case address                = "address"
    }
    
    init(from decoder: Decoder) throws {
        let values          = try decoder.container(keyedBy: CodingKeys.self)
        userID              = try? values.decodeIfPresent(String.self, forKey: .userID)
        email               = try? values.decodeIfPresent(String.self, forKey: .email)
        name                = try? values.decodeIfPresent(String.self, forKey: .name)
        company             = try? values.decodeIfPresent(String.self, forKey: .company)
        experience          = try? values.decodeIfPresent(String.self, forKey: .experience)
        designation         = try? values.decodeIfPresent(String.self, forKey: .designation)
        reportingPerson     = try? values.decodeIfPresent(String.self, forKey: .reportingPerson)
        
        address             = try  values.decodeIfPresent(Address.self, forKey: .address)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy : CodingKeys.self)
        try container.encode(userID, forKey: .userID)
        try container.encode(email, forKey: .email)
        try container.encode(name, forKey: .name)
        try container.encode(company, forKey: .company)
        try container.encode(experience, forKey: .experience)
        try container.encode(designation, forKey: .designation)
        try container.encode(reportingPerson, forKey: .reportingPerson)
        try container.encode(address, forKey: .address)
    }
}

struct Address {
    let formattedAddress  : String!
    let address1          : String!
    let address2          : String!
    let city              : String!
    let zipCode           : String!
    let country           : String!
    let state             : String!
    
    init(_ dict: [String: Any]) {
        formattedAddress = dict["formattedAddress"] as? String
        address1         = dict["address1"] as? String
        address2         = dict["address2"] as? String
        city             = dict["city"] as? String
        zipCode          = dict["zipCode"] as? String
        country          = dict["country"] as? String
        state            = dict["state"] as? String
    }
}

extension Address: Codable {
    enum CodingKeys: String, CodingKey {
        case formattedAddress   = "formattedAddress"
        case address1           = "address1"
        case address2           = "address2"
        case city               = "city"
        case zipCode            = "zipCode"
        case country            = "country"
        case state              = "state"
    }
    
    init(from decoder: Decoder) throws {
        let values          = try decoder.container(keyedBy: CodingKeys.self)
        formattedAddress    = try? values.decodeIfPresent(String.self, forKey: .formattedAddress)
        address1            = try? values.decodeIfPresent(String.self, forKey: .address1)
        address2            = try? values.decodeIfPresent(String.self, forKey: .address2)
        city                = try? values.decodeIfPresent(String.self, forKey: .city)
        zipCode             = try? values.decodeIfPresent(String.self, forKey: .zipCode)
        country             = try? values.decodeIfPresent(String.self, forKey: .country)
        state               = try? values.decodeIfPresent(String.self, forKey: .state)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy : CodingKeys.self)
        try container.encode(formattedAddress, forKey: .formattedAddress)
        try container.encode(address1, forKey: .address1)
        try container.encode(address2, forKey: .address2)
        try container.encode(city, forKey: .city)
        try container.encode(zipCode, forKey: .zipCode)
        try container.encode(country, forKey: .country)
        try container.encode(state, forKey: .state)
    }
}
 
extension UserModel {
    static func getDummyUser() -> UserModel {
        let addressDict = ["formattedAddress": "Test formatted address",
                           "address1" : "Test address 1",
                           "address" : "Test address 2",
                           "city" : "Test city",
                           "zipCode" : "Test zipcode",
                           "country" : "Test country",
                           "state" : "Test state"]

        let dict1 = ["UserID": "1",
                     "EmailID": "chiragdip.israni@tatvasoft.com",
                     "Name": "Chiragdip Israni",
                     "Company": "Tatvasoft",
                     "Experience" : "4.8",
                     "Designation": "SSE",
                     "ReportingPerson": "Mayank Patel",
                     "Address": addressDict] as [String : Any]
        
        return UserModel(dict1)
    }
    /*
    static func getDummyUsers() -> [UserModel] {

        let addressDict = ["formattedAddress": "Test formatted address",
                           "address1" : "Test address 1",
                           "address" : "Test address 2",
                           "city" : "Test city",
                           "zipCode" : "Test zipcode",
                           "country" : "Test country",
                           "state" : "Test state"]

        let dict1 = ["UserID": "1",
                     "EmailID": "chiragdip.israni@tatvasoft.com",
                     "Name": "Chiragdip Israni",
                     "Company": "Tatvasoft",
                     "Experience" : "4.8",
                     "Designation": "SSE",
                     "ReportingPerson": "Mayank Patel",
                     "Address": addressDict] as [String : Any]
                
        let dict2 = ["UserID": "2",
                     "EmailID": "narendra.pandey@tatvasoft.com",
                     "Name": "Narendra Pandey",
                     "Company": "Tatvasoft",
                     "Experience" : "4.8",
                     "Designation": "SSE",
                     "ReportingPerson": "Mayank Patel",
                     "Address": addressDict] as [String : Any]
        
        let dict3 = ["UserID": "3",
                     "EmailID": "saurabh.rajput@tatvasoft.com",
                     "Name": "Saurabh Rajput",
                     "Company": "Tatvasoft",
                     "Experience" : "3.5",
                     "Designation": "SE",
                     "ReportingPerson": "Atri Patel",
                     "Address": addressDict] as [String : Any]
        
        let dict4 = ["UserID": "4",
                     "EmailID": "pranjal.singh@tatvasoft.com",
                     "Name": "Pranjal Singh",
                     "Company": "Tatvasoft",
                     "Experience" : "2.5",
                     "Designation": "SE",
                     "ReportingPerson": "Vipul Patel",
                     "Address": addressDict] as [String : Any]
        
        let user1 = UserModel(dict1)
        let user2 = UserModel(dict2)
        let user3 = UserModel(dict3)
        let user4 = UserModel(dict4)
        
        return [user1, user2, user3, user4]
    }
 */
}

//---Message Models
struct MessageChannel {
    var participants: [String] = []
    var channelName: String = ""
    var messages: [Message] = []
    
    init(_ dict: [String : Any]) {
        channelName          = dict["ChannelName"] as? String ?? ""
        
        if let chatParticipants = dict["Participants"] as? [String] {
            participants = chatParticipants
        }
        
        if let messageArray = dict["Messages"] as? [[String: Any]] {
            messages = messageArray.compactMap { Message($0) }
        }
    }
}

extension MessageChannel {
    mutating func addMessages(_ newMessages: [Message]) {
        messages += newMessages
    }
    
    mutating func remove(_ index: Int) {
        if messages.count >= index {
            messages.remove(at: index)
        }
    }
    
    mutating func insert(_ message: Message, AtIndex index: Int) {
        if messages.count >= index {
            messages.insert(message, at: index)
        }else{
            messages += [message]
        }
    }
}

fileprivate var formatter : DateFormatter {
    let formatter = DateFormatter()
    formatter.timeStyle = .medium
    formatter.dateStyle = .medium
    return formatter
}

fileprivate let storageRef = Firebase.Storage.storage().reference()

struct Message {
    let ID          : String!
    let message     : String!
    let senderID    : String!
    let receiverID  : String!
    let senderName  : String!
    let receiverName: String!
    let time        : Timestamp!
    let date        : Date!
    let dateString  : String!
    let imageURI    : String?
    
    init(_ dict: [String : Any]) {
        ID                   = dict["ID"] as? String
        message              = dict["Message"] as? String
        senderID             = dict["SenderID"] as? String
        receiverID           = dict["ReceiverID"] as? String
        senderName           = dict["SenderName"] as? String
        receiverName         = dict["ReceiverName"] as? String
        time                 = dict["Time"] as? Timestamp
        date                 = time.dateValue()
        dateString           = formatter.string(from: date)
        imageURI             = dict["ImageURI"] as? String
    }
}

extension Message: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(ID)
    }
}

