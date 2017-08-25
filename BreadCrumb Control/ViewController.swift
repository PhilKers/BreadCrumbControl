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

        buttonTitleColor.setTitleColor(breadCrumbControl.textBCColor, for:UIControlState())
        buttonArrowItemColor.setTitleColor(breadCrumbControl.arrowColor, for:UIControlState())
        buttonBreadCrumbBackgrounColor.setTitleColor(breadCrumbControl.backgroundBCColor, for:UIControlState())
        buttonbackgroundRootButtonColor.setTitleColor(breadCrumbControl.backgroundRootButtonColor, for:UIControlState())
        buttonItemPrimaryColor.setTitleColor(breadCrumbControl.itemPrimaryColor, for:UIControlState())

        breadCrumbControl.breadCrumbDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        breadCrumbControl.visibleRootButton = false
        breadCrumbControl.itemsBreadCrumb = []
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
    
    @IBAction func setBackgroundColorBreadCrumb(_ sender: UIButton) {
        openColorPicker (sender, typeColor: "backgroundBreadCrumbColor")
    }
    
    @IBAction func setTitleColor(_ sender: UIButton) {
        openColorPicker (sender, typeColor: "titleColor")
    }

    @IBAction func setArrowItemColor(_ sender: UIButton) {
        openColorPicker (sender, typeColor: "arrowItemColor")
    }

    @IBAction func setBackgroundRootButtonColor(_ sender: UIButton) {
        openColorPicker (sender, typeColor: "backgroundRootButtonColor")
    }
    
    @IBAction func setItemPrimaryColor(_ sender: UIButton) {
        openColorPicker (sender, typeColor: "backgroundItemPrimaryColor")
    }
    func openColorPicker (_ sender: UIButton, typeColor: String) {
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

    
    func setButtonColor (_ color: UIColor, typeColor: String) {
        if (typeColor == "titleColor") {
            buttonTitleColor.setTitleColor(color, for:UIControlState())
            breadCrumbControl.textBCColor = color
        }
        else if (typeColor == "arrowItemColor") {
            buttonArrowItemColor.setTitleColor(color, for:UIControlState())
            breadCrumbControl.arrowColor = color
        }
        else if (typeColor == "backgroundBreadCrumbColor") {
            buttonBreadCrumbBackgrounColor.setTitleColor(color, for:UIControlState())
            breadCrumbControl.backgroundBCColor = color
        }
        else if (typeColor == "backgroundRootButtonColor") {
            buttonbackgroundRootButtonColor.setTitleColor(color, for:UIControlState())
            breadCrumbControl.backgroundRootButtonColor = color
        }
        else if (typeColor == "backgroundItemPrimaryColor") {
            buttonItemPrimaryColor.setTitleColor(color, for:UIControlState())
            breadCrumbControl.itemPrimaryColor = color
        }

    }

    
    @IBAction func setConfig(_ sender: AnyObject) {
        breadCrumbControl.itemsBreadCrumb = ["Config"]
    }

    @IBAction func setConfigOutputRelay(_ sender: AnyObject) {
        breadCrumbControl.itemsBreadCrumb = ["Config","Output","Relay"]
    }
    
    @IBAction func setConfigAlarm(_ sender: AnyObject) {
        breadCrumbControl.itemsBreadCrumb = ["Config","Alarm"]
    }
    
    @IBAction func setConfigAlarmDetector(_ sender: AnyObject) {
        breadCrumbControl.itemsBreadCrumb = ["Config","Alarm","Detector"]

    }
    
    @IBAction func setConfigAlarmDetectorKitchen(_ sender: AnyObject) {
        breadCrumbControl.itemsBreadCrumb = ["Config","Alarm","Detector","Kitchen"]
    }
    
    @IBAction func setConfigVeryLong(_ sender: Any) {
        breadCrumbControl.itemsBreadCrumb = ["Config","Alarm","Detector","Kitchen","White color second refrigerator","Very tasty ale beer"]
    }
    
    @IBAction func setConsultation(_ sender: AnyObject) {
        breadCrumbControl.itemsBreadCrumb = ["Consultation"]
    }
    
    @IBAction func setClear(_ sender: AnyObject) {
        breadCrumbControl.itemsBreadCrumb = []
    }

    @IBAction func setRootButtonVisible(_ sender: AnyObject) {
        let switchRootButton: UISwitch = sender as! UISwitch
        breadCrumbControl.visibleRootButton = switchRootButton.isOn
    }
    
    @IBAction func setGradientStyleChange(_ sender: AnyObject) {
        let gradientStyle: UISwitch = sender as! UISwitch
        breadCrumbControl.style = (gradientStyle.isOn) ? .gradientFlatStyle : .defaultFlatStyle
    }
    
    @IBAction func setValueChanged(_ sender: AnyObject) {
        let timeAnimation: UIStepper = sender as! UIStepper
        //var animationSpeed: Double = breadCrumbControl.animationSpeed
        let newTimeAnimation: Double = timeAnimation.value * 0.1
        breadCrumbControl.animationSpeed = newTimeAnimation
        labelAnimation.text = "Animation:" + String(format:"%.1f", newTimeAnimation)
     }
    
    @IBAction func setOffsetItemColor(_ sender: AnyObject) {
        let offsetItemColor: UIStepper = sender as! UIStepper
        //var animationSpeed: Double = breadCrumbControl.animationSpeed
        let newOffsetItemColor: CGFloat = CGFloat(offsetItemColor.value)
        breadCrumbControl.offsetLastPrimaryColor = newOffsetItemColor
        labelOffsetItemColor.text = "Offset Color:" + String(format:"%.1f", newOffsetItemColor)
    }
}

extension UIViewController: BreadCrumbControlDelegate {
    func buttonPressed(index: Int, item: String) {
        let msgPosition: String = " (position=" + String(index) + ")"
        
        let alertView = UIAlertView();
        alertView.addButton(withTitle: "Ok");
        alertView.title = "item selected:";
        var message: String = (item == "") ? "Button Root" : item
        message += (item == "") ? "" : msgPosition
        alertView.message = message
        alertView.show();
    }
}

