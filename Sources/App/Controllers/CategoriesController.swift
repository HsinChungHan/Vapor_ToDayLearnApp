import Vapor

struct CategoriesController: RouteCollection {
    func boot(router: Router) throws {
        let categoriesRoute = router.grouped("api", "categories")
        categoriesRoute.post(Category.self, use: creatHandler)
        categoriesRoute.get(use: getAllHandler)
        categoriesRoute.get(Category.parameter, use: getHandler)
        categoriesRoute.post(Category.parameter, "acronyms", use: getAcronymsHandler)
    }
    
    func creatHandler(_ req: Request, category: Category) throws -> Future<Category>{
        return category.save(on: req)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Category]>{
        return Category.query(on: req).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<Category>{
        return try req.parameters.next(Category.self)
    }
    
    // /api/categories/<CATEGORY_ID>/acronyms
    func getAcronymsHandler(_ req: Request) throws -> Future<[Acronym]>{
        return try req.parameters.next(Category.self)
            .flatMap(to: [Acronym].self, { (category) in
                try category.acronyms.query(on: req).all()
            })
    }
}
