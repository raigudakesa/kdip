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
        
        DelegateApp.chatDelegate = self
        
        loadChat()

    }
    
    func loadChat()
    {
        let fetchRequest = NSFetchRequest(entityName: "Conversation")
        let entity = NSEntityDescription.entityForName("Conversation", inManagedObjectContext: managedObjectContext!)
        
        //fetchRequest.propertiesToGroupBy = "jid"
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Conversation] {
            for (var i=0;i<fetchResults.count;i++)
            {
                chatList.append(ChatList(jid: fetchResults[i].jid, name: fetchResults[i].jid, lastMessage: fetchResults[i].message, lastMessageReceivedDate: fetchResults[i].date, type: ChatListType.Group))
            }
        }
    }
    
    func chatDelegate(didMessageReceived message: String) {
        println(message)
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

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellchatlist", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...
        cell.textLabel.text = self.chatList[indexPath.row].lastMessage
        
        return cell
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
