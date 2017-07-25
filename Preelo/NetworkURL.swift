//
//  NetworkURL.swift
//  Preelo
//
//  Created by Manasa MP on 14/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

enum NetworkURL {
    
    static let baseUrl                      = "https://api.preelo.com/api"
    static let forgotPassword               = "user/resetRequest"
    static let docLogin                     = "doctor/login"
    static let addPatient                   = "patient/add"
    static let patientLogin                 = "patient/login"
    static let logout                       = "logout"
    static let patientAuthorization         = "patient/requestAuthorization"
    static let patientList                  = "patients"
    static let doctorList                   = "doctors"
    static let patientSelect                = "patient/select"
    static let docSelect                    = "doctor/select"
    static let authRequestList              = "patients/authRequests"
    static let docApproveAuthorization      = "doctor/approveAuthorization"
    static let docRejectAuthorization       = "doctor/rejectAuthorization"
    static let editPatient                  = "patients"
    static let sendText                     = "messages/send"
    static let sendImage                    = "image/send"
    static let channel                      = "user/channels"
    static let patientAuthRequest           = "doctor/authRequests"
    static let getMessages                  = "messages"
    static let markedRead                   = "messages/markread"
    static let feedback                     = "user/feedback"
    static let partentdelet                 = "parent/account/delete"
    static let childUpdate                  = "parent/children/update"
    static let updateProfile                = "user/update"
    static let doctorunblock                = "doctor/unblock"
    static let doctorblock                  = "doctor/block"
    
    
     static let patientedit                  = "patient/edit"
}
