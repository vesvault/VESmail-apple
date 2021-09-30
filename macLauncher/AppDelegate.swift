//
//  AppDelegate.swift
//  macLauncher
//
//  Created by test on 8/23/21.
//

import Cocoa
import SwiftUI

extension Notification.Name {
    static let killLauncher = Notification.Name("killLauncher")
}

@NSApplicationMain
class AppDelegate: NSObject {
    let appId = "com.vesvault.vesmail";
    let appName = "VESmail";
    @objc func terminate() {
        NSApp.terminate(nil)
    }
}

extension AppDelegate: NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = !runningApps.filter { $0.bundleIdentifier == appId }.isEmpty
        if !isRunning {
            DistributedNotificationCenter.default().addObserver(self, selector: #selector(self.terminate), name: .killLauncher, object: appId)
            let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: appId)
            let conf = NSWorkspace.OpenConfiguration();
            conf.hides = true;
            NSWorkspace.shared.openApplication(at: url!, configuration: conf, completionHandler: nil)
        }
        else {
            self.terminate()
        }
    }
}
