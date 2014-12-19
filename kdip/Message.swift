//
//  Message.swift
//  kdip
//
//  Created by Rai on 12/19/14.
//  Copyright (c) 2014 rai. All rights reserved.
//

import Foundation

class Message: NSObject, JSQMessageData {
    var text_: String
    var sender_: String
    var senderId_: String
    var date_: NSDate
    var hash_: UInt
    var media_: JSQMessageMediaData
    var isMediaMessage_: Bool = false
    
    func senderDisplayName() -> String! {
        return sender_
    }
    
    func date() -> NSDate! {
        return date_
    }
    
    func isMediaMessage() -> Bool {
        return isMediaMessage_
    }
    
    func senderId() -> String! {
        return senderId_
    }
    
    func hash() -> UInt {
        return hash_
    }
    
    func text() -> String! {
        return text_
    }
    
    func media() -> JSQMessageMediaData! {
        return media_
    }
    
    init(text: String?, sender: String?) {
        self.text_ = text!
        self.sender_ = sender!
        self.date_ = NSDate()
    }

}