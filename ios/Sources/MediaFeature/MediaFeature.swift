import Component
import ComposableArchitecture
import Feed
import Model
import Player
import Repository
import Styleguide

public struct MediaState: Equatable {
    // In order not to use any networks for searching feature,
    // `feedContents` is storage to search from & `searchedFeedContents` is searched result from `feedContents`
    public var listState: FeedContentListState
    public var searchedFeedListState: FeedContentListState?

    var searchText: String
    var isSearchTextEditing: Bool
    var moreActiveType: MediaType?
    var detailState: MediaDetailState?

    public init(
        listState: FeedContentListState,
        searchText: String = "",
        isSearchTextEditing: Bool = false,
        moreActiveType: MediaType? = nil
    ) {
        self.listState = listState
        self.searchText = searchText
        self.isSearchTextEditing = isSearchTextEditing
        self.moreActiveType = moreActiveType
    }
}

// Only use to scope `Store`
extension MediaState {
    var blogs: IdentifiedArrayOf<FeedItemState> {
        listState.feedItemStates.filter { $0.feedContent.item.wrappedValue is Blog }
    }

    var videos: IdentifiedArrayOf<FeedItemState> {
        listState.feedItemStates.filter { $0.feedContent.item.wrappedValue is Video }
    }

    var podcasts: IdentifiedArrayOf<FeedItemState> {
        listState.feedItemStates.filter { $0.feedContent.item.wrappedValue is Podcast }
    }
}

public enum MediaAction {
    case searchTextDidChange(to: String?)
    case isEditingDidChange(to: Bool)
    case showMore(for: MediaType)
    case moreDismissed
    case showSetting
    case feedList(FeedContentListAction)
    case detail(FeedContentListAction)
}

public struct MediaEnvironment {
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

public let mediaReducer = Reducer<MediaState, MediaAction, MediaEnvironment>.combine(
    feedContentListReducer.pullback(
        state: \.listState,
        action: /MediaAction.feedList,
        environment: { environment in
            .init(
                feedRepository: environment.feedRepository,
                player: environment.player
            )
        }
    ),
    feedContentListReducer.pullback(
        state: \.listState,
        action: /MediaAction.feedList,
        environment: { environment in
            .init(
                feedRepository: environment.feedRepository,
                player: environment.player
            )
        }
    ),
    mediaDetailReducer.optional().pullback(
        state: \.detailState,
        action: /MediaAction.detail,
        environment: { _ in }
    ),
    .init { state, action, _ in
        switch action {
        case let .searchTextDidChange(to: searchText):
            state.searchText = searchText ?? ""
            let containsInSearchText = { (text: String) -> Bool in
                text.contains(searchText?.filterForSeaching ?? "")
            }
            let searchedItemStates = state.listState.feedItemStates
                .filter { state in
                    containsInSearchText(state.feedContent.item.title.jaTitle.filterForSeaching)
                    || containsInSearchText(state.feedContent.item.title.enTitle.filterForSeaching)
                }
            state.searchedFeedListState = .init(
                feedItemStates: searchedItemStates
            )
            return .none
        case let .isEditingDidChange(isEditing):
            state.isSearchTextEditing = isEditing
            if !isEditing {
                state.searchedFeedListState = nil
            }
            return .none
        case let .showMore(mediaType):
            state.moreActiveType = mediaType
            var title: String
            var listState: IdentifiedArrayOf<FeedItemState>
            switch mediaType {
            case .blog:
                title = L10n.MediaScreen.Section.Blog.title
                listState = state.blogs
            case .podcast:
                title = L10n.MediaScreen.Section.Podcast.title
                listState = state.podcasts
            case .video:
                title = L10n.MediaScreen.Section.Video.title
                listState = state.videos
            }
            state.detailState = .init(
                title: title,
                listState: FeedContentListState(feedItemStates: listState)
            )
            return .none
        case .moreDismissed:
            state.moreActiveType = nil
            return .none
        case .showSetting:
            return .none
        case .feedList:
            return .none
        case .detail:
            return .none
        }
    }
)

private extension String {
    var filterForSeaching: Self {
        self.replacingOccurrences(of: " ", with: "")
            .trimmingCharacters(in: .whitespaces)
            .lowercased()
    }
}
