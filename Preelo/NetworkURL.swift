//
//  NetworkURL.swift
//  Preelo
//
//  Created by Manasa MP on 14/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

enum NetworkURL {
    
    static let baseUrl              = "https://api.preelo.com/api"
    static let forgotPassword       = "user/resetRequest"
    static let docLogin             = "doctor/login"
    static let addPatient           = "patient/add"
    static let patientLogin         = "patient/login"
    static let logout               = "logout"
    static let sendText             = "messages/send"
    static let addParent            = "patient/addFamily"
    static let patientAuthorization = "patient/requestAuthorization"
    static let patientList          = "patients"
    static let doctorList           = "doctors"
}
