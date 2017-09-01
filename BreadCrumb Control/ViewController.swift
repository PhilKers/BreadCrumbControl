//
//  ViewController.swift
//  BreadCrumb Control
//
//  Created by Philippe K on 22/11/2015.
//  Copyright © 2015 Philippe K. All rights reserved.
//

import UIKit

class ViewController: UIViewController{

    @IBOutlet weak var labelAnimation: UILabel!
    @IBOutlet weak var labelOffsetItemColor: UILabel!
    @IBOutlet weak var breadCrumbControl: CBreadcrumbControl!
    @IBOutlet weak var buttonTitleColor: UIButton!
    @IBOutlet weak var buttonBreadCrumbBackgrounColor: UIButton!
    @IBOutlet weak var buttonArrowItemColor: UIButton!
    @IBOutlet weak var buttonbackgroundRootButtonColor: UIButton!
    @IBOutlet weak var buttonItemPrimaryColor: UIButton!
    
    fileprivate func setupInternalViews() {
        let animationSpeed = breadCrumbControl.animationSpeed
        labelAnimation.text = "Animation:" + String(format: "%.1f", animationSpeed)
        
        let newOffsetItemColor = CGFloat(breadCrumbControl.offsetLastPrimaryColor)
        labelOffsetItemColor.text = "Offset Color:" + String(format: "%.1f", newOffsetItemColor)
        
        buttonTitleColor.setTitleColor(breadCrumbControl.textBCColor, for: UIControlState())
        buttonArrowItemColor.setTitleColor(breadCrumbControl.arrowColor, for: UIControlState())
        buttonBreadCrumbBackgrounColor.setTitleColor(breadCrumbControl.backgroundBCColor, for: UIControlState())
        buttonbackgroundRootButtonColor.setTitleColor(breadCrumbControl.backgroundRootButtonColor, for: UIControlState())
        buttonItemPrimaryColor.setTitleColor(breadCrumbControl.itemPrimaryColor, for: UIControlState())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Override the iPhone behavior that presents a popover as fullscreen
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // Return no adaptive presentation style, use default presentation behaviour
        return .none
    }
}

// MARK: Initialize CBreadcrumbControl
extension ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // almost properties were set from Storyboard
        
        // Set delegate to handle touch inside on button
        breadCrumbControl.breadCrumbDelegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
        breadCrumbControl.buttonFont = UIFont.boldSystemFont(ofSize: 16)
        breadCrumbControl.style = .gradientFlatStyle
        
        self.setupInternalViews()
    }
}

// MARK: Set color
extension ViewController: UIPopoverPresentationControllerDelegate {
    @IBAction func setBackgroundColorBreadCrumb(_ sender: UIButton) {
        openColorPicker(sender, typeColor: "backgroundBreadCrumbColor")
    }
    
    @IBAction func setTitleColor(_ sender: UIButton) {
        openColorPicker(sender, typeColor: "titleColor")
    }

    @IBAction func setArrowItemColor(_ sender: UIButton) {
        openColorPicker(sender, typeColor: "arrowItemColor")
    }

    @IBAction func setBackgroundRootButtonColor(_ sender: UIButton) {
        openColorPicker(sender, typeColor: "backgroundRootButtonColor")
    }
    
    @IBAction func setItemPrimaryColor(_ sender: UIButton) {
        openColorPicker(sender, typeColor: "backgroundItemPrimaryColor")
    }

    private func openColorPicker(_ sender: UIButton, typeColor: String) {
        let popoverVC = storyboard?.instantiateViewController(withIdentifier: "colorPickerPopover") as! ColorPickerViewController
        popoverVC.modalPresentationStyle = .popover
        popoverVC.preferredContentSize = CGSize(width: 284, height: 446)
        popoverVC.typeColor = typeColor
        if let popoverController = popoverVC.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = CGRect(x: 0, y: 0, width: 85, height: 30)
            popoverController.permittedArrowDirections = .any
            popoverController.delegate = self
            popoverVC.delegate = self
        }
        present(popoverVC, animated: true, completion: nil)
    }

    // Called from ColorPickerViewController
    func setButtonColor(_ color: UIColor, typeColor: String) {
        if (typeColor == "titleColor") {
            buttonTitleColor.setTitleColor(color, for: UIControlState())
            breadCrumbControl.textBCColor = color
        }
        else if (typeColor == "arrowItemColor") {
            buttonArrowItemColor.setTitleColor(color, for: UIControlState())
            breadCrumbControl.arrowColor = color
        }
        else if (typeColor == "backgroundBreadCrumbColor") {
            buttonBreadCrumbBackgrounColor.setTitleColor(color, for: UIControlState())
            breadCrumbControl.backgroundBCColor = color
        }
        else if (typeColor == "backgroundRootButtonColor") {
            buttonbackgroundRootButtonColor.setTitleColor(color, for: UIControlState())
            breadCrumbControl.backgroundRootButtonColor = color
        }
        else if (typeColor == "backgroundItemPrimaryColor") {
            buttonItemPrimaryColor.setTitleColor(color, for: UIControlState())
            breadCrumbControl.itemPrimaryColor = color
        }
    }
}

// MARK: Update items
extension ViewController {
    @IBAction func setConfig(_ sender: AnyObject) {
        breadCrumbControl.itemsBreadCrumb = ["Config"]
    }

    @IBAction func setConfigOutputRelay(_ sender: AnyObject) {
        breadCrumbControl.itemsBreadCrumb = ["Config", "Output", "Relay"]
    }
    
    @IBAction func setConfigAlarm(_ sender: AnyObject) {
        breadCrumbControl.itemsBreadCrumb = ["Config", "Alarm"]
    }
    
    @IBAction func setConfigAlarmDetector(_ sender: AnyObject) {
        breadCrumbControl.itemsBreadCrumb = ["Config", "Alarm", "Detector"]

    }
    
    @IBAction func setConfigAlarmDetectorKitchen(_ sender: AnyObject) {
        breadCrumbControl.itemsBreadCrumb = ["Config", "Alarm", "Detector", "Kitchen"]
    }
    
    @IBAction func setConfigVeryLong(_ sender: Any) {
        breadCrumbControl.itemsBreadCrumb = [
            "Config",
            "Alarm",
            "Detector",
            "Kitchen",
            "White color second refrigerator",
            "Very tasty ale beer"
        ]
    }
    
    @IBAction func setConsultation(_ sender: AnyObject) {
        breadCrumbControl.itemsBreadCrumb = ["Consultation"]
    }
    
    @IBAction func setClear(_ sender: AnyObject) {
        breadCrumbControl.itemsBreadCrumb = []
    }
}

// MARK: other setting values
extension ViewController {
    @IBAction func setRootButtonVisible(_ sender: AnyObject) {
        let switchRootButton = sender as! UISwitch
        breadCrumbControl.visibleRootButton = switchRootButton.isOn
    }
    
    @IBAction func setGradientStyleChange(_ sender: AnyObject) {
        let gradientStyle = sender as! UISwitch
        breadCrumbControl.style = gradientStyle.isOn ? .gradientFlatStyle : .defaultFlatStyle
    }
    
    @IBAction func setValueChanged(_ sender: AnyObject) {
        let timeAnimation = sender as! UIStepper
        let newTimeAnimation = timeAnimation.value * 0.1
        breadCrumbControl.animationSpeed = newTimeAnimation
        labelAnimation.text = "Animation:" + String(format: "%.1f", newTimeAnimation)
    }
    
    @IBAction func setOffsetItemColor(_ sender: AnyObject) {
        let offsetItemColor = sender as! UIStepper
        let newOffsetItemColor = CGFloat(offsetItemColor.value)
        breadCrumbControl.offsetLastPrimaryColor = newOffsetItemColor
        labelOffsetItemColor.text = "Offset Color:" + String(format: "%.1f", newOffsetItemColor)
    }
}

// MARK: BreadCrumbControlDelegate
extension ViewController: BreadCrumbControlDelegate {
    func didTouchItem(index: Int, item: String) {
        let alertView = UIAlertView();
        alertView.addButton(withTitle: "OK")
        alertView.title = "Item touched"
        alertView.message = "\(item) (index= \(index))"
        alertView.show()
    }
    
    func didTouchRootButton() {
        let alertView = UIAlertView();
        alertView.addButton(withTitle: "OK")
        alertView.title = "Root button touched"
        alertView.show()
    }
}

