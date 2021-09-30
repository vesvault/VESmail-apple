//
//  VESmail_appleApp.swift
//  Shared
//
//  Created by test on 5/11/21.
//

import SwiftUI

var vmApp: VESmail_appleApp!;

@main
struct VESmail_appleApp {
    var proxy = vmProxy();
    var notify = vmNotify();
    var appDelegate = vmNSDelegate();
    var ctwin: Int = 0;
    static func main() {
        VESmail_appleApp();
    }
    func window() -> Any? {
        let contentView = vmContentView()
           .environmentObject(vmApp.proxy)
           .onAppear() {
               vmApp.ctwin += 1;
               vmApp.proxy.setwatch(true);
           }
           .onDisappear() {
               if (vmApp.ctwin > 0) {
                   vmApp.ctwin -= 1;
               } else {
                   vmApp.proxy.setwatch(false);
               }
           }

        // Create the window and set the content view.
        let win = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        
        win.title = "Test Application"
        win.isReleasedWhenClosed = false
        win.center()
        win.setFrameAutosaveName("Main Window")
        win.contentView = NSHostingView(rootView: contentView)
        win.makeKeyAndOrderFront(nil)
        return win;
    }
    init() {
        vmApp = self;
        NSApplication.shared.setActivationPolicy(.regular)
        NSApp.delegate = appDelegate
        NSApp.activate(ignoringOtherApps: true)
        NSApp.run()
    }
    func openurl(url: String) {
        let u = URL(string: url);
        NSWorkspace.shared.open(u!);
    }
    func setbadge() {
        var b = proxy.snifauth || proxy.errorport != nil ? 1 : 0;
        for u in proxy.users {
            if (u.error != nil) {
                b += 1;
            }
        }
        NSApp.dockTile.badgeLabel = String(b);
    }
    func vmBackgnd(_ bg: Bool) {
        appDelegate.vmBackgnd(bg);
    }
}


