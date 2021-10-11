import Combine
import Model

public struct FeedRepositoryMock: FeedRepositoryProtocol {
    public init() {}
    public func feedContents() -> AnyPublisher<[FeedContent], KotlinError> {
        Future {
            $0(.success([]))
        }.eraseToAnyPublisher()
    }
    public func addFavorite(id: String) -> AnyPublisher<Void, KotlinError> {
        Empty().eraseToAnyPublisher()
    }
    public func removeFavorite(id: String) -> AnyPublisher<Void, KotlinError> {
        Empty().eraseToAnyPublisher()
    }
}
