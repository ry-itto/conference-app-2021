import ComposableArchitecture
import Feed
import Introspect
import Repository
import Model
import SwiftUI
import Styleguide

public struct FavoritesScreen: View {
    private let store: Store<FavoritesState, FavoritesAction>

    public init(store: Store<FavoritesState, FavoritesAction>) {
        self.store = store
    }

    public var body: some View {
        NavigationView {
            ZStack {
                AssetColor.Background.primary.color.ignoresSafeArea()
                WithViewStore(store) { viewStore in
                    if viewStore.listState.feedItemStates.isEmpty {
                        FavoritesEmptyView()
                    } else {
                        ScrollView {
                            FeedContentListView(
                                store: store.scope(
                                    state: \.listState,
                                    action: FavoritesAction.feedList
                                )
                            )
                        }
                    }
                }
            }
            .navigationBarTitle(L10n.FavoriteScreen.title, displayMode: .large)
            .navigationBarItems(
                trailing: Button(action: {
                    ViewStore(store).send(.showSetting)
                }, label: {
                    AssetImage.iconSetting.image
                        .renderingMode(.template)
                        .foregroundColor(AssetColor.Base.primary.color)
                })
            )
        }
    }
}

#if DEBUG
 public struct FavoritesScreen_Previews: PreviewProvider {
    public static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            FavoritesScreen(
                store: .init(
                    initialState: .init(
                        listState: .init(feedItemStates: .init())
                    ),
                    reducer: .empty,
                    environment: {}
                )
            )
            .previewDevice(.init(rawValue: "iPhone 12"))
            .environment(\.colorScheme, colorScheme)

            FavoritesScreen(
                store: .init(
                    initialState: .init(
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
            .environment(\.colorScheme, colorScheme)
        }
    }
 }
#endif
