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
    var bridge: PHSBridge?

    // segue identifiers
    let SetupViewSegueIdentifier: NSStoryboardSegue.Identifier = .init(rawValue: "showSetupView")
    let BridgeConnectionSegueIdentifier: NSStoryboardSegue.Identifier = .init(rawValue: "showBridgeConnectionView")
    
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
        // if there is a saved last connected bridge,
        // connect to it
        if let bridgeInfo = BridgePersistenceUtil.getLastConnectedBridgeInfo() {
            print("attempting to connect to last connected bridge")
            BridgeBuilderUtil.buildBridge(with: bridgeInfo, sender: self).connect()
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
        BridgePersistenceUtil.configure()
        PHSLog.setConsoleLogLevel(.debug)
    }
    
    func buildAndConnect(with bridgeInfo: PHSBridgeInfo, sender: NSViewController?) {
        // build
        let bridge = BridgeBuilderUtil.buildBridge(with: bridgeInfo, sender: self)
        if sender != nil { dismissViewController(sender!) }
        
        // connect
        performSegue(withIdentifier: BridgeConnectionSegueIdentifier, sender: self)
        bridge.connect()
        //TODO: dismissViewController once bridge is connected
    }
    
    /**
        Handle PHS authentication failure by segueing to
        the setup view
    */
    func handleAuthenticationFailure() {
        self.performSegue(withIdentifier: SetupViewSegueIdentifier, sender: self)
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
