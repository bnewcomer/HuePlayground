//
//  InfoViewController.swift
//  HuePlayground
//
//  Created by Benjamin Newcomer on 2/24/18.
//  Copyright © 2018 Benjamin Newcomer. All rights reserved.
//

import Cocoa

class InfoViewController: NSViewController {
    
    // variable to reference the current bridge
    var bridge: PHSBridge?
    
    // segue identifiers
    let SetupViewSegueIdentifier: NSStoryboardSegue.Identifier = .init(rawValue: "showSetupView")
    let BridgeConnectionSegueIdentifier: NSStoryboardSegue.Identifier = .init(rawValue: "showBridgeConnectionView")
    
    //MARK: Properties
    @IBOutlet weak var bridgeLabel: NSTextField!
    
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
            buildAndConnect(with: bridgeInfo)
        } else {
            // if there is no bridge to connect to, show the setup view
            print("showing setup view")
            performSegue(withIdentifier: SetupViewSegueIdentifier, sender: self)
        }
    }
    
    /**
     Configures the Phillips Hue persistence object
     */
    func configureSDK() {
        BridgePersistenceUtil.configure()
        PHSLog.setConsoleLogLevel(.debug)
    }
    
    /**
     */
    func buildAndConnect(with bridgeInfo: PHSBridgeInfo, sender: NSViewController? = nil) {
        // build bridge from the stored bridge info
        self.bridge = BridgeBuilderUtil.buildBridge(with: bridgeInfo, sender: self)
        
        // if this method was called by another view (like the setup view),
        // dismiss that view
        if sender != nil { dismissViewController(sender!) }
        
        // connect to the bridge by segueing to connect screen. The BridgeConnectionViewController
        // will call the built bridge's connect method
        performSegue(withIdentifier: BridgeConnectionSegueIdentifier, sender: self)
    }
}

extension InfoViewController: PHSBridgeConnectionObserver {
    /**
     Handle various connection-related events
     */
    func bridgeConnection(_ bridgeConnection: PHSBridgeConnection!, handle connectionEvent: PHSBridgeConnectionEvent) {
        print(connectionEvent)
        switch connectionEvent {
        case .couldNotConnect:
            print("LightsViewController: could not connect")
            handleBridgeConnectionFailure()
            break
        case .connected:
            print("LightsViewController: connected")
            break
        case .connectionLost:
            print("LightsViewController: connection lost")
            break
        case .connectionRestored:
            print("LightsViewController: connection restored")
            break
        case .disconnected:
            print("LightsViewController: disconnected")
            handleBridgeDisconnected()
            break
        case .notAuthenticated:
            print("LightsViewController: not authenticated")
            break
        case .linkButtonNotPressed:
            print("LightsViewController: link button not pressed")
            break
        case .authenticated:
            print("LightsViewController: authenticated")
            handleBridgeAuthenticationSuccess()
            break
        default:
            return
        }
    }
    
    func bridgeConnection(_ bridgeConnection: PHSBridgeConnection!, handleErrors connectionErrors: [PHSError]!) {
        print(connectionErrors)
    }
    
    func handleBridgeConnectionFailure() {
        bridge = nil
        presentedViewControllers?[0].dismiss(self)
        performSegue(withIdentifier: SetupViewSegueIdentifier, sender: self)
    }
    
    func handleBridgeDisconnected() {
        bridge = nil
        self.performSegue(withIdentifier: SetupViewSegueIdentifier, sender: self)
    }
    
    func handleBridgeAuthenticationSuccess() {
        presentedViewControllers?[0].dismiss(self)
    }
}

extension InfoViewController: PHSBridgeStateUpdateObserver {
    func bridge(_ bridge: PHSBridge!, handle updateEvent: PHSBridgeStateUpdatedEvent) {
        // start bridge keep-alive heartbeat after bridge connection is initialized
        if updateEvent == .initialized {
            if let connection: PHSBridgeConnection = bridge?.bridgeConnections().first {
                connection.heartbeatManager.startHeartbeat(with:.fullConfig, interval: 10)
                let ipAddress: String = bridge!.bridgeConfiguration.networkConfiguration.ipAddress
                bridgeLabel.stringValue = "Connected to \(ipAddress)"
            }
        }
    }
}

