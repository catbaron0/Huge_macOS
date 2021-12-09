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
    let _status: TalkStatus
    @ObservedObject var gtalk: GCoresTalk
    @State var sending = false
    @State var comment: String = ""
    @State var checkInfo: String = ""
    let uuid = UUID().uuidString
    var body: some View {
        let sendState = gtalk.requestStates[uuid]
        let opacity = (sendState != nil && sendState! == .sending) ? 0.5 : 1.0
        VStack{
            TextEditor(text: $comment)
                .font(.title3)
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
                        gtalk.sendComment(talkId: targetTalkId, commentId: targetCommentId, _status: _status, comment: comment, uuid: uuid)
                    }
                } label: {
                    Label("发送", systemImage: "paperplane.fill").frame(width: 60, height: 30)
                        .background(RoundedRectangle(cornerRadius: 5).fill(.blue))

                }.padding(.trailing, 8).padding(.bottom, 8).buttonStyle(PlainButtonStyle()).opacity(opacity)
            }
        }.onDisappear {
            gtalk.requestStates.removeValue(forKey: uuid)
        }
//

        
        
    }
}
//
//struct NewCommentView_Previews: PreviewProvider {
//    static var previews: some View {
//        NewCommentView()
//    }
//}
//Label("发送", systemImage: "paperplane.fill")
//    .padding(5)
//    .background(RoundedRectangle(cornerRadius: 5).fill(.blue))
//    .onTapGesture {
//        gtalk.sendComment(talkId: targetTalkId, commentId: targetCommentId, _status: _status, comment: comment)
//    }
//    .padding(.trailing).padding(.bottom)