//
//  vmNSDelegate.swift
//  VESmail-apple (macOS)
//
//  Created by test on 5/19/21.
//

import Foundation
import SwiftUI
import BackgroundTasks
import ServiceManagement

extension Notification.Name {
    static let killLauncher = Notification.Name("killLauncher")
}

class vmNSDelegate: NSResponder, NSApplicationDelegate {
    var window: NSWindow!;
    let launcherId = "com.vesvault.vesmail.macLauncher";
/*
    func applicationDidHide(_ notification: Notification) {
        print("hide")
    }
    
    func applicationDidUnhide(_ notification: Notification) {
        print("unhide")
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        print("active");
//        NSApplication.shared.mainWindow?.styleMask.insert([.resizable]);
        print(NSApplication.shared.mainWindow)
    }
*/
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSWindow.allowsAutomaticWindowTabbing = false;
        if (window == nil) {
            window = vmApp.window() as? NSWindow;
        }
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = !runningApps.filter { $0.bundleIdentifier == launcherId }.isEmpty
        SMLoginItemSetEnabled(launcherId as CFString, true);

        if isRunning {
            DistributedNotificationCenter.default().post(name: .killLauncher, object: Bundle.main.bundleIdentifier!)
        }

        NSWorkspace.shared.notificationCenter.addObserver(
            self, selector: #selector(onWakeNote(note:)),
            name: NSWorkspace.didWakeNotification, object: nil)

        NSWorkspace.shared.notificationCenter.addObserver(
            self, selector: #selector(onSleepNote(note:)),
            name: NSWorkspace.willSleepNotification, object: nil)
    }
    
    func vmBackgnd(_ bg: Bool) {
    }
    
    @objc func onWakeNote(note: NSNotification) {
        vmApp.proxy.awake(true);
    }

    @objc func onSleepNote(note: NSNotification) {
        vmApp.proxy.awake(false);
    }
    
}
