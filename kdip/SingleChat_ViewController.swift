//
//  ViewController.swift
//  kdip
//
//  Created by Rai on 12/18/14.
//  Copyright (c) 2014 rai. All rights reserved.
//
import Foundation
import UIKit
import MobileCoreServices
import AssetsLibrary
import Alamofire

public enum ChatAdd: Int {
    case CHAT_ADD_PHOTO = 1
    case CHAT_ADD_CAMERA = 2
    case CHAT_ADD_VIDEO = 3
    case CHAT_ADD_LOCATION = 4
}

class SingleChat_ViewController: JSQMessagesViewController, ChatDelegate, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
        let conversation = ChatConversation()
        for c in conversation.getConversationById(self.receiverId)
        {
            if c.is_sender == true {
                self.msg.addObject(JSQMessage(senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: c.message_date, text: c.message))
            }else{
                self.msg.addObject(JSQMessage(senderId: c.jid, senderDisplayName: c.jid, date: c.message_date, text: c.message))
            }
        }
//        var fetchRequest = NSFetchRequest()
//        let entity = NSEntityDescription.entityForName("Conversation", inManagedObjectContext: managedObjectContext!)
//        var sortbyDate = NSSortDescriptor(key: "date", ascending: true)
//        var predicate = NSPredicate(format: "jid = %@", argumentArray: [self.receiverId])
//        fetchRequest.entity = entity
//        fetchRequest.predicate = predicate
//        
//        var err: NSError?
//        
//        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: &err) as? [Conversation] {
//            for (var i=0;i<fetchResults.count;i++)
//            {
//                if fetchResults[i].isuser == true {
//                    self.msg.addObject(JSQMessage(senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: fetchResults[i].date, text: fetchResults[i].message))
//                }else{
//                    self.msg.addObject(JSQMessage(senderId: fetchResults[i].jid, senderDisplayName: fetchResults[i].jid, date: fetchResults[i].date, text: fetchResults[i].message))
//                }
//            }
//        }
        
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
        let mediaType = info[UIImagePickerControllerMediaType] as NSString
        
        if mediaType.isEqualToString(kUTTypeImage as NSString) {
            var images = JSQPhotoMediaItem(image: info[UIImagePickerControllerOriginalImage] as UIImage)
            var imgURL = info[UIImagePickerControllerReferenceURL] as NSURL
            var resultblock: ALAssetsLibraryAssetForURLResultBlock = { (imageAsset: ALAsset!) -> Void in
                var imageRep = imageAsset.defaultRepresentation()
                // Check Send Item Directory
                let documentsDirectory = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
                let sendImagesDirectory = documentsDirectory[0].stringByAppendingPathComponent("send_images")
                let fileManager = NSFileManager()
                var is_directory: ObjCBool = false
                if !fileManager.fileExistsAtPath(sendImagesDirectory, isDirectory: &is_directory) && !is_directory {
                    fileManager.createDirectoryAtPath(sendImagesDirectory, withIntermediateDirectories: false, attributes: nil, error: nil)
                }
                // Save Images
                let jpeg_images = UIImageJPEGRepresentation(images.image, 1)
                let cur_date = DTLibs.convertStringFromDate("yyyyMMddHHiiss", date: NSDate())
                let file_name = sendImagesDirectory.stringByAppendingPathComponent("\(cur_date)_\(imageRep.filename())")
                //jpeg_images.writeToFile(file_name, atomically: true)
                
                //self.msg.addObject(JSQMessage(senderId: self.senderId, displayName: self.senderDisplayName, media: images))
                //self.finishSendingMessageAnimated(true)
                
                let file: [[String: AnyObject]] = [
                    ["filename": "\(cur_date)_\(imageRep.filename())","mimetype": "image/jpeg", "filedata": jpeg_images]
                ]
                let urlRequest = self.urlRequestWithComponents(nil, urlString: "http://vb.icbali.com/chat/index.php", fileData: file)
                
                Alamofire.upload(urlRequest.0, urlRequest.1)
                    .responseJSON { (request, response, data, error) -> Void in
                        if data != nil {
                            var json = JSON(data!)
                            println(json)
                            var remotePath = ""
                            remotePath = json["file"]["full_urlpath"][0].stringValue
                            println(remotePath)
                            var messg = XMPPMessage()
                            var photo = DDXMLElement.elementWithName("photo") as DDXMLElement
                            photo.setStringValue(remotePath)
                            messg.addChild(photo)
                            messg.addAttributeWithName("id", stringValue: ChatList.generateDate(self.receiverId))
                            messg.addAttributeWithName("type", stringValue: "chat")
                            messg.addAttributeWithName("to", stringValue: "\(self.receiverId)@vb.icbali.com")
                            self.DelegateApp.xmppStream.sendElement(messg)
                        }
                    }
                    .progress { (byteReceived, currentBytes, totalBytes) -> Void in
                        println("\(currentBytes)/\(totalBytes)")
                }
                

            }
            var assetslibrary = ALAssetsLibrary();
            assetslibrary.assetForURL(imgURL, resultBlock: resultblock, failureBlock: nil)
            
        }else if mediaType.isEqualToString(kUTTypeMovie as NSString) {
            println("VIDEOS")
        }
        
        picker.dismissViewControllerAnimated(true, completion: nil)
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
                self.gallerypicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                self.gallerypicker.mediaTypes = [kUTTypeImage as NSString]
                self.gallerypicker.allowsEditing = false
                self.gallerypicker.delegate = self
                self.presentViewController(self.gallerypicker, animated: true, completion: nil)
            }
            break
        case ChatAdd.CHAT_ADD_VIDEO.rawValue:
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
                self.gallerypicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                self.gallerypicker.mediaTypes = [kUTTypeMovie as NSString]
                self.gallerypicker.allowsEditing = false
                self.gallerypicker.delegate = self
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
        if (!message.isMediaMessage) {
           cell.textView.textColor = UIColor.blackColor()
        }
        return cell
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    
    // ================================================================================
    // FILE UPLOAD REQUEST MODULE
    // ================================================================================
    func urlRequestWithComponents(parameters: [String: String]?, urlString:String, fileData:[[String: AnyObject]]) -> (URLRequestConvertible, NSData) {
        
        // create url request to send
        var mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        let boundary = generateBoundaryString()
        mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
        mutableURLRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // create upload data to send
        let uploadData = NSMutableData()
        
        // add image
        if parameters != nil {
            for (key, value) in parameters! {
                uploadData.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
                uploadData.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
                uploadData.appendData("\(value)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            }
        }
        
        for value in fileData {
            let file = value["filedata"] as NSData
            let fileName = value["filename"] as String
            let fileMimeType = value["mimetype"] as String
            uploadData.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            uploadData.appendData("Content-Disposition: form-data; name=\"file[]\"; filename=\"\(fileName)\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            uploadData.appendData("Content-Type: \(fileMimeType)\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            uploadData.appendData(file)
            uploadData.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            uploadData.appendData("--\(boundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        }
        
        // return URLRequestConvertible and NSData
        return (Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0, uploadData)
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().UUIDString)"
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

