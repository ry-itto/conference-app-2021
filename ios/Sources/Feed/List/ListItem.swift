import Component
import ComposableArchitecture
import Model
import Styleguide
import SwiftUI

public struct ListItem: View {
    private struct Const {
        static let maximumShowingSpeaker = 7
    }
    
    struct State: Equatable {
        var title: String
        var imageURL: URL?
        var media: Media
        var date: Date
        var isFavorited: Bool
        var speakers: [Speaker]
        var isShowingSheet: Bool
        
        init(state: FeedItemState) {
            title = state.feedContent.item.title.get(by: Foundation.Locale.current.language)
            imageURL = URL(string: state.feedContent.item.image.smallURLString)
            media = state.feedContent.item.media
            date = state.feedContent.item.publishedAt
            isFavorited = state.feedContent.isFavorited
            speakers = (state.feedContent.item.wrappedValue as? Podcast)?.speakers ?? []
            isShowingSheet = state.webViewState != nil
        }
    }
    
    private let store: Store<FeedItemState, FeedItemAction>

    public init(store: Store<FeedItemState, FeedItemAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store.scope(state: State.init(state:))) { viewStore in
            VStack(alignment: .leading) {
                Tag(media: viewStore.media)

                HStack(alignment: .top) {
                    VStack(spacing: 8) {
                        ZStack {
                            ImageView(
                                imageURL: viewStore.imageURL,
                                placeholderSize: .small,
                                width: 100,
                                height: 100,
                                allowsHitTesting: !viewStore.media.isPodcast
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 20))
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
                    }
                    VStack(alignment: .leading) {
                        Text(viewStore.title)
                            .font(.headline)
                            .foregroundColor(AssetColor.Base.primary.color)
                            .lineLimit(viewStore.speakers.isEmpty ? 3 : 2)
                        Spacer(minLength: 8)
                        if !viewStore.speakers.isEmpty {
                            HStack(spacing: -4) {
                                ForEach(Array(viewStore.speakers.enumerated()), id: \.0) { (index, speaker) in
                                    if index > Const.maximumShowingSpeaker {
                                        EmptyView()
                                    } else {
                                        AvatarView(avatarImageURL: URL(string: speaker.iconURLString), style: .small)
                                            .zIndex(Double(Const.maximumShowingSpeaker - index))
                                    }
                                }
                                if viewStore.speakers.count > Const.maximumShowingSpeaker {
                                    Text("+\(viewStore.speakers.count - Const.maximumShowingSpeaker)")
                                        .font(.caption)
                                        .padding(4)
                                        .background(AssetColor.Background.contents.color)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(AssetColor.Separate.image.color, lineWidth: 1)
                                        )
                                        .zIndex(Double(-Const.maximumShowingSpeaker))
                                }
                            }
                            .frame(width: nil, height: 24)
                        }
                        HStack {
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
            }
            .padding(16)
            .onTapGesture {
                viewStore.send(.select)
            }
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
public struct ListItem_Previews: PreviewProvider {
    public static var previews: some View {
        Group {
            ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
                ListItem(
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
                .frame(width: 343, height: 132)
                .environment(\.colorScheme, colorScheme)
                ListItem(
                    store: .init(
                        initialState: .init(
                            feedContent: .podcastMock(
                                title: "タイトルタイトルタイトルタイトルタイタイトルタイトルタイトルタイトルタイト...",
                                speakers: Array(repeating: .mock(), count: 8),
                                isFavorited: false
                            )
                        ),
                        reducer: .empty,
                        environment: {}
                    )
                )
                .frame(width: 343, height: 132)
                .background(AssetColor.Background.primary.color)
                .environment(\.colorScheme, colorScheme)
            }
        }
    }
}
#endif
