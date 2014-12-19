//
//  Message.swift
//  kdip
//
//  Created by Rai on 12/19/14.
//  Copyright (c) 2014 rai. All rights reserved.
//

import Foundation

class Message: NSObject, JSQMessageData {
    var text_: String!
    var sender_: String!
    var senderId_: String!
    var date_: NSDate!
    var hash_: UInt = 0
    var media_: JSQMessageMediaData!
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
    
    override init(){
        super.init()
        self.date_ = NSDate()
        self.hash_ = 0
    }
    
    init(senderId: String, senderName: String, message: String)
    {
        self.text_ = message
        self.sender_ = senderName
        self.senderId_ = senderId
        self.date_ = NSDate()
        self.media_ = nil
        self.isMediaMessage_ = false
    }
    
    init(senderId: String, senderName: String, message: String, date: NSDate, isMediaMessage:Bool, media: JSQMessageMediaData)
    {
        self.text_ = message
        self.sender_ = senderName
        self.senderId_ = senderId
        self.date_ = date
        self.media_ = media
        self.isMediaMessage_ = true
    }

}