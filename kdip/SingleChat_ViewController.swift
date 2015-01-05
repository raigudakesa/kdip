//
//  ViewController.swift
//  kdip
//
//  Created by Rai on 12/18/14.
//  Copyright (c) 2014 rai. All rights reserved.
//
import Foundation
import UIKit

public enum ChatAdd: Int {
    case CHAT_ADD_PHOTO = 1
    case CHAT_ADD_CAMERA = 2
    case CHAT_ADD_VIDEO = 3
    case CHAT_ADD_LOCATION = 4
}

class SingleChat_ViewController: JSQMessagesViewController, ChatDelegate, UIScrollViewDelegate, UIImagePickerControllerDelegate {
    var gallerypicker = UIImagePickerController()
    var msg = NSMutableArray()
    var receiverDisplayName = ""
    var receiverId = ""
    var DelegateApp = UIApplication.sharedApplication().delegate as AppDelegate
    var kbView: UIView!
    var kbPager: UIPageControl!
    var kbScroll: UIScrollView!
    var kbContent: [UIView?] = []
    var toggleKeyboard = false
    
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
        self.createMenuKeyboard()
        self.makeContent()
       
        DelegateApp.chatSingleDelegate = self
        
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
        self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
        
        self.showLoadEarlierMessagesHeader = true
        self.automaticallyScrollsToMostRecentMessage = true
        
        //Load Messages From Data Store
        var fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("Conversation", inManagedObjectContext: managedObjectContext!)
        var sortbyDate = NSSortDescriptor(key: "date", ascending: true)
        var predicate = NSPredicate(format: "jid = %@", argumentArray: [self.receiverId])
        fetchRequest.entity = entity
        fetchRequest.predicate = predicate
        
        var err: NSError?
        
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: &err) as? [Conversation] {
            for (var i=0;i<fetchResults.count;i++)
            {
                if fetchResults[i].isuser == true {
                    self.msg.addObject(JSQMessage(senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: fetchResults[i].date, text: fetchResults[i].message))
                }else{
                    self.msg.addObject(JSQMessage(senderId: fetchResults[i].jid, senderDisplayName: fetchResults[i].jid, date: fetchResults[i].date, text: fetchResults[i].message))
                }
            }
        }
        
    }
    
    func createMenuKeyboard()
    {
        
        self.kbView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 220))
        
        self.kbScroll = UIScrollView(frame: CGRect(x: 0, y: 0, width: 320, height: 200))
        self.kbScroll.showsHorizontalScrollIndicator = false
        self.kbScroll.showsVerticalScrollIndicator = false
        self.kbScroll.scrollEnabled = true
        self.kbScroll.pagingEnabled = true
        let pagesScrollViewSize = self.kbScroll.frame.size
        self.kbScroll.contentSize = CGSizeMake(pagesScrollViewSize.width * CGFloat(1), pagesScrollViewSize.height)
        self.kbScroll.delegate = self
        
        self.kbPager = UIPageControl(frame: CGRect(x: 0, y: 200, width: 320, height: 20))
        self.kbPager.backgroundColor = UIColor.blackColor()
        self.kbPager.numberOfPages = 1
        self.kbPager.currentPage = 0
        
        self.kbView.addSubview(self.kbScroll)
        self.kbView.addSubview(self.kbPager)
    }
    
    func makeContent()
    {
        // Page 1
        //  Line 1
        var camera = UIButton(frame: CGRect(x: 0, y: 0, width: 106.6, height: 100))
        var video = UIButton(frame: CGRect(x: camera.frame.origin.x + camera.frame.width, y: 0, width: 106.6, height: 100))
        var photo = UIButton(frame: CGRect(x: video.frame.origin.x + video.frame.width, y: 0, width: 106.6, height: 100))
        var location = UIButton(frame: CGRect(x: 0, y: camera.frame.size.height, width: 106.6, height: 100))
        
        var camera_icon = UIImageView(frame: CGRect(x: (camera.frame.width / 2)-18, y: (camera.frame.height / 2)-20, width: 32, height: 25))
        var camera_text = UILabel(frame: CGRect(x: (camera.frame.width / 2)-51, y: (camera_icon.frame.origin.y+camera_icon.frame.height)+1, width: 100, height: 24))
        camera_icon.image = UIImage(named: "camera")
        camera_text.text = "Camera"
        camera_text.font = UIFont.systemFontOfSize(11)
        camera_text.textAlignment = NSTextAlignment.Center
        camera.tag = ChatAdd.CHAT_ADD_CAMERA.rawValue
        camera.backgroundColor = UIColor.lightTextColor()
        camera.layer.borderColor = UIColor.lightGrayColor().CGColor
        camera.layer.borderWidth = 0.25
        camera.addTarget(self, action: "buttonDown:", forControlEvents: UIControlEvents.TouchDown)
        camera.addTarget(self, action: "buttonUp:", forControlEvents: UIControlEvents.TouchUpInside)
        camera.addTarget(self, action: "buttonDragOutside:", forControlEvents: UIControlEvents.TouchDragOutside)
        camera.addSubview(camera_icon)
        camera.addSubview(camera_text)
        
        var video_icon = UIImageView(frame: CGRect(x: (camera.frame.width / 2)-18, y: (camera.frame.height / 2)-20, width: 32, height: 25))
        var video_text = UILabel(frame: CGRect(x: (camera.frame.width / 2)-51, y: (camera_icon.frame.origin.y+camera_icon.frame.height)+1, width: 100, height: 24))
        video_icon.image = UIImage(named: "video")
        video_text.text = "Choose a Video"
        video_text.font = UIFont.systemFontOfSize(11)
        video_text.textAlignment = NSTextAlignment.Center
        video.tag = ChatAdd.CHAT_ADD_VIDEO.rawValue
        video.backgroundColor = UIColor.lightTextColor()
        video.layer.borderColor = UIColor.lightGrayColor().CGColor
        video.layer.borderWidth = 0.25
        video.addTarget(self, action: "buttonDown:", forControlEvents: UIControlEvents.TouchDown)
        video.addTarget(self, action: "buttonUp:", forControlEvents: UIControlEvents.TouchUpInside)
        video.addTarget(self, action: "buttonDragOutside:", forControlEvents: UIControlEvents.TouchDragOutside)
        video.addSubview(video_icon)
        video.addSubview(video_text)
        
        var photo_icon = UIImageView(frame: CGRect(x: (camera.frame.width / 2)-18, y: (camera.frame.height / 2)-20, width: 32, height: 25))
        var photo_text = UILabel(frame: CGRect(x: (camera.frame.width / 2)-51, y: (camera_icon.frame.origin.y+camera_icon.frame.height)+1, width: 100, height: 24))
        photo_icon.image = UIImage(named: "photo")
        photo_text.text = "Choose a Photo"
        photo_text.font = UIFont.systemFontOfSize(11)
        photo_text.textAlignment = NSTextAlignment.Center
        photo.tag = ChatAdd.CHAT_ADD_PHOTO.rawValue
        photo.backgroundColor = UIColor.lightTextColor()
        photo.layer.borderColor = UIColor.lightGrayColor().CGColor
        photo.layer.borderWidth = 0.25
        photo.addTarget(self, action: "buttonDown:", forControlEvents: UIControlEvents.TouchDown)
        photo.addTarget(self, action: "buttonUp:", forControlEvents: UIControlEvents.TouchUpInside)
        photo.addTarget(self, action: "buttonDragOutside:", forControlEvents: UIControlEvents.TouchDragOutside)
        photo.addSubview(photo_icon)
        photo.addSubview(photo_text)

        //  Line 2
//        location.tag = ChatAdd.CHAT_ADD_LOCATION.rawValue
//        location.backgroundColor = UIColor.lightTextColor()
//        location.layer.borderColor = UIColor.lightGrayColor().CGColor
//        location.layer.borderWidth = 0.25
//        location.addTarget(self, action: "buttonDown:", forControlEvents: UIControlEvents.TouchDown)
//        location.addTarget(self, action: "buttonUp:", forControlEvents: UIControlEvents.TouchUpInside)

        // Page 2
        // -
        
//        self.kbContent = []
//        self.kbContent.append(camera)
//        self.kbContent.append(video)
//        self.kbContent.append(photo)
        
        self.kbScroll.addSubview(camera)
        self.kbScroll.addSubview(video)
        self.kbScroll.addSubview(photo)
        //self.kbScroll.addSubview(location)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
    }
    
    func buttonDown(sender: UIButton)
    {
        sender.backgroundColor = UIColor.lightGrayColor()
        
    }
    
    func buttonDragOutside(sender: UIButton)
    {
        sender.backgroundColor = UIColor.lightTextColor()
        
    }
    
    func buttonUp(sender: UIButton)
    {
        sender.backgroundColor = UIColor.lightTextColor()
        switch sender.tag
        {
        case ChatAdd.CHAT_ADD_PHOTO.rawValue:
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
                self.gallerypicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
                self.gallerypicker.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(self.gallerypicker.sourceType)!
                self.gallerypicker.allowsEditing = false
                
                self.presentViewController(self.gallerypicker, animated: true, completion: nil)
            }
            break
        case ChatAdd.CHAT_ADD_VIDEO.rawValue:
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
                self.gallerypicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                self.gallerypicker.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(self.gallerypicker.sourceType)!
                self.gallerypicker.allowsEditing = false
                
                self.presentViewController(self.gallerypicker, animated: true, completion: nil)
            }
        default:
            break
        }
    }
    
    func loadVisiblePages() {
        
        // First, determine which page is currently visible
        let pageWidth = self.kbScroll.frame.size.width
        let page = Int(floor((self.kbScroll.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
        
        
        // Update the page control
        self.kbPager.currentPage = page
        
        // Work out which pages you want to load
        let firstPage = page - 1
        let lastPage = page + 1
        
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        loadVisiblePages()
    }
    
    
    override func didPressAccessoryButton(sender: UIButton!) {
        self.inputToolbar.contentView.textView.becomeFirstResponder()
        
        if self.toggleKeyboard == false {
            self.toggleKeyboard = true
            self.inputToolbar.contentView.textView.inputView = self.kbView
            loadVisiblePages()
        }else{
            self.toggleKeyboard = false
            self.inputToolbar.contentView.textView.inputView = nil
        }
        
        
        self.inputToolbar.contentView.textView.reloadInputViews()
        
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
    
    func chatDelegate(senderId: String, senderName: String, didReceiveChatState state: Int) {
        if senderId == self.receiverId {
            if state == 2 {
                self.showTypingIndicator = true
            }else{
                self.showTypingIndicator = false
            }
            
            self.scrollToBottomAnimated(true)
        }
    }
    
    //======================================================================
    
    
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

