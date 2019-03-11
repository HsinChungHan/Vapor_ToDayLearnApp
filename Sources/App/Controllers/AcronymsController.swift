import Vapor
import Fluent

struct AcronymsController: RouteCollection {
    
    
    
    func boot(router: Router) throws {
        let acronymsRoutes = router.grouped("api", "acronyms")
        //在這邊註冊你的routes
        //router.get("api", "acronyms", use: getAllHandler) //可以利用acronymsRoutes改寫
//        acronymsRoutes.post(use: createHandler)
        acronymsRoutes.post(Acronym.self, use: createHandler)
        acronymsRoutes.get(use: getAllHandler)
        acronymsRoutes.get(Acronym.parameter, use: getByIDHandler)
        acronymsRoutes.put(Acronym.parameter, use: putByIDHandler)
        acronymsRoutes.delete(Acronym.parameter, use: deleteByIDHandler)
        acronymsRoutes.get("search", "short", use: searchShortHandler)
        acronymsRoutes.get("search", use: searchShortLongHandler)
        acronymsRoutes.get("first", use: getFirstHandler)
        acronymsRoutes.get("first", "search", use: searchFirstHandler)
        acronymsRoutes.get("sorted", use: sortedHandler)
        
        acronymsRoutes.get(Acronym.parameter, "user", use: getUserHandler)
        acronymsRoutes.post(Acronym.parameter, "categories", Category.parameter, use: addCategoriesHandle)
        acronymsRoutes.get(Acronym.parameter, "categories", use: getCategoriesHandler)
        acronymsRoutes.delete(Acronym.parameter, "categories", Category.parameter , use: removeCategoriesHandler )
    }
    
    //MARK:- Rowter Call Back
    
    //新增一個API: /api/acronyms/
    //by nested
    /*
    func createHandler(_ req: Request) throws -> Future<Acronym>{
        return try req.content.decode(Acronym.self).flatMap(to: Acronym.self, { (acronym) -> Future<Acronym> in
            return acronym.save(on: req)
        })
    }
    */
    //因為Vapor提供helper function for put, post, and patch routes來針對近來的資料解碼，所以可以不用像原先依樣用網狀的結構
    func createHandler(_ req: Request, acronym: Acronym) throws -> Future<Acronym>{
        return acronym.save(on: req)
    }
    
    
    
    //retrive API: /api/acronyms，得到所有的Acronym
    func getAllHandler(_ req: Request) throws -> Future<[Acronym]>{
        return Acronym.query(on: req).all()
    }
    
    //retrive API: /api/acronyms/id
    func getByIDHandler(_ req: Request) throws -> Future<Acronym>{
        return try req.parameters.next(Acronym.self)
    }
    
    //update API: /api/acronyms/id
    func putByIDHandler(_ req: Request) throws -> Future<Acronym>{
        return try flatMap(to: Acronym.self, req.parameters.next(Acronym.self), req.content.decode(Acronym.self), { (acronym, updatedAcronym) -> Future<Acronym> in
            acronym.short = updatedAcronym.short
            acronym.long = updatedAcronym.long
            acronym.userID = updatedAcronym.userID
            return acronym.save(on: req)
        })
    }
    
    //delete API: /api/acronyms/id/
    func deleteByIDHandler(_ req: Request) throws -> Future<HTTPStatus>{
        return try req.parameters.next(Acronym.self)
        .delete(on: req)
        .transform(to: .noContent)
    }
 
    
    
    
    //search特定acronym short API: /api/acronyms/search/short/?term=所搜尋字串
    func searchShortHandler(_ req: Request) throws -> Future<[Acronym]>{
        guard let searchTerm = req.query[String.self, at: "term"] else {throw Abort.init(.badRequest)}
        return Acronym.query(on: req)
        .filter(\.short == searchTerm)
        .all()
    }
    
    //search特定acronym API: /api/acronyms/search/?term=所搜尋字串
    func searchShortLongHandler(_ req: Request) throws -> Future<[Acronym]>{
        guard let searchTerm = req.query[String.self, at: "term"] else {throw Abort.init(.badRequest)}
        return Acronym.query(on: req).group(.or, closure: { (or) in
            or.filter(\.short == searchTerm)
            or.filter(\.long == searchTerm)
        }).all()
    }
    
    //search first result
    func getFirstHandler(_ req: Request) throws -> Future<Acronym>{
        return Acronym.query(on: req)
        .first()
        .unwrap(or: Abort.init(.notFound))
    }
    
    //search特定acronym API: /api/acronyms/first/search/?term=所搜尋字串
    func searchFirstHandler(_ req: Request) throws -> Future<Acronym>{
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort.init(.badRequest)
        }
        print("searchTerm: \(searchTerm)")
        return Acronym.query(on: req)
        .filter(\.short == searchTerm)
        .first()
        .unwrap(or: Abort.init(.notFound))
    }
    
    //sorted 找到的[acronym] api
    //此API會根據long term的資訊做排序
    func sortedHandler(_ req: Request) throws -> Future<[Acronym]>{
        return Acronym.query(on: req)
        .sort(\.long, .ascending)
        .all()
    }
    
    //根據此acronym的userId取得相對應的user
    func getUserHandler(_ req: Request) throws -> Future<User>{
        return try req
            .parameters.next(Acronym.self)
            .flatMap(to: User.self, { (acronym) in
                acronym.user.get(on: req)
            })
    }
    
    // /api/acronyms/1/categories/1
    //為acronym添加categories
    func addCategoriesHandle(_ req: Request) throws -> Future<HTTPStatus>{
        return try flatMap(to: HTTPStatus.self, req.parameters.next(Acronym.self), req.parameters.next(Category.self), { (acronym, category) in
            //使用attach來設定acronym和category間的關係。並且會新增一個pivot model並保存在database中
            return acronym.categories
                .attach(category, on: req)
                .transform(to: .created)
        })
    }
    
    
    // /api/acronyms/1/categories
    func getCategoriesHandler(_ req: Request) throws -> Future<[Category]>{
        return try req.parameters.next(Acronym.self).flatMap(to: [Category].self, { (acronym) in
            try acronym.categories.query(on: req).all()
        })
    }
    
    func removeCategoriesHandler(_ req: Request) throws -> Future<HTTPStatus>{
        return try flatMap(to: HTTPStatus.self, req.parameters.next(Acronym.self), req.parameters.next(Category.self), { (acronym, category) in
            return acronym.categories
            .detach(category, on: req)
            .transform(to: .noContent)
        })
    }
    
}
