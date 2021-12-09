//
//  NSWindow.swift
//  GCoresTalk
//
//  Created by catbaron on 2021/12/08.
//

import SwiftUI

func newWindowForImageSlides(with images: [TalkImage])
{
    @State var winRef: NSWindow
    @State var winCtrl: NSWindowController
    
    winRef = NSWindow(
        contentRect: NSRect(x: 100, y: 100, width: 800, height: 600),
        styleMask: [.titled, .closable, .fullSizeContentView, .miniaturizable, .resizable],
        backing: .buffered, defer: false)
    winRef.center()
    winRef.isOpaque = false
    winRef.contentView = NSHostingView(rootView: ImageSlidesView(images: images, window: winRef))
//    winRef.setContentSize(view.geo)
    winRef.titlebarAppearsTransparent = true
    winRef.makeKeyAndOrderFront(nil)
    winRef.isMovableByWindowBackground = true
    
    winCtrl = NSWindowController(window: winRef)
}


func newWindowForComment(view: NewCommentView)
{
    @State var winRef: NSWindow
    @State var winCtrl: NSWindowController

    winRef = NSWindow(
        contentRect: NSRect(x: 100, y: 100, width: 300, height: 200),
        styleMask: [.titled, .closable, .fullSizeContentView, .miniaturizable, .resizable],
        backing: .buffered, defer: false)
    winRef.center()
    winRef.isOpaque = false
    winRef.contentView = NSHostingView(rootView: view)
//    winRef.setContentSize(view.geo)
    winRef.titlebarAppearsTransparent = true
    winRef.makeKeyAndOrderFront(nil)
    winRef.isMovableByWindowBackground = true

    winCtrl = NSWindowController(window: winRef)
}
