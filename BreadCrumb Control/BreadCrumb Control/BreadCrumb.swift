//
//  Copyright 2015 Philippe Kersalé
//

import UIKit

let kStartButtonWidth:CGFloat = 44
let kBreadcrumbHeight:CGFloat = 44
let kBreadcrumbCover:CGFloat = 15


enum OperatorItem {
    case addItem
    case removeItem
}

enum StyleBreadCrumb {
    case defaultFlatStyle
    case gradientFlatStyle
}

class ItemEvolution {
    var itemLabel: String = ""
    var operationItem: OperatorItem = OperatorItem.addItem
    var offsetX: CGFloat = 0.0
    init(itemLabel: String, operationItem: OperatorItem, offsetX: CGFloat) {
        self.itemLabel = itemLabel
        self.operationItem = operationItem
        self.offsetX = offsetX
    }
}

class EventItem {
    var itemsEvolution: [ItemEvolution]!
}



@IBDesignable class CBreadcrumbControl: UIControl{
    
    
    var _items: [String] = []
    var _itemViews: [UIButton] = []

    var containerView: UIView!
    var startButton: UIButton!
    
    var color: UIColor = UIColor.blueColor()
    private var _animating: Bool = false
   
    private var animationInProgress: Bool = false
    
    // used if you send a new itemsBreadCrumb when "animationInProgress == true"
    private var itemsBCInWaiting: Bool = false

    // item selected
    var itemClicked: String!
    var itemPositionClicked: Int = -1

    func register() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedUINotificationNewItems:", name:"NotificationNewItems", object: nil)
    }
    
    
    @IBInspectable var style: StyleBreadCrumb = .gradientFlatStyle {
        didSet{
            initialSetup( true)
        }
    }
    
    
    @IBInspectable var visibleRootButton: Bool = true {
        didSet{
            initialSetup( true)
        }
    }
    
    
    @IBInspectable var textBCColor: UIColor = UIColor.blackColor() {
        didSet{
            initialSetup( true)
        }
    }
    
    @IBInspectable var backgroundRootButtonColor: UIColor = UIColor.whiteColor() {
        didSet{
            initialSetup( true)
        }
    }
    
    @IBInspectable var backgroundBCColor: UIColor = UIColor.clearColor() {
        didSet{
            initialSetup( true)
        }
    }
    
    @IBInspectable var itemPrimaryColor: UIColor = UIColor.grayColor() {
        didSet{
            initialSetup( true)
        }
    }
    
    @IBInspectable var offsetLastPrimaryColor: CGFloat = 16.0 {
        didSet{
            initialSetup( true)
        }
    }
    
    
    @IBInspectable var animationSpeed: Double = 0.2 {
        didSet{
            initialSetup( true)
        }
    }
    
    
    @IBInspectable var arrowColor: UIColor = UIColor.blueColor() {
        didSet{
            //drawRect( self.frame)
            initialSetup( true)
        }
    }

    
    @IBInspectable var itemsBreadCrumb: [String] = [] {
        didSet{
            if (!self.animationInProgress) {
                self.itemClicked = ""
                self.itemPositionClicked = -1
                initialSetup( false)
            } else {
                itemsBCInWaiting = true
            }
        }
    }
    
    @IBInspectable var iconSize: CGSize = CGSizeMake(20, 20){
        didSet{
            //setNeedsDisplay()
            initialSetup( true)
        }
    }
    

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        register()
        initialSetup( true)
    }
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup( true)
    }

    
    func initialSetup( refresh: Bool) {
        
        var changeRoot: Int = 0
        if ((visibleRootButton) && (self.startButton == nil)) {
            self.startButton = self.startRootButton()
            changeRoot = 1
        } else if ((visibleRootButton == false) && (self.startButton != nil)){
            changeRoot = 2
        }
        if (self.containerView == nil ) {
            let rectContainerView: CGRect = CGRectMake( kStartButtonWidth+1, 0, self.bounds.size.width - (kStartButtonWidth+1), kBreadcrumbHeight)
            self.containerView = UIView(frame:rectContainerView)
            self.containerView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            
            self.addSubview( self.containerView)
        }

        self.containerView.backgroundColor = backgroundBCColor  //UIColor.whiteColor()
        self.containerView.clipsToBounds = true
        if ((visibleRootButton) && (self.startButton != nil)) {
            self.startButton.backgroundColor = backgroundRootButtonColor
        }
        
        if (changeRoot == 1) {
            self.addSubview( self.startButton)
            let rectContainerView: CGRect = CGRectMake( kStartButtonWidth+1, 0, self.bounds.size.width - (kStartButtonWidth+1), kBreadcrumbHeight)
            self.containerView.frame = rectContainerView
        } else if (changeRoot == 2) {
            self.startButton.removeFromSuperview()
            self.startButton = nil
            let rectContainerView: CGRect = CGRectMake( 0, 0, self.bounds.size.width, kBreadcrumbHeight)
            self.containerView.frame = rectContainerView
        }
        
        self.setItems( self.itemsBreadCrumb, refresh: refresh, containerView: self.containerView)
            
    }


    func startRootButton() -> UIButton
    {
        let button: UIButton = UIButton(type: UIButtonType.Custom) as UIButton
        button.backgroundColor = backgroundRootButtonColor
        let bgImage : UIImage = UIImage( named: "button_start.png")!
        button.setBackgroundImage( bgImage, forState: UIControlState.Normal)
        button.frame = CGRectMake(0, 0, kStartButtonWidth+1, kBreadcrumbHeight)
        button.addTarget(self, action: "pressed:", forControlEvents: .TouchUpInside)

        return button
    }
    
    func itemButton( item: String, position: Int) -> MyCustomButton
    {
        let button: MyCustomButton = MyCustomButton() as MyCustomButton
        if (self.style == .gradientFlatStyle) {
            button.styleButton = .extendButton
            var rgbValueTmp = CGColorGetComponents(self.itemPrimaryColor.CGColor)
            var red = rgbValueTmp[0]
            var green = rgbValueTmp[1]
            var blue = rgbValueTmp[2]
            //var rgbValue: Double = Double(rgbValueTmp)
            //var rgbValue = 0x777777
            //let rPrimary:CGFloat = CGFloat((rgbValue & 0xFF0000) >> 16)/255.0
            //let gPrimary:CGFloat = CGFloat((rgbValue & 0xFF00) >> 8)/255.0
            //let bPrimary:CGFloat = CGFloat((rgbValue & 0xFF))/255.0
            let rPrimary:CGFloat = CGFloat(red * 255.0)
            let gPrimary:CGFloat = CGFloat(green * 255.0)
            let bPrimary:CGFloat = CGFloat(blue * 255.0)

            
            let levelRedPrimaryColor: CGFloat = rPrimary + (self.offsetLastPrimaryColor * CGFloat(position))
            let levelGreenPrimaryColor: CGFloat = gPrimary + (self.offsetLastPrimaryColor * CGFloat(position))
            let levelBluePrimaryColor: CGFloat = bPrimary + (self.offsetLastPrimaryColor * CGFloat(position))
            let r = levelRedPrimaryColor/255.0
            let g = levelGreenPrimaryColor/255.0
            let b = levelBluePrimaryColor/255.0
            button.backgroundCustomColor =  UIColor(red:CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: 1.0)
        } else {
            button.styleButton = .simpleButton
            button.backgroundCustomColor = self.backgroundBCColor  //self.backgroundItemColor
            button.arrowColor = self.arrowColor
        }
        button.contentMode = UIViewContentMode.Center
        button.titleLabel!.font = UIFont.boldSystemFontOfSize(16)
        button.setTitle(item, forState:UIControlState.Normal)
        button.setTitleColor( textBCColor, forState: UIControlState.Normal)
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        
        button.sizeToFit()
        let rectButton:CGRect = button.frame
        let widthButton: CGFloat = (position > 0) ? rectButton.width + 32 + kBreadcrumbCover : rectButton.width + 32
        button.frame = CGRectMake(0, 0, widthButton , kBreadcrumbHeight)
        button.titleEdgeInsets = (position > 0) ? UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0) : UIEdgeInsets(top: 0.0, left: -kBreadcrumbCover, bottom: 0.0, right: 0.0)
        button.addTarget(self, action: "pressed:", forControlEvents: .TouchUpInside)
        
        return button
    }
    
    
    
    func pressed(sender: UIButton!) {
        let titleSelected = sender.titleLabel?.text
        if ((self.startButton != nil) && (self.startButton == sender)) {
            self.itemClicked = ""
            self.itemPositionClicked = 0
        } else {
            self.itemClicked = titleSelected
            for ( var idx: Int = 0; idx < _items.count; idx++) {
                if (titleSelected == _items[idx]) {
                    self.itemPositionClicked = idx + 1
                }
            }
        }
        self.sendActionsForControlEvents( UIControlEvents.TouchUpInside)
        
        /*
        let alertView = UIAlertView();
        alertView.addButtonWithTitle("Ok");
        alertView.title = "title";
        alertView.message = "message";
        alertView.show();
        */
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        var cx: CGFloat = 0  //kStartButtonWidth
        for var view: UIView in _itemViews
        {
            var s: CGSize = view.bounds.size
            view.frame = CGRectMake(cx, 0, s.width, s.height)
            cx += s.width
        }
        initialSetup( true)
    }
    
    
    func singleLayoutSubviews( view: UIView, offsetX: CGFloat) {
        super.layoutSubviews()
        
        var s: CGSize = view.bounds.size
        view.frame = CGRectMake(offsetX, 0, s.width, s.height)
    }
    
    
    func setItems(items: [String], refresh: Bool, containerView: UIView) {
        self.animationInProgress = true

        if (self._animating) {
            return
        }
        if (!refresh)
        {
            var itemsEvolution: [ItemEvolution] = [ItemEvolution]()
            // comparer with old items search the difference
            var endPosition: CGFloat = 0.0
            var idxToChange: Int = 0
            for ( var idx: Int = 0; idx < _items.count; idx++) {
                if ((idx < items.count) && (_items[idx] == items[idx])) {
                    idxToChange++
                    endPosition += _itemViews[idx].frame.width
                    continue
                } else {
                    endPosition -= _itemViews[idx].frame.width
                    if (itemsEvolution.count > idx) {
                    itemsEvolution.insert( ItemEvolution( itemLabel: items[idx], operationItem: OperatorItem.removeItem, offsetX: endPosition), atIndex: idxToChange)
                    } else {
                        itemsEvolution.append(ItemEvolution( itemLabel: _items[idx], operationItem: OperatorItem.removeItem, offsetX: endPosition))
                    }
                }
            }
            for ( var idx: Int = idxToChange; idx < items.count; idx++) {
                itemsEvolution.append( ItemEvolution( itemLabel: items[idx], operationItem: OperatorItem.addItem, offsetX: endPosition))
            }
            
            processItem( itemsEvolution, refresh: false)
        } else {
            self.animationInProgress = false
 
            var itemsEvolution: [ItemEvolution] = [ItemEvolution]()
            // comparer with old items search the difference
            let endPosition: CGFloat = 0.0
            for ( var idx: Int = 0; idx < _items.count; idx++) {
                itemsEvolution.append( ItemEvolution( itemLabel: items[idx], operationItem: OperatorItem.removeItem, offsetX: endPosition))
            }
            for ( var idx: Int = 0; idx < items.count; idx++) {
                itemsEvolution.append( ItemEvolution( itemLabel: items[idx], operationItem: OperatorItem.addItem, offsetX: endPosition))
            }
            processItem( itemsEvolution, refresh: true)
        }
    }
    
    
    func processItem( itemsEvolution: [ItemEvolution], refresh: Bool) {
        //    _itemViews
        if (itemsEvolution.count > 0) {
            var itemsEvolutionToSend: [ItemEvolution] = [ItemEvolution]()
            for ( var idx: Int = 1; idx < itemsEvolution.count; idx++) {
                itemsEvolutionToSend.append( ItemEvolution( itemLabel: itemsEvolution[idx].itemLabel, operationItem: itemsEvolution[idx].operationItem, offsetX: itemsEvolution[idx].offsetX))
            }
            
            if (itemsEvolution[0].operationItem == OperatorItem.addItem) {
                //create a new UIButton
                var startPosition: CGFloat = 0
                var endPosition: CGFloat = 0
                if (_itemViews.count > 0) {
                    let indexTmp = _itemViews.count - 1
                    let lastViewShowing: UIView = _itemViews[indexTmp]
                    let rectLastViewShowing: CGRect = lastViewShowing.frame
                    endPosition = rectLastViewShowing.origin.x + rectLastViewShowing.size.width - kBreadcrumbCover
                }
                let label = itemsEvolution[0].itemLabel
                let itemButton: UIButton = self.itemButton( label, position: _itemViews.count)
                let widthButton: CGFloat = itemButton.frame.size.width
                startPosition = (_itemViews.count > 0) ? endPosition - widthButton - kBreadcrumbCover : endPosition - widthButton
                var rectUIButton = itemButton.frame
                rectUIButton.origin.x = startPosition;
                itemButton.frame = rectUIButton
                containerView.insertSubview( itemButton, atIndex: 0)
                _itemViews.append(itemButton)
                _items.append( label)

                if (!refresh) {
                    UIView.animateWithDuration( self.animationSpeed, delay: 0, options:[.CurveEaseInOut], animations: {
                        self.sizeToFit()
                        self.singleLayoutSubviews( itemButton, offsetX: endPosition)
                        } , completion: { finished in
                            self._animating = false
                            
                            if (itemsEvolution.count > 0) {
                                let eventItem: EventItem = EventItem()
                                eventItem.itemsEvolution = itemsEvolutionToSend
                                
                                NSNotificationCenter.defaultCenter().postNotificationName("NotificationNewItems", object: eventItem)
                            } else {
                                self.processIfItemsBreadCrumbInWaiting()  //self.animationInProgress = false
                            }
                    })
                } else {
                    self.sizeToFit()
                    self.singleLayoutSubviews( itemButton, offsetX: endPosition)
                    if (itemsEvolution.count > 0) {
                        processItem( itemsEvolutionToSend, refresh: true)
                    } else {
                        self.processIfItemsBreadCrumbInWaiting()  //self.animationInProgress = false
                    }
                }
            } else {
                
                //create a new UIButton
                var startPosition: CGFloat = 0
                var endPosition: CGFloat = 0
                if (_itemViews.count == 0) {
                    return
                }
                
                let indexTmp = _itemViews.count - 1
                let lastViewShowing: UIView = _itemViews[indexTmp]
                let rectLastViewShowing: CGRect = lastViewShowing.frame
                startPosition = rectLastViewShowing.origin.x
                let widthButton: CGFloat = lastViewShowing.frame.size.width
                endPosition = startPosition - widthButton
                var rectUIButton = lastViewShowing.frame
                rectUIButton.origin.x = startPosition;
                lastViewShowing.frame = rectUIButton
                
                
                if (!refresh) {
                    UIView.animateWithDuration( self.animationSpeed, delay: 0, options:[.CurveEaseInOut], animations: {
                        self.sizeToFit()
                        self.singleLayoutSubviews( lastViewShowing, offsetX: endPosition)
                        } , completion: { finished in
                            self._animating = false
                            
                            lastViewShowing.removeFromSuperview()
                            self._itemViews.removeLast()
                            self._items.removeLast()

                            
                            if (itemsEvolution.count > 0) {
                                let eventItem: EventItem = EventItem()
                                eventItem.itemsEvolution = itemsEvolutionToSend
                                
                                NSNotificationCenter.defaultCenter().postNotificationName("NotificationNewItems", object: eventItem)
                            } else {
                                self.processIfItemsBreadCrumbInWaiting()  //self.animationInProgress = false
                            }
                    })
                } else {
                    self.sizeToFit()
                    self.singleLayoutSubviews( lastViewShowing, offsetX: endPosition)
                    lastViewShowing.removeFromSuperview()
                    self._itemViews.removeLast()
                    self._items.removeLast()
                    if (itemsEvolution.count > 0) {
                        processItem( itemsEvolutionToSend, refresh: true)
                    } else {
                        self.processIfItemsBreadCrumbInWaiting()  //self.animationInProgress = false
                    }
                }

            }
        } else {
            self.processIfItemsBreadCrumbInWaiting()  //self.animationInProgress = false
        }
    }
    
    func receivedUINotificationNewItems(notification: NSNotification){
        let event: AnyObject? = notification.object
        let eventItems: EventItem? = event as! EventItem
        processItem( eventItems!.itemsEvolution, refresh: false)
    }

    func processIfItemsBreadCrumbInWaiting() {
        self.animationInProgress = false
        if (itemsBCInWaiting == true) {
            itemsBCInWaiting = false
            self.itemClicked = ""
            initialSetup( false)
        }
    }

    
}
