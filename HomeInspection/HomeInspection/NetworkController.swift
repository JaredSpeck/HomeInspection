//
//  NetworkController.swift
//  HomeInspection
//
//  Created by Jared Speck on 7/16/17.
//  Copyright © 2017 Jared Speck. All rights reserved.
//

import UIKit
import Foundation
import SystemConfiguration
import CoreData

class NetworkController {
    
    static let INSPECTION = 1
    static let INSPECTION_DATA = 2
    static let RESULT = 3
    static let LAST_CHANGE = 4
    
    static var isConnectedToNetwork: Bool {
        return connectedToNetwork()
    }
    
    // MARK: Class functions
    
    class func connectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
    class func getModTimes() -> (String?, String?, String?) {
        // FIXME: Finish implementing once API call is created
        return (nil,nil,nil)

        
        if let lastChangeJSON: JSON = pullFromUrl(option: LAST_CHANGE) {
            var commentModTime: String = ""
            var subSectionModTime: String = ""
            var sectionModTime: String = ""
            
            // TODO: Parse JSON here
            
            return (commentModTime, subSectionModTime, sectionModTime)
        }
        else {
            return (nil,nil,nil)
        }
    }
    
    class func getInspectionData() -> JSON? {
        if let inspectionData: JSON = pullFromUrl(option: INSPECTION_DATA) {
            print("Successfully downloaded inspection data")
            return inspectionData
        } else {
            print("Inspection data download unsuccessful")
            return nil
        }
    }
    
    // MARK: - Database Integration
    
    // Pulls data from database and calls helper function to handle data
    private class func pullFromUrl(option: Int) -> JSON? {
        var isPullFinished: Bool = false
        var wasPullError: Bool = false
        var endPointURL: String = ""
        var downloadedJSON: JSON? = nil
        
        switch option {
        case INSPECTION:
            break
        case INSPECTION_DATA:
            endPointURL = "http://crm.professionalhomeinspection.net/sections.json"
            break
        case RESULT:
            break
        case LAST_CHANGE:
            break
        default:
            break
        }
        
        guard let url = URL(string: endPointURL) else {
            print("Error: Cannot create URL")
            wasPullError = true
            return nil
        }
        let urlRequest = URLRequest(url: url)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            
            guard error == nil else {
                print("Error: Calling GET on option \(option) failed:\n\(error!.localizedDescription)")
                wasPullError = true
                return
            }
            guard let responseData = data else {
                print ("Error: Received no date")
                wasPullError = true
                return
            }
            
            do {
                downloadedJSON = JSON(data: responseData)
                isPullFinished = true
            }
        }
        task.resume()
        
        // Wait for pull to complete before returning
        while (!wasPullError && !isPullFinished) {
            print("Waiting on pull for option \(option) to finish")
            sleep(1)
        }
        
        return downloadedJSON
    }

}
