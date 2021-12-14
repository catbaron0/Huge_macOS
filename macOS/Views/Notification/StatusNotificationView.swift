//
//  StatusNotificationView.swift
//  GCoresTalk
//
//  Created by catbaron on 2021/12/13.
//

import SwiftUI

struct NotificationCardView: View {
    @StateObject var status: ViewStatus
    let notification:Notification
    @State var listActors = false
    @EnvironmentObject var gtalk: GCoresTalk
    var body: some View {
        VStack {
            Text(notification.desc)
            
            if notification.actors.count > 1 {
                HStack {
                    Spacer()
                    Text("所有参与用户")
                    Spacer()
                }
                .background(.gray)
                .contentShape(Rectangle())
                .onTapGesture {
                    listActors.toggle()
                }
                if listActors {
                    VStack{
                        ForEach(notification.actors) { actor in
                            Text(actor.nickname)
                        }
                    }
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(count: 2) {
            print("double click")
            switch notification.type {
            case .like:
                switch notification.object[0].type {
                case .comments:
                    gtalk.addStatusToCurrentScene(after: status, statusType: .replies, title: "回复", icon: "arrowshape.turn.up.left.circle.fill", targetCommentId: notification.object[0].id)
                case .talks:
                    gtalk.addStatusToCurrentScene(after: status, statusType: .comments, title: "评论", icon: "bubble.right.fill", targetTalkId: notification.object[0].id)
                default:
                    if let url = notification.url {
                        NSWorkspace.shared.open(URL(string: url)!)
                    }
                }
            case .comment:
                // reply to your talk
                if let target = notification.target, target.type == .talks, notification.object[0].type == .comments {
                    gtalk.addStatusToCurrentScene(after: status, statusType: .comments, title: "评论", icon: "bubble.right.fill", targetTalkId: target.id)
                }
            case .reply:
                // reply to your comment
                if let target = notification.target, target.type == .comments, notification.object[0].type == .comments {
                    gtalk.addStatusToCurrentScene(after: status, statusType: .replies, title: "回复", icon: "arrowshape.turn.up.left.circle.fill", targetCommentId: target.id)
                }
            }
        }
        .onTapGesture {
            print("click")
            let idx = status.notifications.firstIndex(of: notification)
            status.notifications[idx!].unRead = false
        }
        
    }
}

struct StatusNotificationView: View {
    @StateObject var status: ViewStatus
    let scrollTopPadding: CGFloat
    let topOffsetTrigger: TopOffsetTrigger
    @State private var offset: CGPoint = .zero
    @EnvironmentObject var gtalk: GCoresTalk
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                List {// ForEach
                    LazyVStack{ // ForEach(cards)
                        // LazyVstack to avoid refresh of cards
                        Text("").padding(.top, scrollTopPadding)
                        ForEach(status.notifications){ card in
                            // We need foreach to avoid reloading images everytime the talkcards appear
                            NotificationCardView(status: status, notification: card)
                            Divider()
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
                                        gtalk.loadNotifications(status: status, earlier: false)
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
                                    gtalk.loadNotifications(status: status, earlier: true)
                                }
                        }
                    }
                }.padding(.bottom)
            }
        }
    }
}