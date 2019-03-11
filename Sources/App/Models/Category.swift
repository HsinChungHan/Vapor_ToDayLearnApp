import Foundation
import Vapor
import FluentPostgreSQL

//和acronym是多對多的關係
//所以是和acronym是sibling relationship
//因此要使用relationship

final class Category: Codable{
    var id: Int?
    var name: String
    
    init(name: String) {
        self.name = name
    }
}


extension Category: PostgreSQLModel{}
extension Category: Migration{}
extension Category: Content{}
extension Category: Parameter{}

extension Category{
    var acronyms: Siblings<Category, Acronym, AcronymCategoryPivot>{
        return siblings()
    }
}
