//
//  AppDelegate.swift
//  kdip
//
//  Created by Rai on 12/18/14.
//  Copyright (c) 2014 rai. All rights reserved.
//

import Foundation
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, XMPPStreamDelegate, XMPPRosterDelegate {

    var window: UIWindow?
    var chatDelegate: ChatDelegate?
    
    // XMPP Variables
    var xmppStream: XMPPStream!
    var xmppRoster: XMPPRoster!
    var xmppRosterStorage: XMPPRosterCoreDataStorage!
    
    var xmppReconnect: XMPPReconnect!
    var password: String = ""
    var isConnectionOpen: Bool = false

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        self.onXMPPFirstInit()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // XMPP Receiver Module
    func onXMPPFirstInit()
    {
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
        
        //Server Configuration
        self.xmppStream.hostName = "vb.icbali.com"
        self.xmppStream.hostPort = 5222
    }
    
    func onBeginLogin(jabberID: String, password: String)
    {
        var error: NSError?
        var data: NSData?
        
        self.xmppStream.myJID = XMPPJID.jidWithString(jabberID);
        self.password = password
        self.xmppStream.connectWithTimeout(XMPPStreamTimeoutNone, error: &error)
    }
    
    func xmppStreamDidConnect(sender: XMPPStream!) {
        var error: NSError?
        
        if xmppStream!.authenticateWithPassword(self.password, error: &error) {
            println("Authenticating...")
        }
        
    }
    
    func xmppStreamDidAuthenticate(sender: XMPPStream!) {
        println("Authenticated")
        
        self.chatDelegate?.chatDelegate!(didLogin: true, jid: "\(sender.myJID)", name: "\(sender.myJID)")
        
        // SET User Presence to Online
        var presence = XMPPPresence()
        var show = DDXMLElement.elementWithName("show") as DDXMLElement
        var status = DDXMLElement.elementWithName("status") as DDXMLElement
        show.setStringValue("chat")
        status.setStringValue("Available")
        presence.addChild(show)
        presence.addChild(status)
        xmppStream!.sendElement(presence)
        
        // Test VCard
        var iq = XMPPIQ()
        iq.addAttributeWithName("from", stringValue: "\(sender.myJID)")
        iq.addAttributeWithName("type", stringValue: "get")
        iq.addAttributeWithName("id", stringValue: "adit@vb.icbali.com")
        var vcard = DDXMLElement.elementWithName("vcard") as DDXMLElement
        vcard.addAttributeWithName("xmlns", stringValue: "vcard-temp")
//        var query = DDXMLElement.elementWithName("query") as DDXMLElement
//        query.addAttributeWithName("xmlns", stringValue: "jabber:iq:roster")
        iq.addChild(vcard)
        xmppStream.sendElement(iq)
    }
    
    func xmppStream(sender: XMPPStream!, didReceiveMessage message: XMPPMessage!) {
        let mesg = message.elementForName("body");
        println("Message : \(message)")
        if mesg != nil {
            self.chatDelegate?.chatDelegate!(didMessageReceived: mesg.stringValue())
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
    
    func xmppStream(sender: XMPPStream!, didReceiveIQ iq: XMPPIQ!) -> AnyObject! {
        println("IQ: \(iq)")
        return nil
    }


}

