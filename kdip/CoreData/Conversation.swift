//
//  Conversation.swift
//  kdip
//
//  Created by Rai on 12/23/14.
//  Copyright (c) 2014 rai. All rights reserved.
//

import Foundation
import CoreData

class Conversation: NSManagedObject {

    @NSManaged var groupid: String
    @NSManaged var jid: String
    @NSManaged var message: String
    @NSManaged var type: NSNumber
    @NSManaged var date: NSDate

}
