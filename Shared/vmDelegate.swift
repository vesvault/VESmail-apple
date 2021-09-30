//
//  vmSceneDelegate.swift
//  VESmail-apple
//
//  Created by test on 5/15/21.
//

import Foundation
import SwiftUI
import BackgroundTasks

class vmDelegate: UIResponder, UIWindowSceneDelegate, UIApplicationDelegate {
    var window: UIWindow?;
    var fg: Bool = false;
    var bgId: UIBackgroundTaskIdentifier = .invalid;
    var apns: Bool = false;
    let taskId = "com.vesvault.vesmail.Proxy";

/*    func vmBgTask(task: BGAppRefreshTask) {
        print(task)
    }
    
    func vmBgInit() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskId, using: nil) { task in
            self.vmBgTask(task: task as! BGAppRefreshTask)
        }
    }
    
    func vmBgRequest() {
        let req = BGAppRefreshTaskRequest(identifier: taskId);
        req.earliestBeginDate = Date(timeIntervalSinceNow: 0);
        do {
            try BGTaskScheduler.shared.submit(req);
        } catch {
            print("error: \(error)")
        }
    }
    
    func vmBgDump(reqs: [BGTaskRequest]) -> Void {
        print(reqs)
    }

    
    func sceneWillEnterForeground(_ scene: UIScene) {
        print("will enter foreground");
        BGTaskScheduler.shared.getPendingTaskRequests(completionHandler: vmBgDump)
    }
*/

    func vmSleep() -> Void {
        vmApp.proxy.awake(false);
        vmApp.notify.idle();
        vmBackgnd(false);
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        fg = true;
        vmApp.proxy.awake(true);
        vmApp.notify.check();
    }
    func sceneWillResignActive(_ scene: UIScene) {
        fg = false;
        vmBackgnd(true);
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        application.registerForRemoteNotifications();
        return true;
    }
    func application(_ application: UIApplication,
                didRegisterForRemoteNotificationsWithDeviceToken
                    deviceToken: Data) {
        if (vmApp.proxy.setapns(deviceToken) > 0) {
            apns = true;
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                application.registerForRemoteNotifications();
            }
        }
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
            application.registerForRemoteNotifications();
        }

    }
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
            return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if (!fg) {
            vmBackgnd(true);
        }
        vmApp.proxy.awake(true);
        completionHandler(.newData);
    }
        
    func vmBackgnd(_ bg: Bool) {
        if (bgId != .invalid) {
            UIApplication.shared.endBackgroundTask(bgId);
        }
        bgId = bg ? UIApplication.shared.beginBackgroundTask(expirationHandler: vmSleep) : .invalid;
    }

    override init() {
        super.init();
    }
    
}
