//
//  StatusTalksTimelineView.swift
//  GCoresTalk
//
//  Created by catbaron on 2021/12/02.
//
import SwiftUI

struct StatusTalksTimelineView: View {
    let _status: ViewStatus
    let headerView: HeaderView?
    let topOffsetTrigger: TopOffsetTrigger
    @State private var offset: CGPoint = .zero
    @EnvironmentObject var gtalk: GCoresTalk
    
    var body: some View {
        let sceneType = _status.sceneType
//        let idx = gtalk.indexOf(status: _status)
        if let idx = gtalk.indexOf(status: _status) {
            let status = gtalk.statusForScene[sceneType]![idx]
//                    let status = (idx == nil) ? _status : gtalk.statusForScene[sceneType]![idx!]
            GeometryReader { proxy in
                VStack {
                    List {// ForEach
                        LazyVStack{ // ForEach(cards)
                            // LazyVstack to avoid refresh of cards
                            if let headerView = headerView {
                                headerView
                            }
                            ForEach(status.talks){ card in
                                // We need foreach to avoid reloading images everytime the talkcards appear
                                TalkCardView(_status: status, card: card, isSelected: card.id == status.targetTalk?.id)
                                    .onTapGesture(count: 2) {
                                        gtalk.addStatusToCurrentScene(after: status, statusType: .comments, title: "评论", icon: "bubble.right.fill", targetTalk: card)
                                    }
                            }
                            if status.loadingEarlier == .empty {
                                Text("这就是一切了。").padding()
                            }
                            
                        }.readingScrollView(from: "scroll", into: $offset)
                    }.coordinateSpace(name: "scroll")
                        .overlay(alignment: .top) {
                            VStack { // LoadingBar
                                switch status.loadingLatest {
                                case .loading:
                                    ProgressView()
                                case .loaded:
                                    if offset.x > CGFloat(topOffsetTrigger.rawValue) {
                                        Divider()
                                            .contentShape(Rectangle())
                                            .onAppear {
                                                gtalk.readTimeline(status: status, earlier: false)
                                            }
                                    }
                                default:
                                    EmptyView()
                                }
                            }
                            
                        }
                    VStack { // LoadingBar
                        switch status.loadingEarlier {
                        case .loading:
                            ProgressView()
                        case .loaded, .empty:
                            if proxy.size.height - offset.y > -20 {
                                Divider()
                                    .contentShape(Rectangle())
                                    .onAppear {
                                        let off = proxy.size.height - offset.y
                                        gtalk.readTimeline(status: status, earlier: true)
                                        print("off: \(off)")
                                    }
                            }
                        }
                    }.padding(.bottom)
                }
            }
        }
    }
}
