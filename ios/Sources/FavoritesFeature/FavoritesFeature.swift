import Component
import ComposableArchitecture
import Model
import Player
import Repository
import Feed

public struct FavoritesState: Equatable {
    public var listState: FeedContentListState

    public init(listState: FeedContentListState) {
        self.listState = listState
    }
}

public enum FavoritesAction {
    case showSetting
    case feedList(FeedContentListAction)
}

public struct FavoritesEnvironment {
    public let feedRepository: FeedRepositoryProtocol
    public let player: PlayerProtocol

    public init(
        feedRepository: FeedRepositoryProtocol,
        player: PlayerProtocol
    ) {
        self.feedRepository = feedRepository
        self.player = player
    }
}

public let favoritesReducer = Reducer<FavoritesState, FavoritesAction, FavoritesEnvironment>.combine(
    feedContentListReducer.pullback(
        state: \.listState,
        action: /FavoritesAction.feedList,
        environment: { environment in
            .init(
                feedRepository: environment.feedRepository,
                player: environment.player
            )
        }
    ),
    .init { _, action, _ in
        switch action {
        case .feedList:
            return .none
        case .showSetting:
            return .none
        }
    }
)
