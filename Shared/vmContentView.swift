//
//  ContentView.swift
//  Shared
//
//  Created by test on 5/11/21.
//

import SwiftUI

struct vmContentView: View {
    @EnvironmentObject var proxy: vmProxy;
    var body: some View {
        VStack {
            HStack {
                Text("version " + (Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)
                ).padding(12).font(.footnote);
            }.frame(maxWidth: 640, maxHeight: 0, alignment: .topTrailing).padding(0);
            Image("vmIcon").padding(16);
            Button(
                (proxy.fbkbtn
                ? NSLocalizedString("VALIDATE", comment: "Validate")
                : NSLocalizedString("ADD EMAIL", comment: "Add email")),
            action: {
                proxy.openprofile(nil);
            });
            VStack(alignment: .center, spacing: 0) {
                if (!proxy.snifauth) {
                    Text(proxy.errorport == nil ?
                        (proxy.snifst == 1 ? (proxy.users.count > 0 ?
                            NSLocalizedString(
                                "Connected email accounts:",
                                comment: "logged in accounts")
                        : NSLocalizedString(
                            "Waiting for connection from your email app",
                        comment: "No logged in accounts"))
                        : (proxy.snifst < 0 ? NSLocalizedString("SNIF certificate error. Try restarting the device", comment: "SNIF error")
                            : (/*proxy.snifauth
                                                                          ? NSLocalizedString("Click 'Add Email' to initialize the app", comment: "SNIF auth")
                                                                                                                                                :*/ NSLocalizedString("Initializing SNIF end-to-end connection...", comment: "SNIF start")
                            )))
                        : (proxy.errorport != "VPN"
                            ? NSLocalizedString(
                            "Error on localhost:%s. Try restarting the device.",
                            comment: "Daemon error")
                            .replacingOccurrences(of: "%s", with: proxy.errorport!)
                            : NSLocalizedString("Activate VESmail SNIF VPN", comment: "VPN error")
                        )
                ).padding()
                .lineLimit(1)
                .truncationMode(/*@START_MENU_TOKEN@*/.tail/*@END_MENU_TOKEN@*/)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(proxy.errorport != nil || proxy.snifst < 0 ? .red : nil);
                }
                if (proxy.users.count == 0 && !proxy.snifauth && proxy.snifst == 1) {
                    vmSpinnerView();
                    Text(NSLocalizedString("No email address appearing?", comment: "Spinner prompt title")).multilineTextAlignment(.center).font(.footnote).padding(12);
                    Text(NSLocalizedString("a) Did you forget to configure your email app with VESmail settings?\nb) If your configured accounts don't appear after a few seconds, open your email app and select Get Mail for a configured account.", comment: "Spinner Prompt")).multilineTextAlignment(.leading).font(.footnote);
                } else if (proxy.snifauth) {
                    VStack(alignment: .leading, spacing: 32) {
                    Text(NSLocalizedString("Click ADD EMAIL to continue the process in your browser. You may need to revert back to the VESmail app to VALIDATE.", comment: "SNIF auth")).multilineTextAlignment(.leading);
                    ScrollView {
                        Text(NSLocalizedString("USAGE OF YOUR DATA", comment: "VPN consent title"));
                        Text(NSLocalizedString("In your use of the VESmail app, VESvault Corp. only collects information necessary to enable the standard transmission and receptions of email on your behalf. This includes standard email metadata such as sender and recipient email addresses and the time stamp. We do not sell, use or disclose to third parties any data for any purpose. When you use VESmail to send email, you transmit, through us, the metadata of the email message which includes your email address, the recipients’ email addresses and the time stamp to only those third parties normally involved in the normal functioning of your email. By using VESmail encryption, you transmit even less of your personal information to these third parties, and to VESvault Corp, than you would have otherwise with VESmail in that the content of your email is end-to-end encrypted and neither any of the third parties nor VESvault Corp. have access to this information.", comment: "VPN consent")).multilineTextAlignment(.leading).font(.footnote)
                    }
                    }
                } else {
                    ScrollView {
                        ForEach(proxy.users.indices, id: \.self) { uidx in
                            vmUserRowView().environmentObject(proxy.users[uidx])
                                .frame(maxWidth: .infinity)
                                .padding(.bottom, -2)
                        }
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(minWidth: 192, maxWidth: 640, minHeight: 96, maxHeight: .infinity, alignment: .top)
            .padding(16)
        }
    }
}

struct vmContentView_Previews: PreviewProvider {
    static var previews: some View {
        vmContentView()
    }
}

struct vmUserRowView: View {
    @EnvironmentObject var user: vmUser;
    var body: some View {
        HStack {
            Image(user.bullet != " " ? ("led_" + String(user.bullet)) : "led_c")
            Text(user.login())
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(user.hover ?
                                    Color(red: 0, green: 0, blue: 0.625)
                                    : nil)
                .truncationMode(.tail)
                .lineLimit(1)
            Image(user.hover ?
                    "settings_h"
                    : (user.error != nil ?
                        "settings_e"
                        : "settings"
                    )
            ).onHover(perform: { hovering in
                user.hover = hovering;
            }).onTapGesture {
                vmApp.proxy.openprofile(user);
            }
        }
    }
}

struct vmSpinnerView: View {
    @EnvironmentObject var proxy: vmProxy;
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Image(proxy.spin == 7 ? "led_a" : "led_c").frame(width: 23, height: 23, alignment: .leading).position(x: 15, y: 15)
                Image(proxy.spin == 0 ? "led_a" : "led_c").frame(width: 18, height: 23, alignment: .leading).position(x: 9, y: 8)
                Image(proxy.spin == 1 ? "led_a" : "led_c").frame(width: 23, height: 23, alignment: .leading).position(x: 8, y: 15)
            }.frame(width: 64, height: 23, alignment: .leading)
            HStack(spacing: 0) {
                Image(proxy.spin == 6 ? "led_a" : "led_c").frame(width: 23, height: 18, alignment: .leading).position(x: 8, y: 9)
                Image(proxy.spin == 2 ? "led_a" : "led_c").frame(width: 41, height: 18, alignment: .leading).position(x: 34, y: 9)
            }.frame(width: 64, height: 18, alignment: .leading)
            HStack(spacing: 0) {
                Image(proxy.spin == 5 ? "led_a" : "led_c").frame(width: 23, height: 23, alignment: .leading).position(x: 15, y: 8)
                Image(proxy.spin == 4 ? "led_a" : "led_c").frame(width: 18, height: 23, alignment: .leading).position(x: 9, y: 15)
                Image(proxy.spin == 3 ? "led_a" : "led_c").frame(width: 23, height: 23, alignment: .leading).position(x: 8, y: 8)
            }.frame(width: 64, height: 23, alignment: .leading)
        }.frame(width: 64, height: 64, alignment: .center)
    }
}
