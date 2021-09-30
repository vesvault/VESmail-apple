//
//  vmNotify.swift
//  VESmail-apple
//
//  Created by test on 5/17/21.
//

import Foundation
import NotificationCenter
import UserNotifications

class vmNotify: NSObject {
    let nc = UNUserNotificationCenter.current();
    var idleCont: UNMutableNotificationContent? = nil;
    let idleUUID: UUID = UUID();
    var snifCont: UNMutableNotificationContent? = nil;
    let snifUUID: UUID = UUID();
    let badgeUUID: UUID = UUID();
    let uerror: [String: String] = [
        "XVES-3.7": NSLocalizedString("Bad %s username: %s. Click to find the correct VESmail settings", comment: "XVES-3.7"),
        "XVES-3.4": NSLocalizedString("Bad %s username or password for %s: Click to find the correct VESmail settings.", comment: "XVES-3.4"),
        "XVES-7": NSLocalizedString("%s %s: Click to check the settings and save the profile", comment: "XVES-7"),
        "XVES-16": NSLocalizedString("Bad %s hostname for %s, or a problem with the server. Click to review.", comment: "XVES-16"),
        "XVES-17": NSLocalizedString("Connection problem to %s server for %s. Click to review.", comment: "XVES-17"),
        "XVES-18": NSLocalizedString("TLS error on %s server for %s. Click to review.", comment: "XVES-18"),
        "XVES-19": NSLocalizedString("SASL error for %s server for %s. Click to review.", comment: "XVES-19"),
        "XVES-20": NSLocalizedString("Bad response from %s server for %s. Click to review.", comment: "XVES-20"),
        "XVES-22": NSLocalizedString("VESmail Enterprise server error for %s %s. Contact the enterprise administrator.", comment: "XVES-22"),
        "XVES-31": NSLocalizedString("%s authentication error for %s. Click to review.", comment: "XVES-31"),
        "": NSLocalizedString("%s %s: Click to review the profile", comment: "XVES-UNKNOWN")
    ];
    let ueRemote = NSLocalizedString("Bad settings in the VESmail profile or email server error", comment: "XVES-REMOTE");
    let ueLocal = NSLocalizedString("Bad settings in the local email app", comment: "XVES-LOCAL");
    var delegate: vmNotifyDelegate!;
    
    override init() {
        super.init();
        nc.requestAuthorization(options: [.alert, .badge]) { granted, error in
            if (error != nil) {
                NSLog("requestAuthorization: granted: \(granted), error: \(error!)");
            }
        }
        delegate = vmNotifyDelegate();
        nc.delegate = delegate;
        nc.setNotificationCategories([
            UNNotificationCategory(identifier: "frozen", actions: [
                UNNotificationAction(identifier: "resume", title: "Resume", options: [])
            ], intentIdentifiers: [], options: []),
            UNNotificationCategory(identifier: "remote", actions: [], intentIdentifiers: [], options: []),
            UNNotificationCategory(identifier: "local", actions: [], intentIdentifiers: [], options: [])
        ]);
    }
    
    func logerror(error: Any?) {
        if (error != nil) {
            NSLog("vmNotify: \(error!)");
        }
    }
    
    func idle() {
        check();
    }
    func running() {
        nc.removeDeliveredNotifications(withIdentifiers: [idleUUID.uuidString]);
        nc.removePendingNotificationRequests(withIdentifiers: [idleUUID.uuidString])
    }

    func snifauth(f: Bool) {
        if (f && snifCont == nil) {
            snifCont = UNMutableNotificationContent();
            snifCont?.categoryIdentifier = "snifauth";
            snifCont?.title = "Start using VESmail";
            snifCont?.body = "Click to initialize VESmail App and to set up encryption for your email adderss";
            let req = UNNotificationRequest(identifier: snifUUID.uuidString, content: snifCont!, trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false));
            nc.add(req, withCompletionHandler: { error in
                self.logerror(error: error);
            });
        } else if (snifCont != nil) {
            snifCont = nil;
            nc.removeDeliveredNotifications(withIdentifiers: [snifUUID.uuidString]);
            nc.removePendingNotificationRequests(withIdentifiers: [snifUUID.uuidString])
        }
    }

    func setbadge(_ badge: Int) {
        let cont = UNMutableNotificationContent();
        cont.categoryIdentifier = "badge";
        cont.badge = NSNumber(value: badge);
        cont.summaryArgument = " ";
        let req = UNNotificationRequest(identifier: badgeUUID.uuidString, content: cont, trigger: UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false));
        nc.add(req, withCompletionHandler: { error in
            self.logerror(error: error);
        });
    }

    func check() {
        nc.getDeliveredNotifications(completionHandler: { n in
            for ntfy in n {
                if (ntfy.request.trigger as? UNPushNotificationTrigger) != nil {
                    self.nc.removeDeliveredNotifications(withIdentifiers: [ntfy.request.identifier]);
                }
            }
        })
    }
    
    func user(_ user: vmUser) {
        if (user.error != nil) {
            if (user.errUUID == nil) {
                user.errUUID = UUID();
            }
            let p = user.error?.firstIndex(of: ".");
            var proto: String = "";
            var err: String = user.error!;
            if (p != nil) {
                proto = String(user.error![..<p!]);
                err = String(user.error![user.error!.index(after: p!)...]);
            }
            var e1 = err;
            let p2 = err.firstIndex(of: ".");
            if (p2 != nil) {
                e1 = String(err[..<p2!]);
            }
            var ecode = e1;
            var escope = ueRemote;
            var ecat = "remote";
            switch (e1) {
            case "XVES-3" :
                escope = ueLocal;
                ecode = err;
                ecat = "local";
                break;
            default:
                break;
            }
            var msg: String? = uerror[ecode];
            if (msg == nil) {
                msg = uerror[""];
            }
            msg = msg?.replacingCharacters(in: msg!.range(of: "%s")!, with: proto.uppercased());
            msg = msg?.replacingCharacters(in: msg!.range(of: "%s")!, with: user.login());

            let uCont = UNMutableNotificationContent();
            uCont.categoryIdentifier = ecat;
            uCont.title = escope;
            uCont.body = msg!;
            
            let req = UNNotificationRequest(identifier: user.errUUID!.uuidString, content: uCont, trigger: UNTimeIntervalNotificationTrigger(timeInterval: 0.25, repeats: false));
            nc.add(req, withCompletionHandler: { error in
                self.logerror(error: error);
            });
            
        } else if (user.errUUID != nil) {
            let uids = [user.errUUID!.uuidString];
            nc.removeDeliveredNotifications(withIdentifiers: uids);
            nc.removePendingNotificationRequests(withIdentifiers: uids);
            user.errUUID = nil;
        }
    }
}

class vmNotifyDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let uuid = response.notification.request.identifier;
        let user = vmApp.proxy.finduser(uuid);
        if (user != nil || uuid == vmApp.notify.snifUUID.uuidString) {
            vmApp.proxy.openprofile(user);
        }
        vmApp.vmBackgnd(true);
        completionHandler();
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .banner]);
    }
}
