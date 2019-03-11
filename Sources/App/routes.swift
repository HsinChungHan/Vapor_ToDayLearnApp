import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    //MARK: - Create
    //新增一個API: /api/acronyms/ ，且接受post的request，並會回傳一個Future<Acronym>
    /*
    router.post("api", "acronyms") { req -> Future<Acronym> in
        //req是json，所以利用decodable解碼，得到Future<Acronym>
        //req.content.decode(Acronym.self)會解碼出Future<Acronym>
        //再用flatMap從Future<Acronym>取出Acronym
        return try req.content.decode(Acronym.self).flatMap(to: Acronym.self, { (acronym) in
            //database利用Fluent來保存model
            //一但它被儲存，會回傳Future<Acronym>出來
            return acronym.save(on: req)
        })
    }
 */
 
    //MARK: - Retrieve
    //retrive API: /api/acronyms，得到所有的Acronym
    /*
    router.get("api", "acronyms") { (req) -> Future<[Acronym]> in
        return Acronym.query(on: req).all()
    }
    */
    
    //若想要取得特定iD的data，需要讓Acronym繼承Parameter
    //retrieve API: /api/acronyms/id
    /*
    router.get("api", "acronyms", Acronym.parameter) { (req) -> Future<Acronym> in
        return try req.parameters.next(Acronym.self)
    }
 */
    
    //MARK: - Update
    //update API: /api/acronyms/id ,
    /*
    router.put("api", "acronyms", Acronym.parameter) { (req) -> Future<Acronym> in
        /*使用flatMap，(to: Acronym.self, req.parameters.next(Acronym.self), req.content.decode(Acronym.self)
         req.parameters.next(Acronym.self):從database中找出特定id的model
         req.content.decode(Acronym.self)：解碼特定id的model
        其中在block裡面的acronym和updatedAcronym(一個代表req中的model;另一個代表要update的acronym)
        */
        return try flatMap(to: Acronym.self, req.parameters.next(Acronym.self), req.content.decode(Acronym.self), { (acronym, updatedAcronym) in
            acronym.short = updatedAcronym.short
            acronym.long = updatedAcronym.long
            
            //最後把他們存回資料庫，並回傳result
            return acronym.save(on: req)
        })
    }
    */
    
    
    //MARK: -Delete
    //delete API: /api/acronyms/id/
    //回傳httpStatus
    /*
    router.delete("api", "acronyms", Acronym.parameter) { (req) -> Future<HTTPStatus > in
        //req.parameters.next(Acronym.self):根據Acronym.parameter，取出特定的Acronym
        return try req.parameters.next(Acronym.self)
            //Fluent允許我們直接刪除所取出的acronym
            .delete(on: req)
            //根據刪除結果，若成功刪除，會回傳204No Content回來
            .transform(to: .noContent)
    }
    */
    //MARK:- Search
    //search特定acronym short API: /api/acronyms/search/short/?term=所搜尋字串/
    //這是用來搜尋比較不敏感的訊息，直接解析URL所傳的字串
    //此API只比對short的欄位
    /*
    router.get("api", "acronyms", "search", "short") { (req) -> Future<[Acronym]> in
        guard let searchTerm = req.query[String.self, at: "term"] else{
            //如果在req中找不到這個term的話，會回傳400Bad Request
            throw Abort.init(.badRequest)
        }
        
        return Acronym.query(on: req)
        .filter(\.short == searchTerm)
        .all()
    }
    */
    //search特定acronym API: /api/acronyms/search/?term=所搜尋字串/
    //會搜尋short和long欄位，只要short或long有一個成立，就算搜尋到
    /*
    router.get("api", "acronyms", "search") { (req) -> Future<[Acronym]> in
        guard let searchTerm = req.query[String.self, at: "term"] else{
            //如果在req中找不到這個term的話，會回傳400Bad Request
            throw Abort.init(.badRequest)
        }
        
        return Acronym.query(on: req).group(.or, closure: { (or) in
            or.filter(\.short == searchTerm)
            or.filter(\.long == searchTerm)
        }).all()
    }
    */
    
    //search first result
    /*
    router.get("api", "acronyms", "first") { (req) -> Future<Acronym> in
        return Acronym.query(on: req)
        .first()
        //用unwrap確保一定有東西回傳，因為有可能搜尋不到，此時就可以回傳404
        .unwrap(or: Abort.init(.notFound))
    }
    */
    
    //search特定acronym API: /api/acronyms/first/search/?term=所搜尋字串/
    //並回傳第一個找到的acronym
    /*
    router.get("api", "acronyms","first", "search") { (req) -> Future<Acronym> in
        guard let searchTerm = req.query[String.self, at: "term"] else {throw Abort.init(.badRequest)}
        
        return Acronym.query(on: req)
        .filter(\.short == searchTerm)
        .first()
        .unwrap(or: Abort.init(.notFound))
    }
    */
    //sorted 找到的[acronym] api
    //此API會根據long term的資訊做排序
    /*
    router.get("api", "acronyms", "sorted") { (req) -> Future<[Acronym]> in
        return Acronym.query(on: req)
        .sort(\.long, .ascending)
        .all()
    }
    */
    
    //創造一個新的AcronymsController
    let acronymsController = AcronymsController()
    //將這個controller註冊給router，這樣才能用實作在AcronymsController的api
    try router.register(collection: acronymsController)
    
    let usersController = UsersController()
    try router.register(collection: usersController)
    
    let categoriesController = CategoriesController()
    try router.register(collection: categoriesController)
}
