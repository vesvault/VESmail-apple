//
//  vmTunnelProvider.swift
//  vmVPN
//
//  Created by test on 8/26/21.
//

import NetworkExtension
import SwiftUI

import libsnifl_ios_arm64;

var vmApp: vmTunnelProvider!;

class vmTunnelProvider: NEPacketTunnelProvider {
    var proxy: vmProxy!;
    var notify: vmNotify!;
    var openUrlFn: ((_ url: String?) -> Bool)? = nil;
    var lastBadge: Int = 0;
    var fwatched: Bool = false;
    var pkts: [Any] = [];
    let tunlAddr = "169.254.86.77";
    let tunlPeer = "169.254.86.78";
    let tunlNet = "169.254.86.76";
    let tunlMask = "255.255.255.252";
    let tunlDst = "snif-tunl.vesmail.xyz";
    var cerr: Any? = nil;
    let af = NSNumber(value: AF_INET);
    
    override init() {
        super.init();
        vmApp = self;
        proxy = vmProxy();
        notify = vmNotify();
    }

    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        _ = proxy.snifhost { [self] host in
            VESmail_tunl_init(proxy.snifsrv, tunlDst);
            let conf = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "127.0.0.1");
            let v4 = NEIPv4Settings(addresses: [tunlAddr], subnetMasks: [tunlMask]);
            v4.includedRoutes = [
                NEIPv4Route(destinationAddress: String(cString: VESmail_tunl_get_dnsaddr_v4()), subnetMask: "255.255.255.255"),
                NEIPv4Route(destinationAddress: tunlNet, subnetMask: tunlMask)
            ];
            conf.ipv4Settings = v4;
            let dns = NEDNSSettings(servers: [tunlPeer]);
            dns.matchDomains = [host];
            conf.dnsSettings = dns;
            setTunnelNetworkSettings(conf) { error in
                self.cerr = error;
                VESmail_tunl_conf(1440) { pkt, len in
                    let data = Data(bytes: pkt!, count: Int(len));
                    DispatchQueue.main.async {
                        vmApp.packetFlow.writePackets([data], withProtocols: [vmApp.af]);
                    }
                };
                completionHandler(nil);
                self.recv();
            }
        }
    }
    
    func recv() {
        self.packetFlow.readPackets(completionHandler: { data, error in
            _ = data.map { pkt in
                let bytes = (pkt as NSData).bytes;
                VESmail_tunl_pktin(bytes, Int32(pkt.count));
            };
            self.recv();
        });
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func query(_ req: [String : Any]) -> [String : Any] {
        switch (req["req"] as! String) {
        case "watch":
            proxy.watch();
            var users: [[String : Any]] = [];
            var rsp: [String : Any] = [
                "fbkbtn": proxy.fbkbtn,
                "snifst": proxy.snifst,
                "snifauth" : proxy.snifauth
            ];
            for u in proxy.users {
                var udata: [String : Any] = [
                    "login": u.login(),
                    "bullet" : u.bullet.asciiValue ?? 0
                ];
                udata["error"] = u.error;
                users.append(udata);
            }
            if (proxy.blink) {
                _ = proxy.showstat(false);
                var uidx = 0;
                for u in proxy.users {
                    if (uidx >= users.count) {
                        break;
                    }
                    users[uidx]["blink"] = u.bullet.asciiValue ?? 0;
                    uidx += 1;
                }
            }
            rsp["users"] = users;
            rsp["errorport"] = proxy.errorport;
            if (!fwatched) {
                rsp["reset"] = true;
                fwatched = true;
            }
            return rsp;
        case "open":
            let uidx = req["uidx"] as? Int;
            var openUrl: String? = nil;
            openUrlFn = { url in
                openUrl = url;
                return true;
            };
            proxy.openprofile(uidx != nil ? proxy.users[uidx!] : nil);
            return openUrl != nil ? ["url": openUrl!] : [:];
        case "apns":
            if let apns = Data(base64Encoded: req["apns"] as? String ?? "") {
                return ["result": proxy.setapns(apns)];
            }
            break;
        default:
            break;
        }
        return [:];
    }
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        do {
            let req = try JSONSerialization.jsonObject(with: messageData, options: []) as? [String : Any];
            let rsp = req != nil ? query(req!) : [:];
            let enc = try JSONSerialization.data(withJSONObject: rsp, options: []);
            completionHandler?(enc);
        } catch {
            completionHandler?(Data())
        }
    }
    
    override func sleep(completionHandler: @escaping () -> Void) {
        proxy?.awake(false);
        completionHandler()
    }
    
    override func wake() {
        proxy?.awake(true);
    }

    func openurl(url: String) {
        if (openUrlFn?(url) ?? false) {
            openUrlFn = nil;
            return;
        }
    }
    func setbadge() {
        if let b = proxy?.errorct() {
            if (b != lastBadge) {
                notify.setbadge(b);
                lastBadge = b;
            }
        }
    }
    func vmBackgnd(_ bg: Bool) {
    }

}
