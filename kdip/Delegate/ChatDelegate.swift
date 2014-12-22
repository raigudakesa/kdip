//
//  ChatDelegate.swift
//  kdip
//
//  Created by Rai on 12/22/14.
//  Copyright (c) 2014 rai. All rights reserved.
//

import Foundation

@objc protocol ChatDelegate
{
    optional func chatDelegate(didLogin isLogin: Bool, jid: String, name: String)
    optional func chatDelegate(didMessageReceived message: String)
    optional func chatDelegate(didBuddyListReceived buddylist: NSMutableArray)
}