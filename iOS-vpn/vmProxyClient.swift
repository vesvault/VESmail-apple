//
//  vmProxyClient.swift
//  VESmail
//
//  Created by test on 8/26/21.
//

import Foundation
import SwiftUI
import NetworkExtension

class vmProxy: ObservableObject {
    var fwatched: Bool = false;
    @Published var users: Array<vmUser> = [];
    @Published var spin: Int8 = 0;
    @Published var errorport: String? = nil;
    @Published var fbkbtn: Bool = false;
    @Published var snifst: Int8 = 0;
    @Published var snifauth: Bool = false;
    var fbk: Bool = false;
    var fbkuser: vmUser? = nil;
    var apns: Data? = nil;

    let vpnId = "com.vesvault.vesmail.vmVPN";
    var conn: NETunnelProviderSession? = nil;
    var connecting: Bool = false;
    var bypass: Bool = false;
    var badct: Int = 0;
 
    func showstat(_ blink: Bool) -> Bool {
        var rs: Bool = false;
        for u in users {
            u.bullet = blink ? u.bullet0 : u.bullet1;
            rs = rs || u.bullet0 != u.bullet1;
        }
        if (users.isEmpty) {
            spin = spin >= 7 ? 0 : spin + 1;
            rs = true;
        }
        return rs;
    }
    
    func watch() {
        _ = query(["req": "watch"]) { rsp in
            if (rsp["reset"] as? Bool ?? false) {
                self.users = [];
            }
            self.snifst = rsp["snifst"] as? Int8 ?? 0;
            self.snifauth = rsp["snifauth"] as? Bool ?? false;
            self.errorport = rsp["errorport"] as? String;
            self.fbkbtn = rsp["fbkbtn"] as? Bool ?? false;
            var uidx = 0;
            for u in rsp["users"] as? [[String : Any]] ?? [] {
                if (uidx >= self.users.count) {
                    self.users.append(vmUser(u["login"] as! String));
                }
                let b = Character(Unicode.Scalar(u["bullet"] as! Int)!);
                self.users[uidx].bullet0 = b;
                self.users[uidx].bullet1 = u["blink"] != nil ? Character(Unicode.Scalar(u["blink"] as! Int)!) : b;
                self.users[uidx].error = u["error"] as? String;
                uidx += 1;
            }
        }
        let blink = showstat(true);
        if (fwatched) {
            if (blink) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.125) {
                    _ = self.showstat(false);
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.250) {
                self.watch();
            }
        }
    }

    func setwatch(_ w: Bool) {
        fwatched = w;
        if (w) {
            watch();
        }
    }

    func awake(_ flg: Bool) {
        print("awake \(flg)")
    }
    
    func openprofile(_ user: vmUser?) {
        var req: [String : Any] = ["req": "open"];
        if (user != nil) {
            var uidx = 0;
            for u in users {
                if (u.user == user?.user) {
                    req["uidx"] = uidx;
                    break;
                }
                uidx += 1;
            }
        }
        _ = query(req) { rsp in
            if let url = rsp["url"] as? String {
                vmApp.openurl(url: url);
            }
        }
    }
    
    func finduser(_ uuid: String) -> vmUser? {
        return nil;
    }
    
    func setapns(_ apns: Data) -> Int32 {
        return query(["req": "apns", "apns": apns.base64EncodedString()]) { rsp in
            NSLog("setapns: \(rsp)");
        } ? 1 : 0;
    }
    
    func newVPN() -> NETunnelProviderManager {
        let manager = NETunnelProviderManager();
        manager.localizedDescription = NSLocalizedString("VESmail SNIF", comment: "SNIF+VESmail");
        let proto = NETunnelProviderProtocol();
        proto.providerBundleIdentifier = vpnId;
        proto.serverAddress = "127.0.0.1:7180";
        proto.providerConfiguration = [:]
        manager.protocolConfiguration = proto
        manager.isEnabled = true
        return manager;
    }
    
    func connectVPN(_ mgr: NETunnelProviderManager) {
        do {
            try mgr.connection.startVPNTunnel();
            conn = mgr.connection as? NETunnelProviderSession;
        } catch {
            print("catch \(error)");
            conn = nil;
        }
    }
    
    func initVPN() {
        connecting = true;
        bypass = false;
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.bypass = true;
        }
        NETunnelProviderManager.loadAllFromPreferences { mgrs, error in
            if (mgrs != nil) {
                if (mgrs!.count > 0) {
                    for idx in 1..<mgrs!.count {
                        mgrs![idx].removeFromPreferences { error in
                        }
                    }
                    self.connectVPN(mgrs![0]);
                } else {
                    let mgr = self.newVPN();
                    mgr.saveToPreferences {
                        error in
                        if (error != nil) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                self.initVPN();
                            }
                            return;
                        }
                        mgr.loadFromPreferences {
                            error in
                            self.connectVPN(mgr);
                        }
                    }
                }
            }
        }
    }
    
    func query(_ req: [String: Any], callback: @escaping (_ rsp: [String: Any]) -> Void) -> Bool {
        switch conn?.status {
        case .connected:
            connecting = false;
            break;
        case .none, .invalid, .disconnected:
            if (!connecting) {
                conn = nil;
                errorport = "VPN";
                snifst = 0;
                for u in users {
                    u.bullet1 = u.bullet0;
                }
                initVPN();
                return false;
            }
            if (bypass) {
                break;
            }
            return false;
        default:
            return false;
        }
        do {
            let enc = try JSONSerialization.data(withJSONObject: req, options: []);
            try conn?.sendProviderMessage(enc) {rsp in
                if (rsp != nil) {
                    self.badct = 0;
                    do {
                        let dec = try JSONSerialization.jsonObject(with: rsp!, options: []) as? [String : Any];
                        if (dec != nil) {
                            callback(dec!);
                        }
                    } catch {
                        print("catch \(error)");
                    }
                } else if (self.connecting) {
                    self.badct += 1;
                    if (self.badct > 40) {
                        self.badct = 0;
                        self.connecting = false;
                    }
                }
            }
            return true;
        } catch {
            NSLog("sendProviderMessage: catch \(error)");
            connecting = false;
            return false;
        }
    }
    
    func errorct() -> Int {
        return 0;
    }

    init() {
        initVPN();
    }
}
