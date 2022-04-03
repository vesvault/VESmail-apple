//
//  vmProxy.swift
//  VESmail-apple
//
//  Created by test on 5/13/21.
//

import Foundation
import SwiftUI
#if os(macOS)
    #if arch(arm64)
import libvesmail_macos_arm64
    #elseif arch(x86_64)
import libvesmail_macos_x86_64
    #endif
#elseif os(iOS)
    #if targetEnvironment(simulator)
import libvesmail_ioss_arm64
    #else
import libvesmail_ios_arm64
    #endif
#endif

class vmProxy: ObservableObject {
    var fwatched: Bool = false;
    var fbusy: Bool = false;
    var idlect: Int8 = 0;
    @Published var users: Array<vmUser> = [];
    @Published var spin: Int8 = 0;
    @Published var errorport: String? = nil;
    @Published var fbkbtn: Bool = false;
    @Published var snifst: Int8 = 0;
    @Published var snifauth: Bool = false;
    var daemons: Array<UnsafeMutablePointer<VESmail_daemon>> = [];
    var daemonidx: Array<Int32> = [];
    var fbk: Bool = false;
    var fbkuser: vmUser? = nil;
    var apns: Data? = nil;
    var blink: Bool = false;
    var snifsrv: OpaquePointer;
    
    init() {
        let s =  Bundle.main.path(forResource: "curl-ca-bundle", ofType: "crt");
        VESmail_local_caBundle(s);
        VESmail_local_init(nil);
        VESmail_local_start();
        #if os(macOS)
        let dir = NSHomeDirectory() + "/.vesmail";
        mkdir(dir, 0x1c0);
        #else
        let dir = NSHomeDirectory() + "/Library/Caches";
        #endif
        let dfl = UserDefaults.standard;
        var pass: String? = dfl.string(forKey: "seed");
        if (pass == nil) {
            pass = "";
            var i: Int = 0;
            while (i < 32) {
                pass! += String(UnicodeScalar(Int.random(in: 32...126))!);
                i += 1;
            }
            dfl.setValue(pass, forKey: "seed");
        }
        snifsrv = VESmail_local_snif(dir + "/snif.crt", dir + "/snif.pem", pass, nil);
        let dp:UnsafeMutablePointer<UnsafeMutablePointer<VESmail_daemon>?> = VESmail_local_daemons!;
        var i: Int = 0;
        while (dp[i] != nil) {
            let type = String(cString: dp[i]![0].type);
            if (type == "now") {
                i += 1;
                continue;
            }
            var j: Int = 0;
            while (true) {
                if (j >= daemons.count) {
                    daemons.append(dp[i]!);
                    daemonidx.append(Int32(i));
                    break;
                } else if (type == String(cString: daemons[j][0].type)) {
                    break;
                }
                j += 1;
            }
            i += 1;
        }
    }
    
    func openprofile(_ user: vmUser?) {
        var url: String? = nil;
        if (user != nil) {
            let p = VESmail_local_getuserprofileurl(user!.user);
            if (p != nil) {
                url = String(cString: p!);
            }
        }
        if (url == nil) {
            url = "https://my.vesmail.email/profile";
        }
        url! += (url!.firstIndex(of: "?") != nil ? "&" : "?");
        let login = user?.login() ?? (users.count > 0 ? "" : nil);
        let snif = VESmail_local_snifhost();
        if (snif == nil) {
            return;
        }
        url! += "snif=" + String(cString: snif!);
        if (VESmail_local_snifauthurl() != nil) {
            url! += "&snifauth=1";
            if (apns != nil) {
                url! += "&apns=" + apnsstr();
            }
        }
        if (login != nil) {
            url! += "&p=" +
                (login!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "");
        }
        if (VESmail_local_feedback != nil) {
            url! += "&fbk=" + (String(cString: VESmail_local_feedback!).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "");
        }
        if (user?.error != nil) {
            url! += "#" + user!.error!;
        }
        if (fbk) {
            fbk = false;
        } else {
            fbkbtn = false;
            fbkuser = user;
            VESmail_local_setfeedback() { _ -> Int32 in
                DispatchQueue.main.async {
                    vmApp.proxy.fbkbtn = true;
                    vmApp.proxy.fbk = true;
                    vmApp.proxy.openprofile(vmApp.proxy.fbkuser);
                }
                return 0;
            };
        }
        vmApp.openurl(url: url!);
    }
    
    func showstat(_ blink: Bool) -> Bool {
        var usr: UnsafePointer<CChar>? = nil;
        var uidx: Int = 0;
        var rs: Bool = false;
        while (true) {
            var st: Int32 = 0;
            if (blink) {
                VESmail_local_getuser(&usr, &st);
            } else {
                VESmail_local_getuser(&usr, nil);
            }
            if (usr == nil) {
                break;
            }
            if (uidx >= users.count) {
                if (!blink) {
                    break;
                }
                let u: vmUser = vmUser(usr!);
                users.append(u);
            }
            let u = users[uidx];
            if (blink) {
                u.stat = st;
            } else {
                st = u.stat;
            }
            var b: Character = "c";
            if (st >= 0 && (st & 0x0020) == 0) {
                if ((st & 0x00cc) != 0) {
                    if (blink) {
                        b = "a";
                    }
                    else {
                        b = "c";
                    }
                    rs = blink;
                } else if ((st & 0x0010) != 0) {
                    b = "a";
                } else if ((st & 0x0001) != 0) {
                    b = "c";
                } else if ((st & 0x0002) != 0) {
                    b = "e";
                }
            } else {
                b = "e";
            }
            u.bullet = b;
            var uerrbuf: [CChar] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
            let uerr = VESmail_local_getusererror(usr, &uerrbuf);
            u.seterror(b == "e" && uerr != 0 ? String(cString: uerrbuf) : nil);
            uidx += 1;
        }
        if (uidx == 0) {
            spin = spin >= 7 ? 0 : spin + 1;
            rs = true;
        }
        return rs;
    }
    
    func watch() {
        fbusy = true;
        let r = VESmail_local_watch();
        if (r < 0) {
            exit(0);
        }
        snifst = Int8(VESmail_local_snifstat());
        snifauth = VESmail_local_snifauthurl() != nil;
        vmApp.notify.snifauth(f: snifauth);
        var i: Int = 0;
        while (true) {
            if (i < daemons.count) {
                errorport = nil;
                break;
            }
            let st = VESmail_local_getstat(daemonidx[i]);
            if ((st & 0x0002) != 0) {
                errorport = String(cString: VESmail_local_getport(daemons[i]));
                break;
            }
            i += 1;
        }
        blink = showstat(true);
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
        vmApp.setbadge();
    }
    
    func idle() {
        fbusy = false;
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            if (!self.fbusy) {
                self.watch();
                self.fbusy = self.blink;
            }
            if (self.fbusy) {
                self.idlect = 8;
                self.idle();
            } else {
                if (self.idlect > 1) {
                    self.idlect -= 1;
                    self.idle();
                } else {
                    self.idlect = 0;
                    VESmail_local_sleep({ arg in
                        if (!vmApp.proxy.fwatched) {
                            vmApp.proxy.setwatch(false);
                        }
                    }, nil);
                }
            }
        }
    }
    
    func setwatch(_ w: Bool) {
        fwatched = w;
        if (w) {
            watch();
        } else if (idlect == 0) {
            idlect = 8;
            idle();
        }
    }
    
    func finduser(_ uuid: String) -> vmUser? {
        var i = 0;
        while (i < users.count) {
            if (users[i].errUUID?.uuidString == uuid) {
                return users[i];
            }
            i += 1;
        }
        return nil;
    }
    
    func setapns(_ _apns: Data) -> Int32 {
        apns = _apns;
        sendapns();
        return 1;
    }
    func sendapns() {
        if (VESmail_local_snifmsg("apns=" + apnsstr()) > 0) {
            return;
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
            self.sendapns();
        }
    }
    func apnsstr() -> String {
        return apns!.map { String(format: "%02hhx", $0); }.joined();
    }
    
    func awake(_ awake: Bool) {
        VESmail_local_snifawake(awake ? 1 : 0);
        if (!awake) {
            VESmail_local_killall();
        }
    }
    
    func errorct() -> Int {
        var b = snifauth || errorport != nil ? 1 : 0;
        for u in users {
            if (u.error != nil) {
                b += 1;
            }
        }
        return b;
    }
    
    func snifhost(_ cbk: ((String) -> Void)?) -> String? {
        let host = VESmail_local_snifhost();
        if (cbk == nil) {
            return host != nil ? String(cString: host!) : nil;
        }
        if (host == nil) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                _ = self.snifhost(cbk);
            }
        } else {
            cbk!(String(cString: host!));
        }
        return nil;
    }
}
