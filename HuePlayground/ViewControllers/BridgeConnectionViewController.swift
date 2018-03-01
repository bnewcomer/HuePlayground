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
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        // begin countdown
        countdown(start: 30, progress: updateProgressIndicator)
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        
        // stop countdown
        timer?.invalidate()
    }
    
    /**
     Update the progress indicator with the new percentage
    */
    private func updateProgressIndicator(percentage: Int) {
        progressIndicator.doubleValue = Double(percentage)
    }
    
    /**
     Perform a countdown from start seconds to 0.
     
     - start: leng of timer in seconds
     - progress: callback called every second of the timer
     */
    private func countdown(start: Int = 30, progress: @escaping (Int) -> Void) {
        var timeRemaining: Int = start
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            // decrement time remaining
            timeRemaining -= 1
            // increment progress indicator
            progress(Int(Double(start - timeRemaining) / Double(start) * 100.0))
            
            // end of timer?
            if timeRemaining == 0 {
                timer.invalidate()
                self.dismiss(self)
            }
        }
    }
}


