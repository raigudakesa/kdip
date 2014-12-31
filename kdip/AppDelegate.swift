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
class AppDelegate: UIResponder, UIApplicationDelegate, XMPPStreamDelegate, XMPPRosterDelegate, XMPPOutgoingFileTransferDelegate {
    
    var chatDelegate: ChatDelegate?
    var chatListDelegate: ChatDelegate?
    var chatSingleDelegate: ChatDelegate?
    
    var window: UIWindow?
    
    // XMPP Variables
    var xmppStream: XMPPStream!
    var xmppRoster: XMPPRoster!
    var xmppRosterStorage: XMPPRosterCoreDataStorage!
    
    var xmppReconnect: XMPPReconnect!
    var password: String = ""
    var isConnectionOpen: Bool = false
    
    // CORE DATA ====================================>
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.jqsoftware.MyLog" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as NSURL
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("ModelChat.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
    
    // END CORE DATA =========================================>
    
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
        self.saveContext()
    }
    
    // =========================================================
    // XMPP Receiver Module
    // =========================================================
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
    
    func getJabberID()->String
    {
        return splitJabberId("\(self.xmppStream.myJID)")["accountName"]!
    }
    
    func onBeginLogin(jabberID: String, password: String)
    {
        var error: NSError?
        var data: NSData?
        
        self.xmppStream.myJID = XMPPJID.jidWithString(jabberID+"/kdip");
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
        self.chatDelegate(didLogin: true, jid: "\(sender.myJID)", name: "\(sender.myJID)")
        
        // SET User Presence to Online
        var presence = XMPPPresence()
        var show = DDXMLElement.elementWithName("show") as DDXMLElement
        var status = DDXMLElement.elementWithName("status") as DDXMLElement
        show.setStringValue("chat")
        status.setStringValue("Available")
        presence.addChild(show)
        presence.addChild(status)
        xmppStream!.sendElement(presence)
        
        //Check Friend List Core Data
        let friendList = NSFetchRequest(entityName: "FriendList")
        if let friendResults = managedObjectContext!.executeFetchRequest(friendList, error: nil) as? [FriendList] {
            if friendResults.count <= 0 {
                var iq = XMPPIQ();
                var query = DDXMLElement.elementWithName("query") as DDXMLElement
                iq.addAttributeWithName("from", stringValue: "\(sender.myJID)")
                iq.addAttributeWithName("id", stringValue: "friendlistrequest")
                iq.addAttributeWithName("type", stringValue: "get")
                
                query.addAttributeWithName("xmlns", stringValue: "jabber:iq:roster")
                
                iq.addChild(query)
                xmppStream.sendElement(iq)
            }
        }
        
        // Test VCard
//        var iq = XMPPIQ()
//        iq.addAttributeWithName("from", stringValue: "\(sender.myJID)")
//        iq.addAttributeWithName("type", stringValue: "get")
//        iq.addAttributeWithName("id", stringValue: "adit@vb.icbali.com")
//        var vcard = DDXMLElement.elementWithName("vcard") as DDXMLElement
//        vcard.addAttributeWithName("xmlns", stringValue: "vcard-temp")
//        iq.addChild(vcard)
//        xmppStream.sendElement(iq)
        
        // Test File Transfer
//        var filesend_queue = dispatch_queue_create("fileTransfer", nil)
//        var ft = XMPPOutgoingFileTransfer(dispatchQueue: filequeue)
//        var err:NSError?
//        ft.activate(xmppStream)
//        ft.addDelegate(self, delegateQueue: filesend_queue)
//        ft.sendData(NSData(base64EncodedString: imgdata, options: nil), named: "img.jpg", toRecipient: XMPPJID.jidWithString("adit@vb.icbali.com/iuvencas-iMac"), description: "Gambar Doang.", error: &err)
//        println(err)
    }
    
    func xmppStream(sender: XMPPStream!, didReceiveMessage message: XMPPMessage!) {
        let jid = splitJabberId("\(message.from())")["accountName"]!
        
        for children in message.children()
        {
            switch children.name
            {
            case "body":
                let mesg = message.elementForName(children.name)
                let ChatIn = NSEntityDescription.insertNewObjectForEntityForName("Conversation", inManagedObjectContext: self.managedObjectContext!) as Conversation
                
                ChatIn.groupid = "-1"
                ChatIn.message = mesg.stringValue()
                ChatIn.type = 1
                ChatIn.jid = jid
                ChatIn.date = NSDate()
                ChatIn.isuser = false
                
                self.saveContext()
                
                self.chatDelegate(ChatIn.jid, senderName: ChatIn.jid, didMessageReceived: ChatIn.message, date: ChatIn.date)
                break
            case "composing":
                self.chatDelegate(jid, senderName: jid, didReceiveChatState: 2)
                break
            case "paused":
                self.chatDelegate(jid, senderName: jid, didReceiveChatState: 1)
                break
            case "active":
                self.chatDelegate(jid, senderName: jid, didReceiveChatState: 0)
                break
            default:
                break
            }
        }

        
    }
    
    func xmppStream(sender: XMPPStream!, didSendMessage message: XMPPMessage!) {
        //println("DIDSEND : \(message)")
        let mesg = message.elementForName("body");
        let ChatIn = NSEntityDescription.insertNewObjectForEntityForName("Conversation", inManagedObjectContext: self.managedObjectContext!) as Conversation
        if mesg != nil {
            ChatIn.groupid = "-1"
            ChatIn.message = mesg.stringValue()
            ChatIn.type = 1
            ChatIn.jid = splitJabberId("\(message.to())")["accountName"]!
            ChatIn.date = NSDate()
            ChatIn.isuser = true
            self.saveContext()
            
            self.chatDelegate(1, target: ChatIn.jid, didMessageSend: ChatIn.message, date: ChatIn.date)
            
        }
        
    }
    
    func splitJabberId(jid: String) -> [String:String]
    {
        var splitJid = split(jid) {$0 == "/"}
        var splitAccount = split(splitJid[0]) {$0 == "@"}
        var resource = ""
        if splitJid.count > 1 {
            resource = splitJid[1]
        }
        if splitAccount.count > 1 {
            return ["accountName":splitAccount[0], "hostname":splitAccount[splitAccount.count-1], "resource":resource]
        }
        return ["accountName":splitAccount[0], "hostname":splitAccount[1], "resource":resource]
    }
    
    func xmppStream(sender: XMPPStream!, didReceivePresence presence: XMPPPresence!) {
        //println("Receive Presence : \(presence)")
        
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
        //println("Sended Presence : \(presence)")
    }
    
    func xmppRoster(sender: XMPPRoster!, didReceiveRosterItem item: DDXMLElement!) {
        //println("ROSTER ITEM: \(item)")
    }
    
    func xmppStream(sender: XMPPStream!, didReceiveIQ iq: XMPPIQ!) -> AnyObject! {
        println("IQ: \(iq)")
        return nil
    }
    
    func xmppStream(sender: XMPPStream!, didReceiveError error: DDXMLElement!) {
        for children in error.children()
        {
            switch children.name
            {
            case "conflict":
//                let alert = UIAlertController(title: "Warning", message: "Another devices logged in with this account", preferredStyle: UIAlertControllerStyle.Alert)
//                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
//                self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
                
                break
            default:
                break
            }
        }
    }
    
    func xmppStreamDidDisconnect(sender: XMPPStream!, withError error: NSError!) {
        println("DISCONNECT : \(error)")
    }
    
    //==========================
    // Chat Delegate
    //==========================
    
    func chatDelegate(didAlertReceived alertCode: Int){
        
    }
    func chatDelegate(didBuddyListReceived buddylist: NSMutableArray) {
        self.chatDelegate?.chatDelegate?(didBuddyListReceived: buddylist)
    }
    func chatDelegate(didLogin isLogin: Bool, jid: String, name: String) {
        self.chatDelegate?.chatDelegate?(didLogin: isLogin, jid: jid, name: name)
    }
    func chatDelegate(senderId: String, senderName: String, didReceiveChatState state: Int) {
        self.chatSingleDelegate?.chatDelegate?(senderId, senderName: senderName, didReceiveChatState: state)
    }
    func chatDelegate(type: Int, target: String, didMessageSend message: String, date: NSDate) {
        self.chatListDelegate?.chatDelegate?(type, target: target, didMessageSend: message, date: date)
        self.chatSingleDelegate?.chatDelegate?(type, target: target, didMessageSend: message, date: date)
    }
    func chatDelegate(senderId: String, senderName: String, didMessageReceived message: String, date: NSDate) {
        self.chatListDelegate?.chatDelegate?(senderId, senderName: senderName, didMessageReceived: message, date: date)
        self.chatSingleDelegate?.chatDelegate?(senderId, senderName: senderName, didMessageReceived: message, date: date)
    }
    func chatDelegate(senderId: String, senderName: String, didMultimediaReceived data: String, date: NSDate) {
        self.chatListDelegate?.chatDelegate?(senderId, senderName: senderName, didMultimediaReceived: data, date: date)
        self.chatSingleDelegate?.chatDelegate?(senderId, senderName: senderName, didMultimediaReceived: data, date: date)
    }
    
    //==========================
    // File Transfer Section
    //==========================
    func xmppOutgoingFileTransferDidSucceed(sender: XMPPOutgoingFileTransfer!) {
        println("Success Transfering File")
    }
    
    func xmppOutgoingFileTransfer(sender: XMPPOutgoingFileTransfer!, didFailWithError error: NSError!) {
        println("Failed Transfering File")
    }

}

