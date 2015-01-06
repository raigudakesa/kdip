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
    
    func getConversationById(jid: String, group_id: String = "-1") -> [ConversationData]
    {
        var conversation = [ConversationData]()
        self.database!.open()
        var resultset = self.database?.executeQuery("SELECT * FROM chat_conversation WHERE jid=? AND group_id=? ORDER BY date ASC", withArgumentsInArray: [jid, group_id])
        
        while resultset!.next() {
            conversation.append(ConversationData(jid: resultset!.stringForColumn("jid"),
                name: resultset!.stringForColumn("jid"),
                group_id: resultset!.stringForColumn("group_id"),
                is_sender: resultset!.boolForColumn("is_sender"),
                message_id: resultset!.stringForColumn("primary_id"),
                message: resultset!.stringForColumn("message"),
                message_multimediaurl: resultset!.stringForColumn("multimediamsg_fileurl"),
                message_multimedialocal: resultset!.stringForColumn("multimediamsg_filelocal"),
                message_date: resultset!.dateForColumn("date"),
                message_type: resultset!.longForColumn("message_type"),
                message_status: resultset!.longForColumn("message_status")))
        }
        self.database?.close()
        return conversation
    }
    
    func SaveMessage(primary_id:String = "", jid: String, group_id: String = "-1", message: String, date: NSDate, is_sender: Bool = false, message_type: Int = 1, message_status: Int, multimedia_msgurl: String = "", multimedia_msglocal:String = "")
    {
        //Message Type
        //1: Message Only
        //2: Multimedia Message
        //3: Multimedia Message With Text
        self.database!.open()
        
        var primary_id = primary_id
        if primary_id == "" { primary_id = ChatList.generateDate(jid) }
        var resultinsert = self.database?.executeUpdate("INSERT INTO chat_conversation VALUES(?,?,?,?,?,?,?,?,?,?)",
            withArgumentsInArray: [primary_id, formatNSDate("yyyy-MM-dd HH:mm:ss", date: date), jid, group_id, is_sender, message, multimedia_msgurl, multimedia_msglocal, message_type, message_status])
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