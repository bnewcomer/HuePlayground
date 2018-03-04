//
//  SetupViewController.swift
//  HuePlayground
//
//  Created by Benjamin Newcomer on 2/24/18.
//  Copyright © 2018 Benjamin Newcomer. All rights reserved.
//

import Cocoa

class SetupViewController: NSViewController {
    
    private enum ButtonTitle: String {
        case Connect = "Connect"
        case Retry = "Retry"
    }

    var bridges: [PHSBridgeInfo] = []
    
    //MARK: Properties
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var label: NSTextField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var button: NSButton!
    
    //MARK: Actions
    @IBAction func buttonPress(_ sender: Any) {
        switch button.title {
        case ButtonTitle.Connect.rawValue:
            // connect to the selected bridge
            connecting()
            break
        case ButtonTitle.Retry.rawValue:
            // retry discovering bridges
            searching()
            break
        default:
            return
        }
    }
    
    /**
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up table view
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    /**
    */
    override func viewDidAppear() {
        super.viewDidAppear()
        discoverBridges()
    }
    
    /**
    Starts or stop self.progressIndicator either in
    determinate or indeterminate mode.
    */
    private func switchProgressIndicator(start: Bool = true) {
        progressIndicator.isHidden = !start
        
        if start { progressIndicator.startAnimation(self) }
        else { progressIndicator.stopAnimation(self)}
        
    }
    
    /**
    */
    private func searching() {
        button.isHidden = true
        label.stringValue = "Searching for bridges..."
        switchProgressIndicator(start: true)
    }
    
    /**
    */
    private func listingBridges() {
        button.isHidden = false
        button.isEnabled = false
        button.title = ButtonTitle.Connect.rawValue
        label.stringValue = "Select a bridge to connect to."
        switchProgressIndicator(start: false)
        tableView.reloadData()
    }
    
    /**
    */
    private func bridgeSelected() {
        button.isEnabled = true
    }
    
    /**
    */
    private func noBridgesListed() {
        switchProgressIndicator(start: false)
        button.isHidden = false
        button.title = ButtonTitle.Retry.rawValue
        label.stringValue = "No bridges found"
    }
    
    /**
     */
    private func connecting() {
        // connect to bridge by passing selected bridge info
        // from the setup view back to the lights view. this
        // will trigger the dismissal of the setup view and
        // an attempted connected to the given bridge
        if let parent = self.presenting as? InfoViewController {
            parent.buildAndConnect(with: getSelectedBridgeInfo()!, sender: self)
        }
    }
    
    /**
     */
    private func getSelectedBridgeInfo() -> PHSBridgeInfo? {
        let selectedRow = tableView.selectedRow
        if selectedRow != -1 { return bridges[selectedRow] }
        else { return nil }
    }
    
    /**
    discover available hue bridges with the given PHSBridgeDiscoverOption. If no discover option is
    given, then function will iterate through the avaiable discovery options and attempt to find bridges.
    If a search yields results, those results are kept. Otherwise, this method is called again with
    the next available option until all discovery options are exhausted.
    */
    func discoverBridges() {
        searching()
        
        // search for bridges
        BridgeDiscoveryUtil().search({ bridges in
            self.bridges = bridges
            // update helper text indicating next user action
            if self.bridges.count == 0 { self.noBridgesListed() }
            else { self.listingBridges() }
        })
    }
}

/**
 */
extension SetupViewController: NSTableViewDataSource {
    /**
     give number of rows in table view
     */
    func numberOfRows(in tableView: NSTableView) -> Int {
        return bridges.count
    }
}

/**
 */
extension SetupViewController: NSTableViewDelegate {
    // table cell identifiers
    private enum TableCellIdentifier {
        static let IPAddressCell = "IPAddress"
        static let UidCell = "UniqueID"
    }

    /**
     return a cell for a specific value at the given row and column
    */
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
    
    /**
     Listen for table row selection
    */
    func tableViewSelectionDidChange(_ notification: Notification) {
        let selectedRow = tableView.selectedRow
        
        // exclude -1, which means no rows are selected
        if selectedRow >= 0 {
            bridgeSelected()
        } else {
            listingBridges()
        }
    }
}
