//
//  ViewController.swift
//  kdip
//
//  Created by Rai on 12/18/14.
//  Copyright (c) 2014 rai. All rights reserved.
//
import Foundation
import UIKit

class SingleChat_ViewController: JSQMessagesViewController, ChatDelegate {
    var msg = NSMutableArray()
    var receiverDisplayName = ""
    var receiverId = ""
    var DelegateApp = UIApplication.sharedApplication().delegate as AppDelegate
    
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
        
        DelegateApp.chatSingleDelegate = self
        
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
        self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
        
        self.showLoadEarlierMessagesHeader = true
        self.automaticallyScrollsToMostRecentMessage = true
        
        //Load Messages From Data Store
        var fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("Conversation", inManagedObjectContext: managedObjectContext!)
        var sortbyDate = NSSortDescriptor(key: "date", ascending: true)
        var predicate = NSPredicate(format: "jid = %@", argumentArray: [receiverId])
        fetchRequest.entity = entity
        fetchRequest.predicate = predicate
        
        var err: NSError?
        
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: &err) as? [Conversation] {
            for (var i=0;i<fetchResults.count;i++)
            {
                self.msg.addObject(JSQMessage(senderId: fetchResults[i].jid, senderDisplayName: fetchResults[i].jid, date: fetchResults[i].date, text: fetchResults[i].message))
            }
        }

    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        self.msg.addObject(JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text))
        self.finishSendingMessageAnimated(true)
        
        var messg = XMPPMessage()
        messg.addBody(text)
        messg.addAttributeWithName("type", stringValue: "chat")
        messg.addAttributeWithName("to", stringValue: "\(receiverId)@vb.icbali.com")
        self.DelegateApp.xmppStream.sendElement(messg)
    }
    
    // =====================================================================
    // Chat Delegate
    // =====================================================================
    func chatDelegate(senderId: String, senderName: String, didMessageReceived message: String, date: NSDate) {
        self.msg.addObject(JSQMessage(senderId: senderId, senderDisplayName: senderName, date: date, text: message))
        self.finishReceivingMessageAnimated(true)
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        //return self.messages[indexPath.item]
        return self.msg.objectAtIndex(indexPath.item) as JSQMessageData
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return msg.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        var bubbleFactory = JSQMessagesBubbleImageFactory()
        
        if (msg.objectAtIndex(indexPath.item) as JSQMessage).senderId == self.senderId
        {
            return bubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
        }
        
        return bubbleFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as JSQMessagesCollectionViewCell
        
        let message = msg.objectAtIndex(indexPath.item) as JSQMessage
        cell.textView.textColor = UIColor.blackColor()
        return cell
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

