//
//  vmUserClient.swift
//  VESmail-apple
//
//  Created by test on 5/19/21.
//

import Foundation

class vmUser: ObservableObject {
    var user: String!;
    @Published var bullet: Character = " ";
    var bullet0: Character = " ";
    var bullet1: Character = " ";
    @Published var error: String? = nil;
    @Published var hover: Bool = false;
    var errUUID: UUID? = nil;

    init(_ u: String) {
        user = u;
    }
    
    func login() -> String {
        return user;
    }
    
    /*
    func seterror(_ err: String?) {
        let up: Bool = (err != error);
        error = err;
        if (up) {
            vmApp.notify.user(self);
        }
    }
    */
}
