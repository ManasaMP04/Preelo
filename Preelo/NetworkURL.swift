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
}
