//
//  BridgeBuilderUtil.swift
//  HuePlayground
//
//  Created by Benjamin Newcomer on 3/1/18.
//  Copyright © 2018 Benjamin Newcomer. All rights reserved.
//

import Foundation

class BridgeBuilderUtil {
    /**
     Factory for creating a PHSBridge from an instance
     of PHSBridgeInfo
     */
    static func buildBridge(with info: PHSBridgeInfo, sender: PHSBridgeConnectionObserver & PHSBridgeStateUpdateObserver) -> PHSBridge {
        return PHSBridge.init(block: { (builder) in
            builder?.connectionTypes = .local
            builder?.ipAddress = info.ipAddress
            builder?.bridgeID = info.uid
            builder?.bridgeConnectionObserver = sender
            builder?.add(sender)
        }, withAppName: "HuePlayground", withDeviceName: "benjamins-macbook")
    }
}
