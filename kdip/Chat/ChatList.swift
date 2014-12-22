//
//  ChatList.swift
//  kdip
//
//  Created by Rai on 12/22/14.
//  Copyright (c) 2014 rai. All rights reserved.
//

import Foundation

class ChatList {
    var name: String = ""
    var jid: String = ""
    var lastMessage: String = ""
    var lastMessageReceivedDate: String = ""
    var type: ChatListType = ChatListType.Single
    
    init()
    {
        
    }
    
    init(jid: String, name: String, lastMessage: String, lastMessageReceivedDate: String, type: ChatListType)
    {
        self.name = name
        self.jid = jid
        self.lastMessage = lastMessage
        self.lastMessageReceivedDate = lastMessageReceivedDate
        self.type = type
    }
    
}

enum ChatListType: Int {
    case Single = 1
    case Group = 2
}