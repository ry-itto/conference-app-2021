import Component
import ComposableArchitecture
import Model
import Styleguide
import SwiftUI

struct MediaListView: View {

    private let store: Store<MediaState, MediaAction>
    @ObservedObject private var viewStore: ViewStore<ViewState, Never>

    init(store: Store<MediaState, MediaAction>) {
        self.store = store
        self.viewStore = .init(
            store.scope(state: ViewState.init(state:)).actionless
        )
    }

    struct ViewState: Equatable {
        var hasBlogs: Bool
        var hasVideos: Bool
        var hasPodcasts: Bool

        init(state: MediaState) {
            hasBlogs = !state.blogs.isEmpty
            hasVideos = !state.videos.isEmpty
            hasPodcasts = !state.podcasts.isEmpty
        }
    }

    var body: some View {
        ScrollView {
            if viewStore.hasBlogs {
                MediaSectionView(
                    type: .blog,
                    store: store.scope(
                        state: { .init(feedItemStates: $0.blogs) },
                        action: { .init(action: $0) }
                    )
                )
                separator
            }
            if viewStore.hasVideos {
                MediaSectionView(
                    type: .video,
                    store: store.scope(
                        state: { .init(feedItemStates: $0.videos) },
                        action: { .init(action: $0) }
                    )
                )
                separator
            }
            if viewStore.hasPodcasts {
                MediaSectionView(
                    type: .podcast,
                    store: store.scope(
                        state: { .init(feedItemStates: $0.podcasts) },
                        action: { .init(action: $0) }
                    )
                )
            }
        }
        .separatorStyle(ThickSeparatorStyle())
    }

    private var separator: some View {
        Separator()
            .padding()
    }
}

private extension MediaAction {
    init(action: MediaSectionView.ViewAction) {
        switch action {
        case let .showMore(type):
            self = .showMore(for: type)
        case .feedItem(let id, let action):
            self = .feedList(.feedItem(id: id, action: action))
        }
    }
}

#if DEBUG
public struct MediaListView_Previews: PreviewProvider {
    public static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            MediaListView(
                store: .init(
                    initialState: .init(
                        listState: .init(
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
                        )
                    ),
                    reducer: .empty,
                    environment: {}
                )
            )
            .background(AssetColor.Background.primary.color.ignoresSafeArea())
            .environment(\.colorScheme, colorScheme)
        }
        .accentColor(AssetColor.primary.color)
    }
}
#endif
