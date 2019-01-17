//
//  PopOverViewControllerExtension.swift
//  SpotMenu
//
//  Created by Daniel Tombor on 2017. 09. 06..
//  Copyright © 2017. KM. All rights reserved.
//

import Cocoa
import Foundation
import NotificationCenter

extension PopOverViewController: NCWidgetProviding {

    // MARK: - Properties

    override var nibName: NSNib.Name? {
        return NSNib.Name(rawValue: "PopOver")
    }

    // MARK: - Public methods

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Update your data and prepare for a snapshot. Call completion handler when you are done
        // with NoData if nothing has changed or NewData if there is new data since the last
        // time we called you
        completionHandler(.noData)
    }
}
