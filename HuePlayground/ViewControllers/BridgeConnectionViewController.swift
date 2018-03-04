//
//  BridgeConnectionViewController.swift
//  HuePlayground
//
//  Created by Benjamin Newcomer on 3/1/18.
//  Copyright © 2018 Benjamin Newcomer. All rights reserved.
//
import Cocoa

class BridgeConnectionViewController: NSViewController {
    private var timer: Timer?
    
    //MARK: Properties
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var label: NSTextField!
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        // begin countdown waiting for user to press bridge link
        progressIndicator.stopAnimation(self)
        progressIndicator.isIndeterminate = false
        label.stringValue = "Connecting to bridge... press the link button to finish connecting"
        
        if let parent = self.presenting as? InfoViewController {
            parent.bridge?.connect()
            countdown(start: 30, progress: updateProgressIndicator)
        }
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        
        // stop countdown
        timer?.invalidate()
    }
    
    /**
     Update the progress indicator with the new percentage
    */
    func updateProgressIndicator(percentage: Int) {
        progressIndicator.doubleValue = Double(percentage)
    }
    
    /**
     Perform a countdown from start seconds to 0.
     
     - start: leng of timer in seconds
     - progress: callback called every second of the timer
     */
    func countdown(start: Int = 30, progress: @escaping (Int) -> Void) {
        var timeRemaining: Int = start
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            // decrement time remaining
            timeRemaining -= 1
            // increment progress indicator
            print(Int(Double(start - timeRemaining) / Double(start) * 100.0))
            progress(Int(Double(start - timeRemaining) / Double(start) * 100.0))
            
            // end of timer?
            if timeRemaining == 0 {
                timer.invalidate()
                if let parent = self.presenting as? InfoViewController {
                    parent.handleBridgeConnectionFailure()
                }
            }
        }
    }
}


