/*
import Foundation

protocol ObjectSavable {
    func set<Object>(_ object: Object, forKey: UserDefaultsKey) throws where Object: Encodable
    func get<Object>(forKey: UserDefaultsKey, castTo type: Object.Type) throws -> Object where Object: Decodable
}

enum ObjectSavableError: String, LocalizedError {
    case unableToEncode = "Unable to encode object into data"
    case noValue = "No data object found for the given key"
    case unableToDecode = "Unable to decode object into given type"
    
    var errorDescription: String? {
        rawValue
    }
}

enum UserDefaultsKey: String {
    case LoggedInUser = "LoggedInUser"
}

extension UserDefaults {
    func getLoggedInUser() -> UserModel? {
        do {
            let user = try UserDefaults.standard.get(forKey: .LoggedInUser, castTo: UserModel.self)
            return user
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}

extension UserDefaults: ObjectSavable {
    func set<Object>(_ object: Object, forKey: UserDefaultsKey) throws where Object: Encodable {
        let key = forKey.rawValue
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            set(data, forKey: key)
        } catch {
            throw ObjectSavableError.unableToEncode
        }
    }
    
    func get<Object>(forKey: UserDefaultsKey, castTo type: Object.Type) throws -> Object where Object: Decodable {
        let key = forKey.rawValue
        guard let data = data(forKey: key) else { throw ObjectSavableError.noValue }
        let decoder = JSONDecoder()
        do {
            let object = try decoder.decode(type, from: data)
            return object
        } catch {
            throw ObjectSavableError.unableToDecode
        }
    }
}
*/
