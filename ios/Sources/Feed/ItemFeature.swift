import Component
import ComposableArchitecture
import Model
import Foundation
import Player
import Repository

public struct FeedItemState: Equatable, Identifiable {
    public var feedContent: FeedContent
    public var webViewState: WebViewState?

    public var id: FeedContent.ID {
        feedContent.id
    }

    public init(feedContent: FeedContent) {
        self.feedContent = feedContent
    }
}

public enum FeedItemAction {
    case select
    case favorite
    case favoriteResponse(Result<FeedContent.ID, KotlinError>)
    case play
    case played
    case stoped
    case hideSheet
}

public struct FeedItemEnvironment {
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

public let feedItemReducer = Reducer<FeedItemState, FeedItemAction, FeedItemEnvironment> { state, action, environment in
    switch action {
    case .select:
        state.webViewState = URL(string: state.feedContent.item.link).map(WebViewState.init(url:))
        return .none
    case .favorite:
        let id = state.id
        let publisher = state.feedContent.isFavorited
            ? environment.feedRepository.removeFavorite(id: id)
            : environment.feedRepository.addFavorite(id: id)
        return publisher
            .map { id }
            .receive(on: DispatchQueue.main)
            .catchToEffect()
            .map(FeedItemAction.favoriteResponse)
    case .favoriteResponse(.success):
        state.feedContent.isFavorited.toggle()
        return .none
    case .favoriteResponse(.failure):
        return .none
    case .play:
        if let podcast = state.feedContent.item.wrappedValue as? Podcast {
            if environment.player.isPlaying && podcast.media == .droidKaigiFm(isPlaying: true) {
                environment.player.stop()
                return .init(value: .stoped)
            } else {
                environment.player.setUpPlayer(url: URL(string: podcast.podcastLink)!)
                return .init(value: .played)
            }
        }
        return .none
    case .played:
        state.feedContent.item.wrappedValue.media = .droidKaigiFm(isPlaying: true)
        return .none
    case .stoped:
        state.feedContent.item.wrappedValue.media = .droidKaigiFm(isPlaying: false)
        return .none
    case .hideSheet:
        state.webViewState = nil
        return .none
    }
}
