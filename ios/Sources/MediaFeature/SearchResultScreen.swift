import Component
import ComposableArchitecture
import Feed
import Model
import Styleguide
import SwiftUI

public struct SearchResultScreen: View {

    private let store: Store<FeedContentListState, FeedContentListAction>

    init(store: Store<FeedContentListState, FeedContentListAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                AssetColor.Background.primary.color
                if viewStore.feedItemStates.isEmpty {
                    empty
                } else {
                    ScrollView {
                        FeedContentListView(store: store)
                    }
                }
            }
        }
    }
}

extension SearchResultScreen {
    private var empty: some View {
        VStack {
            Text(L10n.SearchResultScreen.Empty.title)
                .font(.subheadline)
                .foregroundColor(AssetColor.Base.primary.color)
                .padding(.top, 40)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#if DEBUG
public struct SearchResultScreen_Previews: PreviewProvider {
    public static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            SearchResultScreen(
                store: .init(
                    initialState: .init(feedItemStates: .init()),
                    reducer: .empty,
                    environment: ()
                )
            )
            .previewDevice(.init(rawValue: "iPhone 12"))
            .environment(\.colorScheme, colorScheme)

            SearchResultScreen(
                store: .init(
                    initialState: .init(
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
                    ),
                    reducer: .empty,
                    environment: ()
                )
            )
            .previewDevice(.init(rawValue: "iPhone 12"))
            .environment(\.colorScheme, colorScheme)
        }
    }
}
#endif
