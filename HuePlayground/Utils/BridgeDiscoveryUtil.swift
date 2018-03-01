//
//  BridgeDiscoveryUtil.swift
//  HuePlayground
//
//  Created by Benjamin Newcomer on 2/27/18.
//  Copyright © 2018 Benjamin Newcomer. All rights reserved.
//

import Foundation

// bridge discovery options in prioritized order
let BridgeDiscoveryOptions: [PHSBridgeDiscoveryOption] = [
    .discoveryOptionUPNP,
    .discoveryOptionNUPNP,
    .discoveryOptionIPScan
]

class BridgeDiscoveryUtil {
    
    var bridgeDiscovery: PHSBridgeDiscovery
    
    /**
     initialize bridge discovery instance
    */
    init() {
        self.bridgeDiscovery = PHSBridgeDiscovery()
    }
    
    /**
     discover available hue bridges with the given PHSBridgeDiscoverOption. If no discover option is
     given, then function will iterate through the avaiable discovery options and attempt to find bridges.
     If a search yields results, those results are kept. Otherwise, this method is called again with
     the next available option until all discovery options are exhausted.
     
     - discoveryOption
     - exhaustive
     - callback(bridges)
     */
    func search(_ completion: @escaping ([PHSBridgeInfo]) -> Void, discoveryOption: PHSBridgeDiscoveryOption = BridgeDiscoveryOptions.first!, exhaustive: Bool = false) {
        var bridges: [PHSBridgeInfo] = []
        
        // search for bridges using given discovery option
        bridgeDiscovery.search(discoveryOption) {(result, returnCode) in
            if returnCode == .success && result!.count > 0 {
                // create list of PHSBridgeInfo
                for (_, value) in result! { bridges.append(PHSBridgeInfo(ipAddress: value.ipAddress, uid: value.uniqueId)) }
                completion(bridges)
            } else if exhaustive && discoveryOption != BridgeDiscoveryOptions.last {
                // if no bridges were found, try another discovery option (which will be null if there are
                // no more options, this is the recursion terminating condition)
                let nextDiscoveryOption: PHSBridgeDiscoveryOption = BridgeDiscoveryOptions[BridgeDiscoveryOptions.index(of: discoveryOption)! + 1]
                self.search(completion, discoveryOption: nextDiscoveryOption, exhaustive: true)
            } else {
                completion(bridges)
            }
        }
    }
}
