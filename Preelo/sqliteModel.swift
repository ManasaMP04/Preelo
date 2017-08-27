//
//  sqliteModel.swift
//  Preelo
//
//  Created by Manasa MP on 27/08/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

class sqliteModel: NSObject {

    var channel_id          = -1
    var relationship        = ""
    var patientname         = ""
    var doctorname          = ""
    var parentname          = ""
    var doctor_initials     = ""
    var unread_count        = 0
    var doctorId            = 0
    var parentId            = 0
    var patientId           = 0
    var auth_status         = ""
    var doctor_user_id      = 0
    var lastMsgId           = -1
    var chatTitle           = ""
    var chatLabelTitle      = ""
    var message_type         = ""
    var message_text         = ""
    var message_date         = ""
    var image_url            = ""
    var thumb_Url            = ""
    var message_id           = 0
    var senderId             = ""
}
