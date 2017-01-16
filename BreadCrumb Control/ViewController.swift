//
//  ViewController.swift
//  BreadCrumb Control
//
//  Created by Philippe K on 22/11/2015.
//  Copyright © 2015 Philippe K. All rights reserved.
//

import UIKit

class ViewController: UIViewController , UIPopoverPresentationControllerDelegate{

    @IBOutlet weak var labelAnimation: UILabel!
    @IBOutlet weak var labelOffsetItemColor: UILabel!
    @IBOutlet weak var breadCrumbControl: CBreadcrumbControl!
    
    @IBOutlet weak var buttonTitleColor: UIButton!
    
    @IBOutlet weak var buttonBreadCrumbBackgrounColor: UIButton!
    
    @IBOutlet weak var buttonArrowItemColor: UIButton!
    
    @IBOutlet weak var buttonbackgroundRootButtonColor: UIButton!
    
    @IBOutlet weak var buttonItemPrimaryColor: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        breadCrumbControl.animationSpeed = 0.2
        let animationSpeed: Double = breadCrumbControl.animationSpeed
        labelAnimation.text = "Animation:" + String(format:"%.1f", animationSpeed)
        
        let newOffsetItemColor: CGFloat = CGFloat(breadCrumbControl.offsetLastPrimaryColor)
        labelOffsetItemColor.text = "Offset Color:" + String(format:"%.1f", newOffsetItemColor)

        buttonTitleColor.setTitleColor(breadCrumbControl.textBCColor, forState:UIControlState.Normal)
        buttonArrowItemColor.setTitleColor(breadCrumbControl.arrowColor, forState:UIControlState.Normal)
        buttonBreadCrumbBackgrounColor.setTitleColor(breadCrumbControl.backgroundBCColor, forState:UIControlState.Normal)
        buttonbackgroundRootButtonColor.setTitleColor(breadCrumbControl.backgroundRootButtonColor, forState:UIControlState.Normal)
        buttonItemPrimaryColor.setTitleColor(breadCrumbControl.itemPrimaryColor, forState:UIControlState.Normal)

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        breadCrumbControl.visibleRootButton = false
        breadCrumbControl.itemsBreadCrumb = []
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Override the iPhone behavior that presents a popover as fullscreen
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController!) -> UIModalPresentationStyle {
        // Return no adaptive presentation style, use default presentation behaviour
        return .None
    }
    
    @IBAction func setBackgroundColorBreadCrumb(sender: UIButton) {
        openColorPicker (sender, typeColor: "backgroundBreadCrumbColor")
    }
    
    @IBAction func setTitleColor(sender: UIButton) {
        openColorPicker (sender, typeColor: "titleColor")
    }

    @IBAction func setArrowItemColor(sender: UIButton) {
        openColorPicker (sender, typeColor: "arrowItemColor")
    }

    @IBAction func setBackgroundRootButtonColor(sender: UIButton) {
        openColorPicker (sender, typeColor: "backgroundRootButtonColor")
    }
    
    @IBAction func setItemPrimaryColor(sender: UIButton) {
        openColorPicker (sender, typeColor: "backgroundItemPrimaryColor")
    }
    func openColorPicker (sender: UIButton, typeColor: String) {
        let popoverVC = storyboard?.instantiateViewControllerWithIdentifier("colorPickerPopover") as! ColorPickerViewController
        popoverVC.modalPresentationStyle = .Popover
        popoverVC.preferredContentSize = CGSizeMake(284, 446)
        popoverVC.typeColor = typeColor
        if let popoverController = popoverVC.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = CGRect(x: 0, y: 0, width: 85, height: 30)
            popoverController.permittedArrowDirections = .Any
            popoverController.delegate = self
            popoverVC.delegate = self
        }
        presentViewController(popoverVC, animated: true, completion: nil)
    }

    
    func setButtonColor (color: UIColor, typeColor: String) {
        if (typeColor == "titleColor") {
            buttonTitleColor.setTitleColor(color, forState:UIControlState.Normal)
            breadCrumbControl.textBCColor = color
        }
        else if (typeColor == "arrowItemColor") {
            buttonArrowItemColor.setTitleColor(color, forState:UIControlState.Normal)
            breadCrumbControl.arrowColor = color
        }
        else if (typeColor == "backgroundBreadCrumbColor") {
            buttonBreadCrumbBackgrounColor.setTitleColor(color, forState:UIControlState.Normal)
            breadCrumbControl.backgroundBCColor = color
        }
        else if (typeColor == "backgroundRootButtonColor") {
            buttonbackgroundRootButtonColor.setTitleColor(color, forState:UIControlState.Normal)
            breadCrumbControl.backgroundRootButtonColor = color
        }
        else if (typeColor == "backgroundItemPrimaryColor") {
            buttonItemPrimaryColor.setTitleColor(color, forState:UIControlState.Normal)
            breadCrumbControl.itemPrimaryColor = color
        }

    }

    
    @IBAction func setConfig(sender: AnyObject) {
        breadCrumbControl.itemsBreadCrumb = ["Config"]
    }

    @IBAction func setConfigOutputRelay(sender: AnyObject) {
        breadCrumbControl.itemsBreadCrumb = ["Config","Output","Relay"]
    }
    
    @IBAction func setConfigAlarm(sender: AnyObject) {
        breadCrumbControl.itemsBreadCrumb = ["Config","Alarm"]
    }
    
    @IBAction func setConfigAlarmDetector(sender: AnyObject) {
        breadCrumbControl.itemsBreadCrumb = ["Config","Alarm","Detector"]

    }
    
    @IBAction func setConfigAlarmDetectorKitchen(sender: AnyObject) {
        breadCrumbControl.itemsBreadCrumb = ["Config","Alarm","Detector","Kitchen"]
    }
    
    @IBAction func setConsultation(sender: AnyObject) {
        breadCrumbControl.itemsBreadCrumb = ["Consultation"]
    }
    
    @IBAction func setClear(sender: AnyObject) {
        breadCrumbControl.itemsBreadCrumb = []
    }
    
    @IBAction func itemSelectedByTouch(sender: AnyObject) {
        let breadcrumbView: CBreadcrumbControl = sender as! CBreadcrumbControl
        let selected: String = breadcrumbView.itemClicked
        let indexSelected: Int = breadcrumbView.itemPositionClicked
        let msgPosition: String = " (position=" + String(indexSelected) + ")"
        
        let alertView = UIAlertView();
        alertView.addButtonWithTitle("Ok");
        alertView.title = "item selected:";
        var message: String = (selected == "") ? "Button Root" : selected
        message += (selected == "") ? "" : msgPosition
        alertView.message = message
        alertView.show();
    }
    @IBAction func setRootButtonVisible(sender: AnyObject) {
        let switchRootButton: UISwitch = sender as! UISwitch
        breadCrumbControl.visibleRootButton = switchRootButton.on
    }
    
    @IBAction func setGradientStyleChange(sender: AnyObject) {
        let gradientStyle: UISwitch = sender as! UISwitch
        breadCrumbControl.style = (gradientStyle.on) ? .gradientFlatStyle : .defaultFlatStyle
    }
    
    @IBAction func setValueChanged(sender: AnyObject) {
        let timeAnimation: UIStepper = sender as! UIStepper
        //var animationSpeed: Double = breadCrumbControl.animationSpeed
        let newTimeAnimation: Double = timeAnimation.value * 0.1
        breadCrumbControl.animationSpeed = newTimeAnimation
        labelAnimation.text = "Animation:" + String(format:"%.1f", newTimeAnimation)
     }
    
    @IBAction func setOffsetItemColor(sender: AnyObject) {
        let offsetItemColor: UIStepper = sender as! UIStepper
        //var animationSpeed: Double = breadCrumbControl.animationSpeed
        let newOffsetItemColor: CGFloat = CGFloat(offsetItemColor.value)
        breadCrumbControl.offsetLastPrimaryColor = newOffsetItemColor
        labelOffsetItemColor.text = "Offset Color:" + String(format:"%.1f", newOffsetItemColor)
    }
}

