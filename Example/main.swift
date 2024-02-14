import Papyrus

// MARK: 0. Define your API.

public struct SampleResponse<T:Codable>: Codable{
    let data: T
    let status:Bool
}


//@Mock
@API()
@KeyMapping(.snakeCase)
@Authorization(.bearer("<my-auth-token>"))
@Headers(["X-Client-Version": "1.2.3"])
protocol Sample {
    @GET("/todos")
    @RESPONSE(SampleResponse<Todo>, key: "data.combos.records")
    func getTodos() async throws -> [Todo]
    @GET("/todo")
    func getTodo() async throws -> [Todo]

}






public struct Todo: Codable {
    let id: Int
    let name: String
}

// MARK: 1. Create a Provider with any custom configuration.

let provider = Provider(baseURL: "http://127.0.0.1:3000")
    .intercept { req, next in
        let start = Date()
        let res = try await next(req)
        let elapsedTime = String(format: "%.2fs", Date().timeIntervalSince(start))
        let statusCode = res.statusCode.map { "\($0)" } ?? "N/A"
        print("Got a \(statusCode) for \(req.method) \(req.url!) after \(elapsedTime)")
        return res
    }

// MARK: 2. Initialize an API instance & call an endpoint.

let api: Sample = SampleAPI(provider: provider)
let todos = try await api.getTodos()

// MARK: 3. Easily mock endpoints for tests.

let mock = SampleMock()
mock.mockGetTodos {
    return [
        Todo(id: 1, name: "Foo"),
        Todo(id: 2, name: "Bar"),
    ]
}

let mockedTodos = try await mock.getTodos()
