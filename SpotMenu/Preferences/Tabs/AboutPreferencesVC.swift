//
//  AboutPreferencesVC.swift
//  SpotMenu
//
//  Created by Miklós Kristyán on 2017. 12. 03..
//  Copyright © 2017. KM. All rights reserved.
//

import Cocoa

class AboutPrefState {
    var lastPressed: NSButton?
}

class AboutPrefProps {
    var buttons: [NSButton] = []
    let btc = "1Cc79kaUUWZ2fD7iFAnr5i89vb2j6JunvA"
    let eth = "0xFA06Af34fd45c0213fc909F22cA7241BBD94076f"
    let ltc = "LS3ibFQWd2xz1ByZajrzS3Y787LgRwHYVE"
}

class AboutPreferencesVC: NSViewController {

    @IBOutlet private var scrollView: NSScrollView!

    @IBOutlet private var btcButton: NSButton!
    @IBOutlet private var btcTextField: NSTextField!

    @IBOutlet private var ethButton: NSButton!
    @IBOutlet private var ethTextField: NSTextField!

    @IBOutlet private var ltcButton: NSButton!
    @IBOutlet private var ltcTextField: NSTextField!

    private var state: AboutPrefState = AboutPrefState()
    private var props: AboutPrefProps = AboutPrefProps()

    @IBOutlet var ppTextView: NSTextView!

    @IBOutlet var aboutDescTextField: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

        aboutDescTextField.stringValue = NSLocalizedString("about-description", comment: "")
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        scrollView.flashScrollers()

        props.buttons = [btcButton, ethButton, ltcButton]

        ppTextView.isEditable = true
        ppTextView.checkTextInDocument(nil)
        ppTextView.isEditable = false

        btcTextField.stringValue = props.btc
        ethTextField.stringValue = props.eth
        ltcTextField.stringValue = props.ltc

        updateFields()
    }

    @IBAction func btcButtonAction(_: Any) {
        copyToClipBoard(text: props.btc)
        state.lastPressed = btcButton
        updateFields()
    }

    @IBAction func ethButtonAction(_: Any) {
        copyToClipBoard(text: props.eth)
        state.lastPressed = ethButton
        updateFields()
    }

    @IBAction func ltcButtonAction(_: Any) {
        copyToClipBoard(text: props.ltc)
        state.lastPressed = ltcButton
        updateFields()
    }

    private func copyToClipBoard(text: String) {
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.writeObjects([text as NSString])
    }

    private func updateFields() {
        for button in props.buttons {
            if button === state.lastPressed {
                button.title = NSLocalizedString("copied", comment: "")
                button.state = .off
            } else {
                button.title = NSLocalizedString("copy", comment: "")
                button.state = .on
            }
        }
    }
}
