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
    var msg = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var error: NSError?
        var data: NSData?
    
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
        
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
        self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
        
        self.showLoadEarlierMessagesHeader = true
        
        // Harus Set User dan ID
        self.senderDisplayName = "raigudakesa"
        self.senderId = "raigudakesa@vb.icbali.com"
        
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        var messg = XMPPMessage()
        messg.addBody(text)
        messg.addAttributeWithName("type", stringValue: "chat")
        messg.addAttributeWithName("to", stringValue: "adit@vb.icbali.com")
        self.xmppStream.sendElement(messg)
        self.msg.addObject(JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text))
        self.finishSendingMessageAnimated(true)
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
        //let message = messages[indexPath.item]
        
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
        let mesg = message.elementForName("body");
        println("Message : \(message)")
        if mesg != nil {
            self.msg.addObject(JSQMessage(senderId: "2", displayName: "Outside", text: mesg.stringValue()))
            self.finishReceivingMessage()
        }
        
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

