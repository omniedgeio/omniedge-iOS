import Combine
import Foundation

@available(macOS 10.15, *)
public struct OENetwork {
    var baseURL: String!
    var networkDispatcher: NetworkDispatcher!
    @available(macOS 10.15, *)
    
    public init(baseURL: String, dispatcher: NetworkDispatcher = NetworkDispatcher()) {
        self.baseURL = baseURL
        self.networkDispatcher = dispatcher
    }

    @available(macOS 10.15, *)
    public func dispatch<R: Request>(_ request: R) -> AnyPublisher<R.ReturnType, NetworkRequestError> {
        //typealias RequestPublisher = AnyPublisher<R.ReturnType, NetworkRequestError>
        guard let urlRequest = request.asURLRequest(baseURL: baseURL) else {
            return Fail(outputType: R.ReturnType.self,
                        failure: NetworkRequestError.badRequest).eraseToAnyPublisher()
        }
        let requestPublisher: AnyPublisher<R.ReturnType, NetworkRequestError> = networkDispatcher.dispatch(request: urlRequest)
        return requestPublisher.eraseToAnyPublisher()
    }

    @available(macOS 12.0, iOS 15.0, *)
    public func dispatch<R: Request>(_ request: R) async throws -> R.ReturnType {
        guard let urlRequest = request.asURLRequest(baseURL: baseURL) else {
            throw NetworkRequestError.badRequest
        }
        return try await networkDispatcher.dispatch(request: urlRequest)
    }
}
