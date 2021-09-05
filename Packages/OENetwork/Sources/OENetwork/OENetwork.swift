import Combine
import Foundation

public struct OENetwork {
    var baseURL: String!
    var networkDispatcher: NetworkDispatcher!

    public init(baseURL: String, dispatcher: NetworkDispatcher = NetworkDispatcher()) {
        self.baseURL = baseURL
        self.networkDispatcher = dispatcher
    }

    public func dispatch<R: Request>(_ request: R) -> AnyPublisher<R.ReturnType, NetworkRequestError> {
        //typealias RequestPublisher = AnyPublisher<R.ReturnType, NetworkRequestError>
        guard let urlRequest = request.asURLRequest(baseURL: baseURL) else {
            return Fail(outputType: R.ReturnType.self,
                        failure: NetworkRequestError.badRequest).eraseToAnyPublisher()
        }
        let requestPublisher: AnyPublisher<R.ReturnType, NetworkRequestError> = networkDispatcher.dispatch(request: urlRequest)
        return requestPublisher.eraseToAnyPublisher()
    }
}
