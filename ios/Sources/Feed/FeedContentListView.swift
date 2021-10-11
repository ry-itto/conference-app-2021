import ComposableArchitecture
import Model
import Styleguide
import SwiftUI
import Repository
import Player

public struct FeedContentListState: Equatable {
    public var feedItemStates: IdentifiedArrayOf<FeedItemState>
    
    public init(
        feedItemStates: IdentifiedArrayOf<FeedItemState>
    ) {
        self.feedItemStates = feedItemStates
    }
}

public enum FeedContentListAction {
    case feedItem(id: FeedContent.ID, action: FeedItemAction)
}

public struct FeedContentListEnvironment {
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

public let feedContentListReducer = Reducer<FeedContentListState, FeedContentListAction, FeedContentListEnvironment>.combine(
    feedItemReducer.forEach(
        state: \.feedItemStates,
        action: /FeedContentListAction.feedItem(id:action:),
        environment: { environment in
            .init(
                feedRepository: environment.feedRepository,
                player: environment.player
            )
        }
    ),
    .init { state, action, _ in
        switch action {
        case .feedItem:
            return .none
        }
    }
)

public struct FeedContentListView: View {
    private let store: Store<FeedContentListState, FeedContentListAction>

    public init(store: Store<FeedContentListState, FeedContentListAction>) {
        self.store = store
    }

    public var body: some View {
        LazyVGrid(
            columns: Array(
                repeating: GridItem(.flexible(), spacing: .zero),
                count: 2
            ),
            spacing: 16
        ) {
            ForEachStore(
                store.scope(
                    state: \.feedItemStates,
                    action: FeedContentListAction.feedItem(id:action:)
                ),
                content: SmallCard.init(store:)
            )
        }
        .padding(.horizontal, SmallCard.Const.margin)
    }
}

#if DEBUG
public struct FeedContentListView_Previews: PreviewProvider {
    /**
     
     */
    public static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            FeedContentListView(
                store: .init(
                    initialState: .init(
                        feedItemStates: .init(
                            uniqueElements: [
                                .init(feedContent: .blogMock()),
                                .init(feedContent: .blogMock()),
                                .init(feedContent: .videoMock()),
                                .init(feedContent: .videoMock()),
                                .init(feedContent: .podcastMock()),
                                .init(feedContent: .podcastMock()),
                            ],
                            id: \.id
                        )
                    ),
                    reducer: .empty,
                    environment: {}
                )
            )
            .background(AssetColor.Background.primary.color)
            .previewDevice(.init(rawValue: "iPhone 12"))
            .environment(\.colorScheme, colorScheme)
        }
    }
}
#endif
