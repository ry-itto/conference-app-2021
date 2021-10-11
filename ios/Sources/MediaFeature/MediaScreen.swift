import Component
import ComposableArchitecture
import Feed
import Introspect
import Model
import SwiftUI
import Styleguide

public struct MediaScreen: View {
    private let store: Store<MediaState, MediaAction>
//    @ObservedObject private var viewStore: ViewStore<ViewState, MediaAction>
    @SearchController private var searchController: UISearchController

    public init(store: Store<MediaState, MediaAction>) {
        self.store = store
        let viewStore = ViewStore(store)
//        self.viewStore = viewStore
        self._searchController = .init(
            searchBarPlaceHolder: L10n.MediaScreen.SearchBar.placeholder,
            searchTextDidChangeTo: { text in
                withAnimation(.easeInOut) {
                    viewStore.send(.searchTextDidChange(to: text))
                }
            },
            isEditingDidChangeTo: { isEditing in
                withAnimation(.easeInOut) {
                    viewStore.send(.isEditingDidChange(to: isEditing))
                }
            }
        )
    }

    struct ViewState: Equatable {
        var isMoreActive: Bool

        init(state: MediaState) {
            isMoreActive = state.moreActiveType != nil
        }
    }

    public var body: some View {
        WithViewStore(store.scope(state: ViewState.init(state:))) { viewStore in
            NavigationView {
                ZStack {
                    AssetColor.Background.primary.color.ignoresSafeArea()
                        .zIndex(0)

                    MediaListView(store: store)
                        .zIndex(1)

//                    Color.black.opacity(0.4)
//                        .ignoresSafeArea()
//                        .opacity(viewStore.isSearchTextEditing ? 1 : .zero)
//                        .zIndex(2)

                    IfLetStore(
                        store.scope(
                            state: \.searchedFeedListState,
                            action: MediaAction.feedList
                        ),
                        then: SearchResultScreen.init(store:)
                    )
                    .zIndex(3)
                }
                .background(
                    NavigationLink(
                        destination: IfLetStore(
                            store.scope(
                                state: \.detailState,
                                action: MediaAction.feedList
                            ),
                            then: MediaDetailScreen.init(store:)
                        ),
                        isActive: viewStore.binding(
                            get: \.isMoreActive,
                            send: { _ in .moreDismissed }
                        )
                    ) {
                        EmptyView()
                    }
                )
                .navigationTitle(L10n.MediaScreen.title)
                .navigationBarItems(
                    trailing: Button(action: {
                        viewStore.send(.showSetting)
                    }, label: {
                        AssetImage.iconSetting.image
                            .renderingMode(.template)
                            .foregroundColor(AssetColor.Base.primary.color)
                    })
                )
                .introspectViewController { viewController in
                    guard viewController.navigationItem.searchController == nil else { return }
                    viewController.navigationItem.searchController = searchController
                    viewController.navigationItem.hidesSearchBarWhenScrolling = false
                    // To keep the navigation bar expanded
                    viewController.navigationController?.navigationBar.sizeToFit()
                }
            }
        }
    }

    private var separator: some View {
        Separator()
            .padding()
    }
}

#if DEBUG
public struct MediaScreen_Previews: PreviewProvider {
    public static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            Group {
                MediaScreen(
                    store: .init(
                        initialState: .init(
                            listState: .init(
                                feedItemStates: .init(
                                    uniqueElements: [
                                        .init(feedContent: .blogMock()),
                                        .init(feedContent: .blogMock()),
                                        .init(feedContent: .blogMock()),
                                        .init(feedContent: .videoMock()),
                                        .init(feedContent: .videoMock()),
                                        .init(feedContent: .videoMock()),
                                        .init(feedContent: .podcastMock()),
                                        .init(feedContent: .podcastMock()),
                                        .init(feedContent: .podcastMock()),
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

                MediaScreen(
                    store: .init(
                        initialState: .init(
                            listState: .init(
                                feedItemStates: [
                                    .init(feedContent: .blogMock(title: "ForSearch")),
                                    .init(feedContent: .blogMock(title: "ForSearch")),
                                    .init(feedContent: .blogMock(title: "ForSearch")),
                                    .init(feedContent: .videoMock(title: "ForSearch")),
                                    .init(feedContent: .videoMock(title: "ForSearch")),
                                    .init(feedContent: .videoMock()),
                                    .init(feedContent: .podcastMock()),
                                    .init(feedContent: .podcastMock()),
                                    .init(feedContent: .podcastMock()),
                                ]
                            ),
                            searchText: "Search",
                            isSearchTextEditing: true
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
}
#endif
