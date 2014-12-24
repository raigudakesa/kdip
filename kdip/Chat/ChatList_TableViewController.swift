//
//  ChatList_TableViewController.swift
//  kdip
//
//  Created by Rai on 12/22/14.
//  Copyright (c) 2014 rai. All rights reserved.
//

import UIKit

class ChatList_TableViewController: UITableViewController, ChatDelegate {
    var DelegateApp = UIApplication.sharedApplication().delegate as AppDelegate
    
    var chatList = [ChatList]()
    var selectedCell: NSIndexPath!
    
    lazy var managedObjectContext : NSManagedObjectContext? = {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext {
            return managedObjectContext
        }
        else {
            return nil
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.DelegateApp.chatListDelegate = self
        
        loadChat()

    }
    
    func loadChat()
    {
        self.chatList = [ChatList]()
        var fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("Conversation", inManagedObjectContext: managedObjectContext!)
        //var jid = entity?.attributesByName["jid"] as NSAttributeDescription
        //var date = entity?.attributesByName["date"] as NSAttributeDescription
        var sortbyDate = NSSortDescriptor(key: "date", ascending: false)
        
        fetchRequest.entity = entity
        fetchRequest.sortDescriptors = [sortbyDate]
        //fetchRequest.propertiesToGroupBy = ["jid"]
        //fetchRequest.propertiesToFetch = ["jid", "message"]
        //fetchRequest.resultType = NSFetchRequestResultType.DictionaryResultType
        
        var err: NSError?
        
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: &err) as? [Conversation] {
            // Group By
            var temp = [String]()
            var found = false
            for (var i=0;i<fetchResults.count;i++)
            {
                found = false
                for(var j=0;j<temp.count;j++){
                    if(fetchResults[i].jid == temp[j])
                    {
                        found = true
                        break;
                    }
                }
                
                if(!found)
                {
                    temp.append(fetchResults[i].jid)
                    chatList.append(ChatList(jid: fetchResults[i].jid, name: fetchResults[i].jid, lastMessage: fetchResults[i].message, lastMessageReceivedDate: fetchResults[i].date, type: ChatListType.Single))
                }
                
            }
        }
            
        
        
    }
    
    func chatDelegate(senderId: String, senderName: String, didMessageReceived message: String, date: NSDate) {
        println("CHAT MASUK")
        self.loadChat()
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return chatList.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 67
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedCell = indexPath
        performSegueWithIdentifier("showSingleChat", sender: self)
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellchatlist2", forIndexPath: indexPath) as ChatList_TableViewCell

        // Configure the cell..
//        cell.avatar.frame = CGRect(x: 15, y: 8, width: 50, height: 50)
//        cell.username.frame = CGRect(x: 73, y: 4, width: 180, height: 24)
//        cell.lastMessage.frame = CGRect(x: 73, y: 21, width: 180, height: 24)
//        cell.lastDate.frame = CGRect(x: 261, y: 4, width: 50, height: 24)
        
        // Set Cell Value
        cell.username.text = chatList[indexPath.row].name
        cell.lastMessage.text = chatList[indexPath.row].lastMessage
        cell.lastDate.text = formatNSDate("HH:mm", date: chatList[indexPath.row].lastMessageReceivedDate)
        
        return cell
    }
    
    func formatNSDate(format: String, date: NSDate) -> String
    {
        var formatter: NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = format
        let stringDate: String = formatter.stringFromDate(date)
        return stringDate
    }


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier!
        {
        case "showSingleChat":
            let controller = segue.destinationViewController as SingleChat_ViewController
            controller.receiverDisplayName = chatList[self.selectedCell.row].name
            controller.receiverId = chatList[self.selectedCell.row].jid
            controller.senderId = "\(DelegateApp.xmppStream.myJID)"
            controller.senderDisplayName = "\(DelegateApp.xmppStream.myJID)"
            
            controller.hidesBottomBarWhenPushed = true
            break
        default:
            break
        }
    }


}
