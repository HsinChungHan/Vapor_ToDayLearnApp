//
//  AcronymCategoryPivot.swift
//  App
//
//  Created by Chung Han Hsin on 2019/3/10.
//

import Foundation
import FluentPostgreSQL


//利用這個class去管理acronym的sibling關係
//我們不能用像parent與child的關係的方式，去管理sibling的關係。
//因為這將會使query變成一個沒有效率的行為
//ex如果在category中有一個acronyms array，每次去搜尋一個acronym的所有categories，你將會跑遍所有的categories
//或者如果一個acronym中有一個categories array，如果要搜尋一個category的所有的acronyms，你將會跑遍所有的acronyms
final class AcronymCategoryPivot: PostgreSQLUUIDPivot{
    var id: UUID?
    
    var acronymID: Acronym.ID
    var categoryID: Category.ID
    
    //告訴Fluent哪兩個model是有sibling relationship的
    typealias Left = Acronym
    typealias Right = Category
    
    //告訴Fluent哪兩個model的id的key path
    static var leftIDKey: LeftIDKey = \.acronymID
    static var rightIDKey: RightIDKey = \.categoryID
    
    init(_ acronym: Acronym, _ category: Category) throws {
        self.acronymID = try acronym.requireID()
        self.categoryID = try category.requireID()
    }
    
}

//讓Fluent可以setup table
//在此增加foreign key constraint來監控acronyms和categories的關係。
//預防acronyms和categories被AcronymCategoryPivot link且兩個仍有關係時，還可以刪除的清況
//Ex有可能執行http://localhost:8080/api/acronyms/3/categories/1
//但若id為3的acronyms，若沒有任何categories的時候，在未設定foreign key constraint時，不會有任何錯誤拋出
//在設定foreign key constraint後，才會拋出錯誤
extension AcronymCategoryPivot: Migration{
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void>{
        return Database.create(self, on: connection, closure: { (builder) in
            try addProperties(to: builder)
            //將AcronymCategoryPivot中的acronymID與Acronym的Acronym.id作foreign key constraint
            //cascade表當你做完刪除後，使用cascade策略(這代表relationship會被自動移除，若有錯誤則會丟出)
            builder.reference(from: \.acronymID, to: \Acronym.id, onDelete: .cascade)
            builder.reference(from: \.categoryID, to: \Category.id, onDelete: .cascade)
        })
    }
    
}

//讓我們可以使用adding和removing realtionship的語法糖衣
extension AcronymCategoryPivot: ModifiablePivot{}
