//
//  BridgePersistenceUtil.swift
//  HuePlayground
//
//  Created by Benjamin Newcomer on 3/1/18.
//  Copyright © 2018 Benjamin Newcomer. All rights reserved.
//

import Foundation

class BridgePersistenceUtil {
    /**
    Configures HueSDK persistence options
    */
    static func configure() {
        PHSPersistence.setStorageLocation(NSHomeDirectory(), andDeviceId: "phillipshueplayground")
    }
    
    /**
     Returns the last connected bridge or nil
     */
    static func getLastConnectedBridgeInfo() -> PHSBridgeInfo? {
        guard let knownBridges: [PHSKnownBridge] = PHSKnownBridges.getAll() else {
            return nil
        }
        
        let sortedBridges = knownBridges.sorted { (bridgeA, bridgeB) -> Bool in
            return bridgeA.lastConnected < bridgeB.lastConnected
        }
        
        // return info for last known bridge or nil
        if let lastKnownBridge = sortedBridges.first {
            return PHSBridgeInfo(ipAddress: lastKnownBridge.ipAddress, uid: lastKnownBridge.uniqueId)
        }
        
        return nil
    }
}
