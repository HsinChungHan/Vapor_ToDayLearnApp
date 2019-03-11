import Foundation
import Vapor
import FluentPostgreSQL


final class User: Codable{
    //這一次的id是個獨特id，確保id不會重複
    var id: UUID?
    var name: String
    var userName: String
    
    init(name: String, userName: String) {
        self.name = name
        self.userName = userName
    }
}

extension User: PostgreSQLUUIDModel{}
extension User: Content{}
extension User: Migration{}
extension User: Parameter{}

extension User{
    //children擺在後面
    var acronyms: Children<User, Acronym>{
        //可以利用userID得到此key path
        return children(\.userID)
    }
}
