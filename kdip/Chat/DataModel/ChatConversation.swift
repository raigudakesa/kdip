//
//  ChatConversation.swift
//  kdip
//
//  Created by Rai on 1/5/15.
//  Copyright (c) 2015 rai. All rights reserved.
//

import Foundation

class ChatConversation {
    var database: FMDatabase? = nil
    
    init(){
        self.database = FMDatabase(path: Util.getPath("kdip.sqlite"))
        var path = Util.getPath("kdip.sqlite")
    }
    
    func getConversationList() -> [ChatList]
    {
        var chatList = [ChatList]()
        self.database!.open()
        var resultset = self.database?.executeQuery("SELECT * FROM chat_conversation GROUP BY jid ORDER BY date DESC", withArgumentsInArray: nil)
        
        while resultset!.next() {
            chatList.append(ChatList(jid: resultset!.stringForColumn("jid"), name: resultset!.stringForColumn("jid"), lastMessage: resultset!.stringForColumn("message"), lastMessageReceivedDate: NSDate(), type: ChatListType.Single))
        }
        self.database?.close()
        return chatList
    }
    
    func receiveMessage(jid: String, group_id: String = "-1", message: String, date: NSDate, message_type: Int = 1, multimedia_msgurl: String = "", multimedia_msglocal:String = "")
    {
        //Message Type
        //1: Message Only
        //2: Multimedia Message
        //3: Multimedia Message With Text
        self.database!.open()
        var primary_date = formatNSDate("yyyyMMddHHmmss", date: date)
        var resultinsert = self.database?.executeUpdate("INSERT INTO chat_conversation VALUES(?,?,?,?,?,?,?,?,?,?)",
            withArgumentsInArray: [primary_date, 1, formatNSDate("yyyy-MM-dd HH:mm:ss", date: date), jid, group_id, 0, message, multimedia_msgurl, multimedia_msglocal, 1])
        self.database?.close()
    }
    
    func formatNSDate(format: String, date: NSDate) -> String
    {
        var formatter: NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = format
        let stringDate: String = formatter.stringFromDate(date)
        return stringDate
    }
}