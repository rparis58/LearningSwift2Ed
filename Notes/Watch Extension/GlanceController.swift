//
//  GlanceController.swift
//  Watch Extension
//
//  Created by Jon Manning on 3/11/2015.
//  Copyright © 2015 Jonathon Manning. All rights reserved.
//

import WatchKit
import Foundation


class GlanceController: WKInterfaceController {

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }

    // BEGIN glance_will_activate
    override func willActivate() {
        // This method is called when watch view controller is 
        // about to be visible to user
        updateUserActivity("au.com.secretlab.Notes.creating",
                           userInfo: ["editing":true], webpageURL: nil)
        super.willActivate()
    }
    // END glance_will_activate

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
