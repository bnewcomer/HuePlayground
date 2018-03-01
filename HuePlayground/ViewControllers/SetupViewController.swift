//
//  SetupViewController.swift
//  HuePlayground
//
//  Created by Benjamin Newcomer on 2/24/18.
//  Copyright © 2018 Benjamin Newcomer. All rights reserved.
//

import Cocoa

class SetupViewController: NSViewController {
    
    //MARK: Properties
    var bridges: [PHSBridgeInfo] = []
    

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var spinner: NSProgressIndicator!
    
    //MARK: Actions
    @IBAction func retryDiscoverBridges(_ sender: Any) {
        discoverBridges()
    }

    //MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up table view
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear() {
        // discover bridges
        discoverBridges()
    }
    
    /**
        discover available hue bridges with the given PHSBridgeDiscoverOption. If no discover option is
        given, then function will iterate through the avaiable discovery options and attempt to find bridges.
        If a search yields results, those results are kept. Otherwise, this method is called again with
        the next available option until all discovery options are exhausted.
    */
    func discoverBridges() {
        // show the indefinite progress indicator popover
        print("showing spinner")
        self.spinner.startAnimation(self)
//        self.label.stringValue = "Searching for bridges..."
        
        // search for bridges
        BridgeDiscoveryUtil().search({ bridges in
            self.bridges = bridges
            
            // hide the indefinite progress indicator popover
            print("stopping spinner")
            self.spinner.stopAnimation(self)
            
            // update helper text indicating next user action
//            if self.bridges.count == 0 {
//                self.label.stringValue = "No bridges were found on this network."
//            } else {
//                self.label.stringValue = "Please select a bridge to connect to."
//            }
            
            // reload table data
            self.tableView.reloadData()
        })
    }
    
    /**
        Perform a countdown from start seconds
        to 0
    */
//    func countdown(start: Int = 30) {
//        var timeRemaining: Int = start
//        let stepSize: Double = 100.0 / Double(start)
//        self.progressIndicator.startAnimation(nil)
//
//        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (timer) in
//            // decrement time remaining
//            timeRemaining -= 1
//            // increment progress indicator
//            self.progressIndicator.increment(by: stepSize)
//
//            // end of timer?
//            if timeRemaining == 0 {
//                timer.invalidate()
//                timeoutAlert()
//            }
//        }
//    }
}

/**
 Simple modal to inform users of a timeout connecting to bridge
 */
//func timeoutAlert() {
//    let alert = NSAlert()
//    alert.messageText = "Timeout connecting to bridge. Please try again"
//    alert.runModal()
//}

extension SetupViewController: NSTableViewDataSource {
    /**
     give number of rows in table view
     */
    func numberOfRows(in tableView: NSTableView) -> Int {
        return bridges.count
    }
}

extension SetupViewController: NSTableViewDelegate {
    // table cell identifiers
    fileprivate enum TableCellIdentifier {
        static let IPAddressCell = "IPAddress"
        static let UidCell = "UniqueID"
    }
    
    // return a cell for a specific value at the given row and column
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        print("getting info for a table cell")
        var cellId: String?
        var text: String = ""
        
        // select a bridge from the list using
        // the given row index
        let bridge: PHSBridgeInfo = bridges[row]
        
        // assign text value (from the bridge attributes) and
        // cell id for a particular column
        switch tableColumn {
        case tableView.tableColumns[0]?:
            text = bridge.ipAddress
            cellId = TableCellIdentifier.IPAddressCell
        case tableView.tableColumns[1]?:
            text = bridge.uid
            cellId = TableCellIdentifier.UidCell
        default:
            return nil
        }

        // create a table cell view
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellId!), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
}
