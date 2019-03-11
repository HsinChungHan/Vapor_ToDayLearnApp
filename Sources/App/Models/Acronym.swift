
import Vapor
import FluentPostgreSQL

final class Acronym: Codable{
    var id: Int?
    var short: String
    var long: String
    
    //setting up realtionship for a specific user
    var userID: User.ID
    
    init(short: String, long: String, userID: User.ID) {
        self.short = short
        self.long = long
        self.userID = userID
    }
    
    
    
}

//SQLiteModel裡面有id: Int? property，因為有id+1的function，所以讓Acronym繼承SQLiteModel
extension Acronym: PostgreSQLModel{}


//Set foreign key constraints here
//可以在這邊確保無法新增acronyms除非已經有User id
//可以在這邊確保你無法刪除User，除非你把此user所有的acronyms都已刪除
//可以確保你無法刪除User table，除非已把acronym table刪除
extension Acronym: Migration{
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void>{
        //在database中創造一個Acronym的table
        return Database.create(self, on: connection, closure: { (builder) in
            //新增所有fields到database中
            try addProperties(to: builder)
            
            //在Acronym和User間新增reference，利用userID(Acronym)和user.id(User)建立聯繫
            builder.reference(from: \.userID, to: \User.id)
        })
    }
    //最後因為你link acronym's userID 到 User table，所以你必須先創造User table。
    //到configure.swift中將User的migration移到acronym的migration之前...
    
}






extension Acronym: Content{}
extension Acronym: Parameter{}
//可以被SQLiteModel取代
/*
 extension Acronym: Model{
 typealias Database = SQLiteDatabase
 typealias ID = Int
 
 //前面加\是因為這是model的ID property的keypath
 public static var idKey: IDKey = \Acronym.id
 }
 */


//Getting the user of the acronym
//設定Acronym的parent
extension Acronym{
    //Parent擺在後面
    var user: Parent<Acronym, User>{
        //利用Fluent的function來得到parent,這將會得到acronym的user reference的keypath
        return parent(\.userID)
    }
    
    //利用AcronymCategoryPivot來設定Acronym的sibling
    var categories: Siblings<Acronym, Category, AcronymCategoryPivot>{
        return siblings()
    }
}



