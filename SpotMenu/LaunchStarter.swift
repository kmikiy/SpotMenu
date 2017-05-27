//
//  LaunchStarter.swift
//  SpotMenu
//
//  Created by Miklós Kristyán on 2017. 05. 21..
//  Copyright © 2017. KM. All rights reserved.
//

import Foundation

func applicationIsInStartUpItems() -> Bool {
    return (itemReferencesInLoginItems().existingReference != nil)
}

func itemReferencesInLoginItems() -> (existingReference: LSSharedFileListItem?, lastReference: LSSharedFileListItem?) {
    let appURL : NSURL = NSURL.fileURL(withPath: Bundle.main.bundlePath) as NSURL
    if let loginItemsRef = LSSharedFileListCreate(nil, kLSSharedFileListSessionLoginItems.takeRetainedValue(), nil).takeRetainedValue() as LSSharedFileList? {
        
        let loginItems: NSArray = LSSharedFileListCopySnapshot(loginItemsRef, nil).takeRetainedValue() as NSArray
        let lastItemRef: LSSharedFileListItem = loginItems.lastObject as! LSSharedFileListItem
        
        for (index,_) in loginItems.enumerated() {
            let currentItemRef: LSSharedFileListItem = loginItems.object(at: index) as! LSSharedFileListItem
            if let itemURL = LSSharedFileListItemCopyResolvedURL(currentItemRef, 0, nil) {
                if (itemURL.takeRetainedValue() as NSURL).isEqual(appURL) {
                    return (currentItemRef, lastItemRef)
                }
            }
        }
        
        return (nil, lastItemRef)
    }
    
    
    return (nil, nil)
}

func toggleLaunchAtStartup() {
    let itemReferences = itemReferencesInLoginItems()
    let shouldBeToggled = (itemReferences.existingReference == nil)
    if let loginItemsRef = LSSharedFileListCreate( nil, kLSSharedFileListSessionLoginItems.takeRetainedValue(), nil).takeRetainedValue() as LSSharedFileList? {
        if shouldBeToggled {
            let appUrl : CFURL = NSURL.fileURL(withPath: Bundle.main.bundlePath) as CFURL
            print("Add login item")
            LSSharedFileListInsertItemURL(loginItemsRef, itemReferences.lastReference, nil, nil, appUrl, nil, nil)
            
        } else {
            if let itemRef = itemReferences.existingReference {
                print("Remove login item")
                LSSharedFileListItemRemove(loginItemsRef,itemRef);
            }
        }
    }
}
