//
//  LightsViewController.swift
//  HuePlayground
//
//  Created by Benjamin Newcomer on 2/24/18.
//  Copyright © 2018 Benjamin Newcomer. All rights reserved.
//

import Cocoa

class LightsViewController: NSViewController {
    
    // variable to reference the current bridge
    var bridge: PHSBridge!
    
    // reference to bridge info selected from setup view
    var selectedBridgeInfo: PHSBridgeInfo?
    
    // segue identifier for segueing to the setup view
    let SetupViewSegueIdentifier: NSStoryboardSegue.Identifier = .init(rawValue: "showSetupView")
    
    //MARK: Actions
    
    /**
        Random color and brightness for all lights
    */
    @IBAction func randomizeAllLights(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        configureSDK()
        
        // if there is a selected bridge, connect
        // to that one
        if let bridgeInfo = selectedBridgeInfo {
            print("attempting to connect to selected bridge")
            bridge = self.buildBridge(with: bridgeInfo)
            bridge.connect()
            return
        }
        
        // if there is a saved last connected bridge,
        // connect to it
        if let bridgeInfo = getLastConnectedBridgeInfo() {
            print("attempting to connect to last connected bridge")
            bridge = self.buildBridge(with: bridgeInfo)
            bridge.connect()
            return
        }
        
        // if there is no bridge to connect to, show the setup view
        print("showing setup view")
        self.performSegue(withIdentifier: SetupViewSegueIdentifier, sender: self)
    }
    
    /**
     Configures the Phillips Hue persistence object
     */
    func configureSDK() {
        PHSPersistence.setStorageLocation(NSHomeDirectory(), andDeviceId: "phillipshueplayground")
        PHSLog.setConsoleLogLevel(.debug)
        print("configured PHS storage location and set console level")
    }
    
    /**
        Returns the last connected bridge or nil
    */
    func getLastConnectedBridgeInfo() -> PHSBridgeInfo? {
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
    
    /**
        Handle PHS authentication failure by segueing to
        the setup view
    */
    func handleAuthenticationFailure() {
        self.performSegue(withIdentifier: SetupViewSegueIdentifier, sender: self)
    }
    
    /**
        Factory for creating a PHSBridge from an instance
        of PHSBridgeInfo
    */
    func buildBridge(with info: PHSBridgeInfo) -> PHSBridge {
        return PHSBridge.init(block: { (builder) in
            builder?.connectionTypes = .local
            builder?.ipAddress = info.ipAddress
            builder?.bridgeID = info.uid
            builder?.bridgeConnectionObserver = self
            builder?.add(self)
        }, withAppName: "HuePlayground", withDeviceName: "benjamins-macbook")
    }
}

extension LightsViewController: PHSBridgeConnectionObserver {
    
    func bridgeConnection(_ bridgeConnection: PHSBridgeConnection!, handle connectionEvent: PHSBridgeConnectionEvent) {
        switch connectionEvent {
        case .notAuthenticated:
            handleAuthenticationFailure()
            break
        default:
            return
        }
    }
    
    func bridgeConnection(_ bridgeConnection: PHSBridgeConnection!, handleErrors connectionErrors: [PHSError]!) {
        return
    }
}

extension LightsViewController: PHSBridgeStateUpdateObserver {
    func bridge(_ bridge: PHSBridge!, handle updateEvent: PHSBridgeStateUpdatedEvent) {
        return
    }
}
