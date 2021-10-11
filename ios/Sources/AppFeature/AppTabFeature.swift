import Combine
import Component
import Feed
import ComposableArchitecture
import HomeFeature
import MediaFeature
import FavoritesFeature
import SettingFeature
import AboutFeature
import SwiftUI
import Model
import Repository
import TimetableFeature
import Styleguide

public struct AppTabState: Equatable {
    public var feedItemStates: IdentifiedArrayOf<FeedItemState> {
        didSet {
            homeState.feedItemStates = feedItemStates
            mediaState.listState.feedItemStates = feedItemStates
            favoritesState.listState = .init(feedItemStates: feedItemStates.filter(\.feedContent.isFavorited))
        }
    }
    public var homeState: HomeState
    public var timetableState: TimetableState
    public var mediaState: MediaState
    public var favoritesState: FavoritesState
    public var aboutState: AboutState
    public var settingState: SettingState?

    public init(
        feedItemStates: IdentifiedArrayOf<FeedItemState>
    ) {
        self.feedItemStates = feedItemStates
        self.homeState = HomeState(feedItemStates: feedItemStates)
        self.mediaState = MediaState(listState: .init(feedItemStates: feedItemStates))
        self.favoritesState = FavoritesState(
            listState: .init(feedItemStates: feedItemStates.filter(\.feedContent.isFavorited))
        )
        self.aboutState = AboutState()
        self.timetableState = TimetableState()
    }
}

public enum AppTabAction {
    case reload
    case hideSheet
    case answerQuestionnaire
    case home(HomeAction)
    case timetable(TimetableAction)
    case media(MediaAction)
    case favorite(FavoritesAction)
    case about(AboutAction)
    case showSetting
    case setting(SettingAction)
}

public let appTabReducer = Reducer<AppTabState, AppTabAction, AppEnvironment>.combine(
    homeReducer.pullback(
        state: \.homeState,
        action: /AppTabAction.home,
        environment: { environment in
            .init(
                feedRepository: environment.feedRepository,
                player: environment.player
            )
        }
    ),
    timetableReducer.pullback(
        state: \.timetableState,
        action: /AppTabAction.timetable,
        environment: { environment in
            .init(
                timetableRepository: environment.timetableRepository
            )
        }
    ),
    mediaReducer.pullback(
        state: \.mediaState,
        action: /AppTabAction.media,
        environment: { environment in
            .init(
                feedRepository: environment.feedRepository,
                player: environment.player
            )
        }
    ),
    favoritesReducer.pullback(
        state: \.favoritesState,
        action: /AppTabAction.favorite,
        environment: { environment in
            .init(
                feedRepository: environment.feedRepository,
                player: environment.player
            )
        }
    ),
    settingReducer.optional().pullback(
        state: \.settingState,
        action: /AppTabAction.setting,
        environment: { _ in
            .init()
        }
    ),
    aboutReducer.pullback(
        state: \.aboutState,
        action: /AppTabAction.about,
        environment: { environment in
            .init(
                applicationClient: environment.applicationClient,
                contributorRepository: environment.contributorRepository,
                staffRepository: environment.staffRepository
            )
        }
    ),
    .init { state, action, environment in
        switch action {
        case .reload:
            return .none
        case .hideSheet:
            state.settingState = nil
            return .none
        case .answerQuestionnaire:
            return .none
        case .home(.feedItem(id: _, action: .play)),
                .media(.feedList(.feedItem(id: _, action: .play))),
                .favorite(.feedList(.feedItem(id: _, action: .play))):
            if environment.player.isPlaying {
                environment.player.stop()
                if let playingIndex = state.feedItemStates.firstIndex(where: {
                    $0.feedContent.item.wrappedValue.media == .droidKaigiFm(isPlaying: true)
                }) {
                    var feedItemState = state.feedItemStates[playingIndex]
                    feedItemState.feedContent.item.wrappedValue.media = .droidKaigiFm(isPlaying: false)
                    state.feedItemStates.update(feedItemState, at: playingIndex)
                }
            }
            return .none
        case .home(.feedItem(id: let id, action: .favoriteResponse(.success))),
                .media(.feedList(.feedItem(id: let id, action: .favoriteResponse(.success)))),
                .favorite(.feedList(.feedItem(id: let id, action: .favoriteResponse(.success)))):
            if let index = state.feedItemStates.map(\.id).firstIndex(of: id) {
                var feedItemState = state.feedItemStates[index]
                feedItemState.feedContent.isFavorited.toggle()
                state.feedItemStates.update(feedItemState, at: index)
            }
            return .none
        case .home:
            return .none
        case .showSetting, .media(.showSetting), .timetable(.loaded(.showSetting)):
            state.settingState = SettingState()
            return .none
        case .media:
            return .none
        case .favorite:
            return .none
        case .about:
            return .none
        case .timetable:
            return .none
        case .setting:
            return .none
        }
    }
)
