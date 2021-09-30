//
//  vmUser.swift
//  VESmail-apple
//
//  Created by test on 5/19/21.
//

import Foundation

class vmUser: ObservableObject {
    var stat: Int32 = 0;
    var user: UnsafePointer<CChar>!;
    @Published var bullet: Character = " ";
    @Published var error: String? = nil;
    @Published var hover: Bool = false;
    var errUUID: UUID? = nil;

    init(_ u: UnsafePointer<CChar>) {
        user = u;
    }
    
    func login() -> String {
        return String(cString: user);
    }
    
    func seterror(_ err: String?) {
        let up: Bool = (err != error);
        error = err;
        if (up) {
            vmApp.notify.user(self);
        }
    }
}
