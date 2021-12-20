//
//  NewCommentView.swift
//  GCoresTalk
//
//  Created by catbaron on 2021/12/08.
//

import SwiftUI

struct NewCommentView: View {
    let targetUser: TalkUser?
    let targetTalkId: String
    let targetCommentId: String?
    @ObservedObject var status: ViewStatus
    @ObservedObject var gtalk: GCoresTalk
    @State var comment: String = ""
    @State var checkInfo: String = ""
    let uuid = DateUtils.stampFromDate(date: Date())
    

    var body: some View {
        let sendState = status.requestState
        let opacity = (sendState != nil && sendState! == .sending) ? 0.5 : 1.0
        VStack{
            if let targetCommentId = targetCommentId {
                let replyToUser = status.getUserOfReplyTo(replyToId: targetCommentId)
                HStack{
                    Text("回复").font(.callout)
                    Text("\(replyToUser!.nickname)").foregroundColor(.red).font(.callout.bold())
                        .padding(.top, 3)
                }.padding(.top, 5)
            }
            TextEditor(text: $comment)
                .font(.body)
                .padding([.leading, .trailing])
                
            HStack{
                Spacer()
                if checkInfo != "" {
                    Text(checkInfo)
                }
                if let state = sendState {
                    if state == .sending {
                        HStack {
                            ProgressView().frame(width: 5)
                            Text("正在发送")
                        }
                    } else if state == .failed {
                        Label("发送失败", systemImage: "x.circle.fill").foregroundColor(.red)
                    }

                }
                Button {
                    if comment.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
                        checkInfo = "评论不能为空！"
                        return
                    } else {
                        checkInfo = ""
                    }
                    if sendState == nil || sendState! == .failed {
                        status.requestState = .sending
                        gtalk.sendComment(talkId: targetTalkId, commentId: targetCommentId, status: status, comment: comment)
                    }
                } label: {
                    Label("发送", systemImage: "paperplane.fill").frame(width: 60, height: 30)
                        .background(RoundedRectangle(cornerRadius: CornerRadius).fill(.red))
                }.padding(.trailing, 8).padding(.bottom, 8).buttonStyle(PlainButtonStyle()).opacity(opacity)
                    .disabled(status.requestState != nil && status.requestState! == .sending)

            }
        }
        .preferredColorScheme(.dark)
        .background(BlurView().colorMultiply(.blue.opacity(0.3)))
    }
}
