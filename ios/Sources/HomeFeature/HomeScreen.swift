import Component
import Feed
import ComposableArchitecture
import Model
import Repository
import Styleguide
import SwiftUI

public struct HomeScreen: View {
    private let store: Store<HomeState, HomeAction>

    public init(store: Store<HomeState, HomeAction>) {
        self.store = store
    }

    public var body: some View {
        NavigationView {
            InlineTitleNavigationBarScrollView {
                WithViewStore(store) { viewStore in
                    VStack(alignment: .trailing, spacing: 0) {
                        Spacer(minLength: 16)
                        IfLetStore(
                            store.scope(
                                state: \.topic,
                                action: HomeAction.topic(action:)
                            ),
                            then: LargeCard.init(store:)
                        )
                        Separator()
                        QuestionnaireView(tapAnswerAction: {
                            viewStore.send(.answerQuestionnaire)
                        })
                        Separator()
                        ForEachStore(
                            store.scope(
                                state: \.listFeedItemStates,
                                action: HomeAction.feedItem(id:action:)
                            ),
                            content: ListItem.init(store:)
                        )
                    }
                    .separatorStyle(ThickSeparatorStyle())
                }
            }
            .background(AssetColor.Background.primary.color.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    AssetImage.logoTitle.image
                }
            }
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
public struct HomeScreen_Previews: PreviewProvider {
    public static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
            HomeScreen(
                store: .init(
                    initialState: .init(
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
            .previewDevice(.init(rawValue: "iPhone 12"))
            .environment(\.colorScheme, colorScheme)
        }
    }
}
#endif
