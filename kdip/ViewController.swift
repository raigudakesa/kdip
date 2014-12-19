//
//  ViewController.swift
//  kdip
//
//  Created by Rai on 12/18/14.
//  Copyright (c) 2014 rai. All rights reserved.
//
import Foundation
import UIKit

class ViewController: JSQMessagesViewController, XMPPStreamDelegate, XMPPRosterDelegate {
    var xmppStream: XMPPStream!
    var xmppRoster: XMPPRoster!
    var xmppRosterStorage: XMPPRosterCoreDataStorage!
    var xmppReconnect: XMPPReconnect!
    var password: String = ""
    var messages = [Message]()
    var sid: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var error: NSError?
        self.xmppStream = XMPPStream()
        self.xmppReconnect = XMPPReconnect()
        self.xmppRosterStorage = XMPPRosterCoreDataStorage()
        self.xmppRoster = XMPPRoster(rosterStorage: self.xmppRosterStorage)
        self.xmppRoster.autoFetchRoster = true
        self.xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = true
        
        //Activate
        self.xmppReconnect.activate(xmppStream)
        self.xmppRoster.activate(xmppStream)
        
        //Delegate
        self.xmppStream.addDelegate(self, delegateQueue: dispatch_get_main_queue())
        self.xmppRoster.addDelegate(self, delegateQueue: dispatch_get_main_queue())
        
        //Connect
        self.xmppStream.myJID = XMPPJID.jidWithString("raigudakesa@vb.icbali.com");
        self.password = "qwerty"
        self.xmppStream.connectWithTimeout(XMPPStreamTimeoutNone, error: &error)
        
        
        self.inputToolbar.contentView.leftBarButtonItem = nil
        self.automaticallyScrollsToMostRecentMessage = true
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        self.sid++
        self.messages.append(Message(senderId: "\(self.sid)", senderName: "Rai Gudakesa", message: text))
        self.finishSendingMessage()
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        var bubbleFactory = JSQMessagesBubbleImageFactory()
        
        return bubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]

        cell.textView.textColor = UIColor.blackColor()
        cell.textView.text = message.text_
        cell.sizeToFit()
        //let attributes : [NSObject:AnyObject] = [NSForegroundColorAttributeName:cell.textView.textColor, NSUnderlineStyleAttributeName: 1]
        //cell.textView.linkTextAttributes = attributes
        
        //        cell.textView.linkTextAttributes = [NSForegroundColorAttributeName: cell.textView.textColor,
        //            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle]
        return cell
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let message = messages[indexPath.item]
        
        // Sent by me, skip
//        if message.sender() == sender {
//            return CGFloat(0.0);
//        }
        
//        // Same as previous sender, skip
//        if indexPath.item > 0 {
//            let previousMessage = messages[indexPath.item - 1];
//            if previousMessage.sender() == message.sender() {
//                return CGFloat(0.0);
//            }
//        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    
    func xmppStreamDidConnect(sender: XMPPStream!) {
        var error: NSError?
        
        if xmppStream!.authenticateWithPassword(self.password, error: &error) {
            println("Login Success")
        }
        
        
    }
    
    func xmppStreamDidAuthenticate(sender: XMPPStream!) {
        println("Authenticated")
        var presence = XMPPPresence()
        var show = DDXMLElement.elementWithName("show") as DDXMLElement
        var status = DDXMLElement.elementWithName("status") as DDXMLElement
        show.setStringValue("chat")
        status.setStringValue("Available")
        presence.addChild(show)
        presence.addChild(status)
        xmppStream!.sendElement(presence)
    }
    
    func xmppStream(sender: XMPPStream!, didReceiveMessage message: XMPPMessage!) {
        let msg = message.elementForName("body");
        println("Message : \(message)")
    }
    
    func xmppStream(sender: XMPPStream!, didReceivePresence presence: XMPPPresence!) {
        println("Receive Presence : \(presence)")
        
        if presence.attributeStringValueForName("type") != nil {
            switch presence.attributeStringValueForName("type") {
            case "subscribe":
                self.xmppRoster.acceptPresenceSubscriptionRequestFrom(presence.from(), andAddToRoster: true)
            default:
                break;
            }
        }
    }
    
    func xmppStream(sender: XMPPStream!, didSendPresence presence: XMPPPresence!) {
        println("Sended Presence : \(presence)")
    }
    
    func xmppRoster(sender: XMPPRoster!, didReceiveRosterItem item: DDXMLElement!) {
        println("ROSTER ITEM: \(item)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

