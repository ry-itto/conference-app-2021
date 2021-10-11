import Component
import Feed
import ComposableArchitecture
import Model
import SwiftUI
import Styleguide
import IdentifiedCollections

public struct MediaSectionView: View {
    let type: MediaType
    let store: Store<ViewState, ViewAction>

    struct ViewState: Equatable {
        var feedItemStates: IdentifiedArrayOf<FeedItemState>
    }

    enum ViewAction {
        case feedItem(id: FeedContent.ID, content: FeedItemAction)
        case showMore(MediaType)
    }

    public var body: some View {
        VStack(spacing: .zero) {
            WithViewStore(store) { viewStore in
                MediaSectionHeader(
                    type: type,
                    moreAction: { viewStore.send(.showMore(type)) }
                )
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: .zero) {
                        ForEachStore(
                            store.scope(
                                state: \.feedItemStates,
                                action: ViewAction.feedItem(id:content:)
                            ),
                            content: MediumCard.init(store:)
                        )
                    }
                }
            }
        }
    }
}

#if DEBUG
public struct MediaSectionView_Previews: PreviewProvider {
    public static var previews: some View {
        let sizeCategories: [ContentSizeCategory] = [
            .large, // Default
            .extraExtraExtraLarge
        ]
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            ForEach(sizeCategories, id: \.self) { sizeCategory in
                MediaSectionView(
                    type: .blog,
                    store: .init(
                        initialState: MediaSectionView.ViewState(
                            feedItemStates: [
                                .init(feedContent: .blogMock()),
                                .init(feedContent: .blogMock()),
                                .init(feedContent: .blogMock()),
                                .init(feedContent: .blogMock()),
                                .init(feedContent: .blogMock()),
                                .init(feedContent: .blogMock()),
                            ]
                        ),
                        reducer: .empty,
                        environment: {}
                    )
                )
                .background(AssetColor.Background.primary.color)
                .environment(\.sizeCategory, sizeCategory)
                .environment(\.colorScheme, colorScheme)
            }
        }
        .frame(width: 375, height: 301)
        .previewLayout(.sizeThatFits)
        .accentColor(AssetColor.primary.color)
    }
}
#endif
