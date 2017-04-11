//
//  PlistManager.swift
//  Preelo
//
//  Created by Manasa MP on 04/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

class PlistManager {
    
    enum PlistFile {
        
        case parentInfo
    }
    
    //MARK:- Public API
    
    func setObject(_ anyObject: Any, forKey key:String, inFile file: PlistFile) {
        
        let url = URLForFile(file)
        if let dictionary = NSMutableDictionary(contentsOf: url) {
            
            dictionary.setValue(anyObject, forKey: key)
            dictionary.write(to: url, atomically: true)
            
        } else {
            
            createFolderIfRequired()
            let dict = NSDictionary(object: anyObject, forKey: key as NSCopying)
            dict.write(to: url, atomically: true)
        }
    }
    
    func objectForKey(_ aKey: String, inFile file: PlistFile) -> AnyObject? {
        
        let url = URLForFile(file)
        
        if let dictionary = NSDictionary(contentsOf: url) {
            
            return dictionary.object(forKey: aKey) as AnyObject?
        }
        return nil
    }
    
    func allKeysInPlistFile(_ file: PlistFile) -> [Any]? {
        
        let url = URLForFile(file)
        
        if let dictionary = NSDictionary(contentsOf: url) {
            
            return dictionary.allKeys
        }
        
        return nil
    }
    
    //MARK:- Private API's
    
    fileprivate func URLForFile(_ file: PlistFile) -> URL {
        
        let name = nameForFile(file)
        
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        var url = URL(fileURLWithPath: documentsDirectory)
        url = url.appendingPathComponent("PlistFiles")
        url = url.appendingPathComponent(name, isDirectory: false)
        
        return url
    }
    
    fileprivate func nameForFile(_ file: PlistFile) -> String {
        
        switch file {
            
        case .parentInfo:
            return "ParentInfo.plist"
        }
    }
    
    fileprivate func createFolderIfRequired () {
        
        let fManager = FileManager.default
        
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        var url = URL(fileURLWithPath: documentsDirectory)
        url = url.appendingPathComponent("PlistFiles")
        
        if (!fManager.fileExists(atPath: url.absoluteString)) {
            
            let attr = [FileAttributeKey.protectionKey.rawValue: FileProtectionType.complete]
            
            try! fManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: attr)
        }
    }
    
    func deleteObject(forKey key:String, inFile file: PlistFile) {
        
        let url = URLForFile(file)
        if let dictionary = NSMutableDictionary(contentsOf: url) {
            
            dictionary.removeObject(forKey: key)
            dictionary.write(to: url, atomically: true)
        }
    }
}
