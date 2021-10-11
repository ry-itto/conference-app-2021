import AboutFeature
import ComposableArchitecture
import FavoritesFeature
import HomeFeature
import MediaFeature
import Styleguide
import SwiftUI
import TimetableFeature

enum AppTab: CaseIterable {
    case home
    case timetable
    case media
    case favorites
    case about

    @ViewBuilder
    func view(_ store: Store<AppTabState, AppTabAction>) -> some View {
        switch self {
        case .home:
            HomeScreen(
                store: store.scope(
                    state: \.homeState,
                    action: AppTabAction.home
                )
            )
        case .timetable:
            TimetableScreen(
                store: store.scope(
                    state: \.timetableState,
                    action: AppTabAction.timetable
                )
            )
        case .media:
            MediaScreen(
                store: store.scope(
                    state: \.mediaState,
                    action: AppTabAction.media
                )
            )
        case .favorites:
            FavoritesScreen(
                store: store.scope(
                    state: \.favoritesState,
                    action: AppTabAction.favorite
                )
            )
        case .about:
            AboutScreen(
                store: store.scope(
                    state: \.aboutState,
                    action: AppTabAction.about
                )
            )
        }
    }
}
