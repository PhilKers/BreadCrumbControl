/*

ColorPickerViewController.swift

Created by Ethan Strider on 11/28/14.

The MIT License (MIT)

Copyright (c) 2014 Ethan Strider

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

import UIKit

class ColorPickerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	// Global variables
	var tag: Int = 0
	var color: UIColor = UIColor.gray
	var delegate: ViewController? = nil
    var typeColor: String!

    private let rowCount = 16
    private let columnCount = 10
    
	// This function converts from HTML colors (hex strings of the form '#ffffff') to UIColors
	func hexStringToUIColor (_ hex:String) -> UIColor {
        var cString: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
		
		if (cString.hasPrefix("#")) {
            cString = String(cString[cString.index(cString.startIndex, offsetBy: 1)...])
		}
		
/*		if (countElements(cString) != 6) {
			return UIColor.grayColor()
		}*/
		
		var rgbValue:UInt32 = 0
		Scanner(string: cString).scanHexInt32(&rgbValue)
		
		return UIColor(
			red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
			green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
			blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
			alpha: CGFloat(1.0)
		)
	}
	
	// UICollectionViewDataSource Protocol:
	// Returns the number of rows in collection view
	internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return columnCount
	}
	// UICollectionViewDataSource Protocol:
	// Returns the number of columns in collection view
	internal func numberOfSections(in collectionView: UICollectionView) -> Int {
		return rowCount
	}
	// UICollectionViewDataSource Protocol:
	// Inilitializes the collection view cells
	internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as UICollectionViewCell
		cell.backgroundColor = UIColor.clear
		cell.tag = indexPath.section * self.columnCount + indexPath.row
		
		return cell
	}
	
	// Recognizes and handles when a collection view cell has been selected
	internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		var colorPalette: Array<String>
		
		// Get colorPalette array from plist file
		let path = Bundle.main.path(forResource: "colorPalette", ofType: "plist")
		let pListArray = NSArray(contentsOfFile: path!)
		
		if let colorPalettePlistFile = pListArray {
			colorPalette = colorPalettePlistFile as! [String]
			
			let cell: UICollectionViewCell  = collectionView.cellForItem(at: indexPath)! as UICollectionViewCell
			let hexString = colorPalette[cell.tag]
			color = hexStringToUIColor(hexString)
			self.view.backgroundColor = color
            delegate?.setButtonColor(color, typeColor:typeColor)
		}
	}
}
