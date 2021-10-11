import Component
import ComposableArchitecture
import Model
import SwiftUI
import Styleguide

public struct LargeCard: View {
    enum Const {
        static let margin: CGFloat = 16
        static let cardWidth = UIScreen.main.bounds.width
        static let imageViewWidth = Const.cardWidth - (Const.margin * 2) - (ImageView.Const.roundedLineWidth * 2)
    }
    
    struct State: Equatable {
        var title: String
        var imageURL: URL?
        var media: Media
        var date: Date
        var isFavorited: Bool
        var isShowingSheet: Bool
        
        init(state: FeedItemState) {
            title = state.feedContent.item.title.get(by: Foundation.Locale.current.language)
            imageURL = URL(string: state.feedContent.item.image.largeURLString)
            media = state.feedContent.item.media
            date = state.feedContent.item.publishedAt
            isFavorited = state.feedContent.isFavorited
            isShowingSheet = state.webViewState != nil
        }
    }

    private let store: Store<FeedItemState, FeedItemAction>

    public init(store: Store<FeedItemState, FeedItemAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store.scope(state: State.init(state:))) { viewStore in
            VStack(alignment: .leading, spacing: 16) {
                ZStack {
                    ImageView(
                        imageURL: viewStore.imageURL,
                        placeholder: .noImage,
                        placeholderSize: .large,
                        width: Const.imageViewWidth,
                        height: Const.imageViewWidth * 190/343,
                        allowsHitTesting: !viewStore.media.isPodcast
                    )
                    if case let .droidKaigiFm(isPlaying) = viewStore.media {
                        SwiftUI.Image(
                            systemName: isPlaying ? "stop.fill" : "play.fill"
                        )
                        .foregroundColor(Color.white)
                        .padding()
                        .background(Color.black.opacity(0.4))
                        .clipShape(Circle())
                        .onTapGesture {
                            viewStore.send(.play)
                        }
                    }
                }
                Group {
                    Text(viewStore.title)
                        .font(.headline)
                        .foregroundColor(AssetColor.Base.primary.color)
                        .lineLimit(2)

                    Spacer(minLength: 13)

                    HStack(spacing: 8) {
                        Tag(media: viewStore.media)

                        Text(viewStore.date.formatted)
                            .font(.caption)
                            .foregroundColor(AssetColor.Base.tertiary.color)
                        Spacer()
                        Button(action: {
                            viewStore.send(.favorite)
                        }, label: {
                            let image = viewStore.isFavorited ? AssetImage.iconFavorite.image : AssetImage.iconFavoriteOff.image
                            image
                                .renderingMode(.template)
                                .foregroundColor(AssetColor.primary.color)
                        })
                    }
                }
            }
            .background(Color.clear)
            .onTapGesture {
                viewStore.send(.select)
            }
            .padding(Const.margin)
            .sheet(
                isPresented: viewStore.binding(
                    get: \.isShowingSheet,
                    send: .hideSheet
                ), content: {
                    IfLetStore(
                        store.scope(state: \.webViewState).actionless,
                        then: WebView.init(store:)
                    )
                }
            )
        }
    }
}

#if DEBUG
public struct LargeCard_Previews: PreviewProvider {
    public static var previews: some View {
        Group {
            ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
                LargeCard(
                    store: .init(
                        initialState: .init(
                            feedContent: .podcastMock(
                                title: "タイトルタイトルタイトルタイトルタイタイトルタイトルタイトルタイトルタイト...",
                                isFavorited: false
                            )
                        ),
                        reducer: .empty,
                        environment: {}
                    )
                )
                .frame(width: 375, height: 319)
                .background(AssetColor.Background.primary.color)
                .previewDevice(.init(rawValue: "iPhone X"))
                .environment(\.colorScheme, colorScheme)

                LargeCard(
                    store: .init(
                        initialState: .init(
                            feedContent: .blogMock(
                                title: "タイトルタイトルタイトルタイトルタイタイトルタイトルタイトルタイトルタイト...",
                                isFavorited: true
                            )
                        ),
                        reducer: .empty,
                        environment: {}
                    )
                )
                .frame(width: 375, height: 319)
                .background(AssetColor.Background.primary.color)
                .previewDevice(.init(rawValue: "iPhone X"))
                .environment(\.colorScheme, colorScheme)

                LargeCard(
                    store: .init(
                        initialState: .init(
                            feedContent: .videoMock(
                                title: "タイトル",
                                isFavorited: true
                            )
                        ),
                        reducer: .empty,
                        environment: {}
                    )
                )
                .frame(width: 375, height: 319)
                .background(AssetColor.Background.primary.color)
                .previewDevice(.init(rawValue: "iPhone X"))
                .environment(\.colorScheme, colorScheme)
            }
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
