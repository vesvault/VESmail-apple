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
            Image("vmIcon").padding(16);
            Button(
                (proxy.fbkbtn
                ? NSLocalizedString("VALIDATE", comment: "Validate")
                : NSLocalizedString("ADD EMAIL", comment: "Add email")),
            action: {
                proxy.openprofile(nil);
            });
            VStack(alignment: .center, spacing: 0) {
                Text(proxy.errorport == nil ?
                        (proxy.snifst == 1 ? (proxy.users.count > 0 ?
                            NSLocalizedString(
                                "Connected email accounts:",
                                comment: "logged in accounts")
                        : NSLocalizedString(
                            "Waiting for connection from your email app",
                        comment: "No logged in accounts"))
                        : (proxy.snifst < 0 ? NSLocalizedString("SNIF certificate error. Try restarting the device", comment: "SNIF error")
                            : (proxy.snifauth
                                                                          ? NSLocalizedString("Click 'Add Email' to initialize the app", comment: "SNIF auth")
                                                                                                                                                : NSLocalizedString("Initializing SNIF end-to-end connection...", comment: "SNIF start")
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
                if (proxy.users.count == 0) {
                    vmSpinnerView()
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
