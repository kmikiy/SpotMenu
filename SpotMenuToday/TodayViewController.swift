//
//  TodayViewController.swift
//  SpotMenuToday
//
//  Created by Miklós Kristyán on 2017. 07. 16..
//  Copyright © 2017. KM. All rights reserved.
//

import Cocoa
import NotificationCenter
import Spotify

class TodayViewController: NSViewController, NCWidgetProviding {

    @IBOutlet weak var popOver: PopOver!
    override var nibName: String? {
        return "TodayViewController"
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Update your data and prepare for a snapshot. Call completion handler when you are done
        // with NoData if nothing has changed or NewData if there is new data since the last
        // time we called you
        completionHandler(.noData)
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        
        popOver.updateInfo()
        NotificationCenter.default.addObserver(self, selector: #selector(TodayViewController.updateInfo), name: NSNotification.Name(rawValue: InternalNotification.key), object: nil)
        
        popOver.timer = Timer.scheduledTimer(timeInterval: 0.8, target: self, selector: #selector(TodayViewController.postUpdateNotification), userInfo: nil, repeats: true)
    }
    
    func postUpdateNotification(){
        NotificationCenter.default.post(name: Notification.Name(rawValue: InternalNotification.key), object: self)
    }
    
    
    func updateInfo(){
        popOver.updateInfo()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popOver.defaultImage = popOver.artworkImageView.image
        
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        NotificationCenter.default.removeObserver(self)
        popOver.timer.invalidate()
    }


}
