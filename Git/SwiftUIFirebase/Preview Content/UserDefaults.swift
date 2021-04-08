import Foundation

struct UserDefault {
    static func saveUser(_ user: UserModel) {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(user), forKey:"User")
    }
    
    static func getUser() -> UserModel? {
        if let data = UserDefaults.standard.value(forKey:"User") as? Data {
            return try? PropertyListDecoder().decode(UserModel.self, from: data)
        }
        return nil
    }
    
    static func logOut() {
        UserDefaults.standard.removeObject(forKey: "User")
        UserDefaults.standard.synchronize()
    }
}

enum APIResult {
    case loading
    case success
    case failed
}
