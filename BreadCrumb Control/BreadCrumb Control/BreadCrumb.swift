//
//  Copyright 2015 Philippe Kersalé
//

import UIKit

let kStartButtonWidth: CGFloat = 44
let kBreadcrumbCover: CGFloat = 15

public enum StyleBreadCrumb {
    case defaultFlatStyle
    case gradientFlatStyle
}

public protocol BreadCrumbControlDelegate: class {
    func didTouchItem(index: Int, item: String)
    func didTouchRootButton()
}

public extension BreadCrumbControlDelegate {
    func didTouchItem(index: Int, item: String) {}
    func didTouchRootButton() {}
}

private enum OperatorItem {
    case add
    case remove
}

private class ItemEvolution {
    var itemLabel: String = ""
    var operationItem: OperatorItem = OperatorItem.add
    var offsetX: CGFloat = 0.0
    init(itemLabel: String, operationItem: OperatorItem, offsetX: CGFloat) {
        self.itemLabel = itemLabel
        self.operationItem = operationItem
        self.offsetX = offsetX
    }
}

private class EventItem {
    init(evolutions: [ItemEvolution]) {
        itemsEvolution = evolutions
    }
    var itemsEvolution: [ItemEvolution]
}

@IBDesignable
public class CBreadcrumbControl: UIScrollView {
    
    // MARK: - Internal properties
    
    var _items: [String] = []
    public var _itemViews: [UIButton] = []

    public var containerView: UIView?
    public var startButton: UIButton?

    private var _animating: Bool = false
   
    private var animationInProgress: Bool = false
    
    // used if you send a new itemsBreadCrumb when "animationInProgress == true"
    private var itemsBCInWaiting: Bool = false
    
    // MARK: - Customizable properties. (Available for Interface Builder)
    
    @IBInspectable public var autoScrollEnabled: Bool = false
    
    @IBInspectable public var visibleRootButton: Bool = true {
        didSet{
            initialSetup(refresh: true)
        }
    }
    
    @IBInspectable public var textBCColor: UIColor = UIColor.black {
        didSet{
            initialSetup(refresh: true)
        }
    }
    
    @IBInspectable public var backgroundRootButtonColor: UIColor = UIColor.white {
        didSet{
            initialSetup(refresh: true)
        }
    }
    
    @IBInspectable public var backgroundBCColor: UIColor = UIColor.clear {
        didSet{
            initialSetup(refresh: true)
        }
    }
    
    @IBInspectable public var itemPrimaryColor: UIColor = UIColor.gray {
        didSet{
            initialSetup(refresh: true)
        }
    }
    
    @IBInspectable public var offsetLastPrimaryColor: CGFloat = 16.0 {
        didSet{
            initialSetup(refresh: true)
        }
    }
    
    
    @IBInspectable public var animationSpeed: Double = 0.2 {
        didSet{
            initialSetup(refresh: true)
        }
    }
    
    
    @IBInspectable public var arrowColor: UIColor = UIColor.blue {
        didSet{
            //drawRect( self.frame)
            initialSetup(refresh: true)
        }
    }
    
    @IBInspectable public var iconSize: CGSize = CGSize(width:20, height:20){
        didSet{
            //setNeedsDisplay()
            initialSetup(refresh: true)
        }
    }
    
    // MARK: - Customizable properties.
    
    public var style: StyleBreadCrumb = .gradientFlatStyle {
        didSet{
            initialSetup(refresh: true)
        }
    }
    
    public var buttonFont: UIFont = UIFont.boldSystemFont(ofSize: 16) {
        didSet{
            initialSetup(refresh: true)
        }
    }
    
    // MARK: - Delegates
    
    weak var breadCrumbDelegate: BreadCrumbControlDelegate?
    
    // MARK: Updating items
    
    @IBInspectable public var itemsBreadCrumb: [String] = [] {
        didSet{
            if !self.animationInProgress {
                initialSetup(refresh: false)
            } else {
                itemsBCInWaiting = true
            }
        }
    }
    
    // MARK: - initializers
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        register()
        initialSetup(refresh: true)
    }
    

    override public init(frame: CGRect) {
        super.init(frame: frame)
        register()
        initialSetup(refresh: true)
    }
    
    func register() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.receivedUINotificationNewItems),
                                               name:NSNotification.Name(rawValue: "NotificationNewItems"),
                                               object: nil)
    }
    
    override public func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UIButton {
            return true
        }
        return false
    }
    
    func initialSetup(refresh: Bool) {
        if self.containerView == nil {
            let rectContainerView = CGRect(origin: CGPoint(x: kStartButtonWidth + 1, y: 0),
                                           size: CGSize(width: self.bounds.size.width - (kStartButtonWidth + 1), height: self.frame.size.height))
            let containerView = UIView(frame:rectContainerView)
            containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            clipsToBounds = true
            
            self.addSubview(containerView)
            
            self.containerView = containerView
        }
        guard let containerView = self.containerView else { return }

        containerView.backgroundColor = backgroundBCColor
        
        if visibleRootButton && self.startButton == nil {
            let startButton = self.startRootButton()
            self.startButton = startButton
            self.addSubview(startButton)
            let rectContainerView = CGRect(origin: CGPoint(x: kStartButtonWidth+1, y: 0),
                                           size: CGSize(width: self.bounds.size.width - (kStartButtonWidth+1), height: self.frame.size.height))
            containerView.frame = rectContainerView
        } else if !visibleRootButton && self.startButton != nil {
            self.startButton?.removeFromSuperview()
            self.startButton = nil
            let rectContainerView = CGRect(origin: CGPoint(x: 0, y: 0),
                                           size: CGSize(width: self.bounds.size.width, height: self.frame.size.height))
            containerView.frame = rectContainerView
        }
        if let startButton = self.startButton, visibleRootButton {
            startButton.backgroundColor = backgroundRootButtonColor
        }
        self.setItems(items: self.itemsBreadCrumb, refresh: refresh, containerView: containerView)
    }


    func startRootButton() -> UIButton
    {
        let button = UIButton(type: .custom) as UIButton
        button.backgroundColor = backgroundRootButtonColor
        guard let bgImage = UIImage(named: "button_start", in: Bundle(for: type(of: self)), compatibleWith: nil) else {
            fatalError("Root button's image is not created")
        }
        button.setBackgroundImage(bgImage, for: .normal)
        button.frame = CGRect(origin: CGPoint(x: 0, y: 0),
                              size: CGSize(width: kStartButtonWidth+1, height: self.frame.size.height))
        button.addTarget(self, action: #selector(self.pressed), for: .touchUpInside)

        return button
    }
    
    func itemButton(item: String, position: Int) -> BreadCrumbButton
    {
        let button: BreadCrumbButton = BreadCrumbButton() as BreadCrumbButton
        if (self.style == .gradientFlatStyle) {
            button.styleButton = .extendButton
            var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0
            _ = self.itemPrimaryColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
//            var rgbValueTmp = self.itemPrimaryColor.cgColor.components
//            let red = rgbValueTmp?[0]
//            let green = rgbValueTmp?[1]
//            let blue = rgbValueTmp?[1]
            //var rgbValue: Double = Double(rgbValueTmp)
            //var rgbValue = 0x777777
            //let rPrimary:CGFloat = CGFloat((rgbValue & 0xFF0000) >> 16)/255.0
            //let gPrimary:CGFloat = CGFloat((rgbValue & 0xFF00) >> 8)/255.0
            //let bPrimary:CGFloat = CGFloat((rgbValue & 0xFF))/255.0
            let rPrimary = CGFloat(red * 255.0)
            let gPrimary = CGFloat(green * 255.0)
            let bPrimary = CGFloat(blue * 255.0)

            
            let levelRedPrimaryColor = rPrimary + (self.offsetLastPrimaryColor * CGFloat(position))
            let levelGreenPrimaryColor = gPrimary + (self.offsetLastPrimaryColor * CGFloat(position))
            let levelBluePrimaryColor = bPrimary + (self.offsetLastPrimaryColor * CGFloat(position))
            let r = levelRedPrimaryColor / 255.0
            let g = levelGreenPrimaryColor / 255.0
            let b = levelBluePrimaryColor / 255.0
            button.backgroundCustomColor =  UIColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: 1.0)
        } else {
            button.styleButton = .simpleButton
            button.backgroundCustomColor = self.backgroundBCColor  //self.backgroundItemColor
            button.arrowColor = self.arrowColor
        }
        button.contentMode = .center
        button.titleLabel?.font = self.buttonFont
        button.setTitle(item, for: .normal)
        button.setTitleColor( textBCColor, for: .normal)
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        
        button.sizeToFit()
        let rectButton = button.frame
        let widthButton = (position > 0) ? rectButton.width + 32 + kBreadcrumbCover : rectButton.width + 32
        button.frame = CGRect(origin: CGPoint(x: 0, y: 0),
                              size: CGSize(width: widthButton , height: self.frame.size.height))
        button.titleEdgeInsets = (position > 0) ?
            UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0) :
            UIEdgeInsets(top: 0.0, left: -kBreadcrumbCover, bottom: 0.0, right: 0.0)
        button.addTarget(self, action: #selector(self.pressed), for: .touchUpInside)
        
        return button
    }
    
    func pressed(sender: UIButton!) {
        if self.startButton != nil && self.startButton == sender {
            self.breadCrumbDelegate?.didTouchRootButton()
        } else {
            if let clickedButtonTitle = sender.titleLabel?.text,
                let index = self._items.index(of: clickedButtonTitle) {
                self.breadCrumbDelegate?.didTouchItem(index: index, item: clickedButtonTitle)
            }
        }
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        var cx: CGFloat = 0  //kStartButtonWidth
        for view: UIView in _itemViews {
            let s = view.bounds.size
            view.frame = CGRect(origin: CGPoint(x: cx, y: 0), size: CGSize(width: s.width, height: s.height))
            cx += s.width
        }
        initialSetup(refresh: true)
    }
    
    
    func singleLayoutSubviews( view: UIView, offsetX: CGFloat) {
        super.layoutSubviews()
        
        let s = view.bounds.size
        view.frame = CGRect(origin: CGPoint(x: offsetX, y: 0), size: CGSize(width: s.width, height: s.height))
    }
    
    
    func setItems(items: [String], refresh: Bool, containerView: UIView) {
        self.animationInProgress = true

        if self._animating {
            return
        }
        if !refresh {
            var itemsEvolution = [ItemEvolution]()
            // comparer with old items search the difference
            var endPosition: CGFloat = 0.0
            var idxToChange: Int = 0
            for idx: Int in 0 ..< _items.count {
                if idx < items.count && _items[idx] == items[idx] {
                    idxToChange += 1
                    endPosition += _itemViews[idx].frame.width
                    continue
                } else {
                    endPosition -= _itemViews[idx].frame.width
                    if itemsEvolution.count > idx {
                    itemsEvolution.insert(ItemEvolution(itemLabel: items[idx], operationItem: OperatorItem.remove, offsetX: endPosition), at: idxToChange)
                    } else {
                        itemsEvolution.append(ItemEvolution(itemLabel: _items[idx], operationItem: OperatorItem.remove, offsetX: endPosition))
                    }
                }
            }
            for idx: Int in idxToChange ..< items.count {
                itemsEvolution.append(ItemEvolution( itemLabel: items[idx], operationItem: OperatorItem.add, offsetX: endPosition))
            }
            
            processItem( itemsEvolution: itemsEvolution, refresh: false)
        } else {
            self.animationInProgress = false
 
            var itemsEvolution = [ItemEvolution]()
            // comparer with old items search the difference
            let endPosition: CGFloat = 0.0
            for idx: Int in 0 ..< _items.count {
                itemsEvolution.append( ItemEvolution( itemLabel: items[idx], operationItem: OperatorItem.remove, offsetX: endPosition))
            }
            for idx: Int in 0 ..< _items.count {
                itemsEvolution.append( ItemEvolution( itemLabel: items[idx], operationItem: OperatorItem.add, offsetX: endPosition))
            }
            processItem( itemsEvolution: itemsEvolution, refresh: true)
        }
    }
    
    private func processItem( itemsEvolution: [ItemEvolution], refresh: Bool) {
        if itemsEvolution.count <= 0 {
            self.processIfItemsBreadCrumbInWaiting()  //self.animationInProgress = false
            return
        }
        
        var itemsEvolutionToSend = [ItemEvolution]()
        for idx: Int in 1 ..< itemsEvolution.count {
            itemsEvolutionToSend.append(
                ItemEvolution(itemLabel: itemsEvolution[idx].itemLabel,
                              operationItem: itemsEvolution[idx].operationItem,
                              offsetX: itemsEvolution[idx].offsetX)
            )
        }
        
        if itemsEvolution[0].operationItem == .add {
            //create a new UIButton
            var startPosition: CGFloat = 0
            var endPosition: CGFloat = 0
            if _itemViews.count > 0 {
                let indexTmp = _itemViews.count - 1
                let lastViewShowing: UIView = _itemViews[indexTmp]
                let rectLastViewShowing: CGRect = lastViewShowing.frame
                endPosition = rectLastViewShowing.origin.x + rectLastViewShowing.size.width - kBreadcrumbCover
            }
            let label = itemsEvolution[0].itemLabel
            let itemButton = self.itemButton( item: label, position: _itemViews.count)
            let widthButton = itemButton.frame.size.width
            startPosition = (_itemViews.count > 0) ? endPosition - widthButton - kBreadcrumbCover : endPosition - widthButton
            var rectUIButton = itemButton.frame
            rectUIButton.origin.x = startPosition;
            itemButton.frame = rectUIButton
            containerView?.insertSubview( itemButton, at: 0)
            _itemViews.append(itemButton)
            _items.append( label)

            if !refresh {
                UIView.animate( withDuration: self.animationSpeed, delay: 0, options:[.curveEaseInOut], animations: { [weak self] in
                    guard let this = self else { return }
                    this.sizeToFit()
                    this.singleLayoutSubviews( view: itemButton, offsetX: endPosition)
                }, completion: { [weak self] finished in
                    guard let this = self else { return }
                    this._animating = false
                    
                    if itemsEvolutionToSend.count == 0 {
                        var contentSize = this.contentSize
                        contentSize.width = endPosition + widthButton + kBreadcrumbCover
                        this.contentSize = contentSize
                        if this.autoScrollEnabled {
                            this.setContentOffset(CGPoint(x: endPosition, y: 0), animated: true)
                        }
                    }
                    
                    if itemsEvolution.count > 0 {
                        let eventItem = EventItem(evolutions: itemsEvolutionToSend)
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NotificationNewItems"), object: eventItem)
                    } else {
                        this.processIfItemsBreadCrumbInWaiting()  //self.animationInProgress = false
                    }
                })
            } else {
                self.sizeToFit()
                self.singleLayoutSubviews( view: itemButton, offsetX: endPosition)
                
                if itemsEvolutionToSend.count == 0 {
                    var contentSize = self.contentSize
                    contentSize.width = endPosition + widthButton + kBreadcrumbCover
                    self.contentSize = contentSize
                }
                
                if itemsEvolution.count > 0 {
                    processItem( itemsEvolution: itemsEvolutionToSend, refresh: true)
                } else {
                    self.processIfItemsBreadCrumbInWaiting()  //self.animationInProgress = false
                }
            }
        } else if itemsEvolution[0].operationItem == .remove {
            
            //create a new UIButton
            var startPosition: CGFloat = 0
            var endPosition: CGFloat = 0
            if _itemViews.count == 0 {
                return
            }
            
            let indexTmp = _itemViews.count - 1
            let lastViewShowing = _itemViews[indexTmp]
            let rectLastViewShowing = lastViewShowing.frame
            startPosition = rectLastViewShowing.origin.x
            let widthButton = lastViewShowing.frame.size.width
            endPosition = startPosition - widthButton
            var rectUIButton = lastViewShowing.frame
            rectUIButton.origin.x = startPosition;
            lastViewShowing.frame = rectUIButton
            
            if !refresh {
                UIView.animate( withDuration: self.animationSpeed, delay: 0, options:[.curveEaseInOut], animations: { [weak self] in
                    guard let this = self else { return }
                    this.sizeToFit()
                    this.singleLayoutSubviews( view: lastViewShowing, offsetX: endPosition)
                }, completion: { [weak self] finished in
                    guard let this = self else { return }
                    this._animating = false
                    
                    lastViewShowing.removeFromSuperview()
                    this._itemViews.removeLast()
                    this._items.removeLast()

                    
                    if itemsEvolutionToSend.count == 0 {
                        var contentSize = this.contentSize
                        contentSize.width = startPosition + widthButton + kBreadcrumbCover + 500
                        this.contentSize = contentSize
                        if this.autoScrollEnabled {
                            this.setContentOffset(CGPoint(x: endPosition, y: 0), animated: true)
                        }
                    }
                    
                    if itemsEvolution.count > 0 {
                        let eventItem = EventItem(evolutions: itemsEvolutionToSend)
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NotificationNewItems"), object: eventItem)
                    } else {
                        this.processIfItemsBreadCrumbInWaiting()  //self.animationInProgress = false
                    }
                })
            } else {
                self.sizeToFit()
                self.singleLayoutSubviews(view: lastViewShowing, offsetX: endPosition)
                
                lastViewShowing.removeFromSuperview()
                self._itemViews.removeLast()
                self._items.removeLast()
                
                if itemsEvolutionToSend.count == 0 {
                    var contentSize = self.contentSize
                    contentSize.width = startPosition + widthButton + kBreadcrumbCover + 500
                    self.contentSize = contentSize
                }
                
                if itemsEvolution.count > 0 {
                    processItem( itemsEvolution: itemsEvolutionToSend, refresh: true)
                } else {
                    self.processIfItemsBreadCrumbInWaiting()  //self.animationInProgress = false
                }
            }

        }
    }
    
    func receivedUINotificationNewItems(notification: NSNotification){
        if let eventItems = notification.object as? EventItem {
            processItem(itemsEvolution: eventItems.itemsEvolution, refresh: false)
        }
    }

    func processIfItemsBreadCrumbInWaiting() {
        self.animationInProgress = false
        if itemsBCInWaiting {
            itemsBCInWaiting = false
            initialSetup(refresh: false)
        }
    }
}
