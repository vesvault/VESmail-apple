//
//  vmAppDelegate.swift
//  VESmail-apple
//
//  Created by test on 5/14/21.
//

import Foundation
import SwiftUI

//@main
class vmAppDelegate: NSObject, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, willFinishWithLaunchOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("application")
        return true
    }
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        print("forConnecting");
            // Called when a new scene session is being created.
            // Use this method to select a configuration to create the new scene with.
            return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    func application(_ application: UIApplication, didUpdate userActivity: NSUserActivity) {
        print("didUpdate: " + String(userActivity.activityType))
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("active")
    }
    override class func didChangeValue(forKey key: String) {
        print("didChangeValue: " + key)
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("didEnterBackground")
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("willEnterForeground")
    }
    func applicationWillTerminate(_ application: UIApplication) {
        print("terminate")
    }
    override class func performSelector(inBackground aSelector: Selector, with arg: Any?) {
        print("performSelector")
    }
    override func performSelector(inBackground aSelector: Selector, with arg: Any?) {
        print("perform")
    }
  
    /*
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler:@escaping () -> Void) {
    let dateFormatter = DateFormatter()  // format the date for output
    dateFormatter.dateStyle = DateFormatter.Style.medium
    dateFormatter.timeStyle = DateFormatter.Style.long
    let convertedDate = dateFormatter.string(from: Date())
    self.logSB.info("Background URLSession handled at \(convertedDate)")
    self.logSB.info("Background URLSession ID \(identifier)")
    let config = URLSessionConfiguration.background(withIdentifier: "WayneBGconfig")
    let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
    session.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) -> Void in
        // yay! you have your tasks!
        self.logSB.info("Background completion handler here with \(downloadTasks.count) tasks")
        for i in 0...max(0,downloadTasks.count - 1) {
            let description: String = downloadTasks[i].taskDescription!
            self.logSB.info("Task ID \(i) is \(description)")
        }
    }
    backgroundSessionCompletionHandler = completionHandler
    }
*/
}
