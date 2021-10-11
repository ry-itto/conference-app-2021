import Component
import Feed
import ComposableArchitecture
import Model
import Player
import Repository
import IdentifiedCollections

public struct HomeState: Equatable {
    public var feedItemStates: IdentifiedArrayOf<FeedItemState>

    var topic: FeedItemState? {
        feedItemStates.first
    }

    var listFeedItemStates: IdentifiedArrayOf<FeedItemState> {
        IdentifiedArray(feedItemStates.dropFirst())
    }

    public init(feedItemStates: IdentifiedArrayOf<FeedItemState>) {
        self.feedItemStates = feedItemStates
    }
}

public enum HomeAction {
    case topic(action: FeedItemAction)
    case feedItem(id: FeedContent.ID, action: FeedItemAction)
    case answerQuestionnaire
    case showSetting
}

public struct HomeEnvironment {
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

public let homeReducer = Reducer<HomeState, HomeAction, HomeEnvironment>.combine(
    feedItemReducer.forEach(
        state: \.feedItemStates,
        action: /HomeAction.feedItem(id:action:),
        environment: { environment in
            FeedItemEnvironment(
                feedRepository: environment.feedRepository,
                player: environment.player
            )
        }
    ),
    .init { state, action, _ in
        switch action {
        case let .topic(action):
            if let id = state.topic?.id {
                return .init(value: .feedItem(id: id, action: action))
            }
            return .none
        case .feedItem:
            return .none
        case .answerQuestionnaire:
            return .none
        case .showSetting:
            return .none
        }
    }
)
