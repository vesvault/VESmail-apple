//
//  VESmail_appleApp.swift
//  Shared
//
//  Created by test on 5/11/21.
//

import SwiftUI

var vmApp: VESmail_appleApp!;

@main
struct VESmail_appleApp: App {
    #if os(iOS)
    @UIApplicationDelegateAdaptor(vmDelegate.self) var appDelegate;
    #elseif os(macOS)
    @NSApplicationDelegateAdaptor(vmNSDelegate.self) var appDelegate;
    #endif
    var proxy = vmProxy();
    var notify = vmNotify();
    var ctwin: Int = 0;
    var lastBadge: Int = -1;
    var body: some Scene {
        WindowGroup {
            vmContentView()
                .environmentObject(proxy)
                .onAppear() {
                    vmApp.ctwin += 1;
                    proxy.setwatch(true);
                }
                .onDisappear() {
                    if (vmApp.ctwin > 0) {
                        vmApp.ctwin -= 1;
                    }
                    if (vmApp.ctwin == 0) {
                        proxy.setwatch(false);
                    }
                }
        }
    }
    init() {
        vmApp = self;
    }
    func window() -> Any? {
        return nil;
    }
    func openurl(url: String) {
        let u = URL(string: url);
        #if os(macOS)
        NSWorkspace.shared.open(u!);
        #else
        UIApplication.shared.open(u!);
        #endif
    }
    mutating func setbadge() {
        let b = proxy.errorct();
        if (b != lastBadge) {
            #if os(iOS)
            UIApplication.shared.applicationIconBadgeNumber = b;
            #elseif os(macOS)
            NSApp.dockTile.badgeLabel = b > 0 ? String(b) : nil;
            #endif
            lastBadge = b;
        }
    }
    func vmBackgnd(_ bg: Bool) {
        appDelegate.vmBackgnd(bg);
    }
 }
