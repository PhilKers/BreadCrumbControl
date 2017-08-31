# BreadCrumbControl
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

BreadCrumb Control for iOS written in Swift.

![animatedsample](https://user-images.githubusercontent.com/3298414/29718787-d5afe59c-89ee-11e7-8a03-88c92656265e.gif)
![sample](https://cloud.githubusercontent.com/assets/16086042/11485915/14c29ff4-97b6-11e5-9674-ff2c83a675e9.jpg)

The properties of "BreadCrumb" are fully accessible for the developer: color, animation, etc.
This control is provided with a sample application that lets you change the properties of the control in real-time.


# Compatibility

This control is compatible with iOS 8. Swift 3.0 compatible.


# Installation in Xcode project

It is a very easy control to include in your project.

## Manually

Add to your iOS project: `BreadCrumb.swift`, `CustomButton.swift`, `BreadCrumbs.xcassets`.

## CocoaPods

[CocoaPods](http://cocoapods.org/) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate this into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
platform :ios, '8.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'BreadCrumbControl'
end
```

## Carthage

BreadCrumbControl is [Carthage](https://github.com/Carthage/Carthage/) compatible.
Add the following into your `Cartfile`, then run `carthage update`.

```
github "apparition47/BreadCrumbControl"
```

# Usage

In order to use BreadCrumb control, you can instantiate it programmatically, or create a custom view in Interface Builder and assign it to an ivar of your app. Once you have an instance, you can use the control properties to configure it.
See `ViewController.swift` for detail code.

```swift
import BreadCrumbControl // if using CocoaPods or Carthage 

class ViewController: UIViewController {
	@IBOutlet weak var breadcrumbControl: CBreadcrumbControl!
	override func viewDidLoad() {
        self.breadcrumbView.delegate = self

        self.breadcrumbView.buttonFont = UIFont.boldSystemFont(ofSize: 16)
        self.breadcrumbView.style = .gradientFlatStyle
		self.breadcrumbView.itemsBreadCrumb = ["Config", "Alarm"]
	}
}

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
```


# Screenshots

![sampleapplication](https://cloud.githubusercontent.com/assets/16086042/11486079/09e7d904-97b7-11e5-9cd5-e0a7e4888bfe.jpg)

# Credits

For the sample application I use the control "ColorPickerView", created by Ethan Strider on 11/28/14. This control allowed me to easily change the colors in the sample application.

The BreadCrumb and the sample application have been created by Philippe Kersalé.

Root button icon is from the MIT-licensed [ionicons](http://ionicons.com).

# License

BSD
