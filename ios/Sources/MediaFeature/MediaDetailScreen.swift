import Component
import Feed
import ComposableArchitecture
import Model
import Styleguide
import SwiftUI

public struct MediaDetailState: Equatable {
    public var title: String
    public var listState: FeedContentListState

    public init(
        title: String,
        listState: FeedContentListState
    ) {
        self.title = title
        self.listState = listState
    }
}

public let mediaDetailReducer = Reducer<MediaDetailState, FeedContentListAction, Void> { _, action, _ in
    switch action {
    case .feedItem:
        return .none
    }
}

public struct MediaDetailScreen: View {
    private let store: Store<MediaDetailState, FeedContentListAction>

    public init(
        store: Store<MediaDetailState, FeedContentListAction>
    ) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                FeedContentListView(
                    store: store.scope(state: \.listState)
                )
            }
            .background(AssetColor.Background.primary.color.ignoresSafeArea())
            .navigationBarTitle(viewStore.title, displayMode: .inline)
        }
    }
}

#if DEBUG
public struct MediaDetailScreen_Previews: PreviewProvider {
    public static var previews: some View {
        MediaDetailScreen(
            store: .init(
                initialState: MediaDetailState(
                    title: "BLOG",
                    listState: .init(
                        feedItemStates: .init(
                            uniqueElements: [
                                .init(feedContent: .blogMock()),
                                .init(feedContent: .blogMock()),
                                .init(feedContent: .blogMock()),
                                .init(feedContent: .blogMock()),
                                .init(feedContent: .blogMock()),
                                .init(feedContent: .blogMock()),
                            ],
                            id: \.id
                        )
                    )
                ),
                reducer: .empty,
                environment: {}
            )
        )
        .previewDevice(.init(rawValue: "iPhone 12"))
        .environment(\.colorScheme, .light)

        MediaDetailScreen(
            store: .init(
                initialState: MediaDetailState(
                    title: "BLOG",
                    listState: .init(
                        feedItemStates: .init(
                            uniqueElements: [
                                .init(feedContent: .blogMock()),
                                .init(feedContent: .blogMock()),
                                .init(feedContent: .blogMock()),
                                .init(feedContent: .blogMock()),
                                .init(feedContent: .blogMock()),
                                .init(feedContent: .blogMock()),
                            ],
                            id: \.id
                        )
                    )
                ),
                reducer: .empty,
                environment: {}
            )
        )
        .previewDevice(.init(rawValue: "iPhone 12"))
        .environment(\.colorScheme, .dark)
    }
}
#endif
