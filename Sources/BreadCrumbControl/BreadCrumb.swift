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

public protocol BreadCrumbControlDelegate: AnyObject {
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

private class ItemUpdatingContext {
    init(items: [String], itemViews: [UIButton]) {
        self.items = items
        self.itemViews = itemViews
    }
    var items: [String]
    var itemViews: [UIButton]
    var evolutions: [ItemEvolution] = []
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
    init(context: ItemUpdatingContext) {
        self.context = context
    }
    var context: ItemUpdatingContext
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
    private var itemsResisterQueue: [[String]] = []
    
    // MARK: - Customizable properties. (Available for Interface Builder)
    
    @IBInspectable public var animateOnPress: Bool = false
    
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
    
    public weak var breadCrumbDelegate: BreadCrumbControlDelegate?
    
    // MARK: Updating items
    
    @IBInspectable public var itemsBreadCrumb: [String] = [] {
        didSet{
            if !self.animationInProgress {
                initialSetup(refresh: false, newItems: self.itemsBreadCrumb)
            } else {
                itemsResisterQueue.append(self.itemsBreadCrumb)
            }
        }
    }
    
    // MARK: - initializers
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        register()
        setupViews()
        initialSetup(refresh: true)
    }
    

    override public init(frame: CGRect) {
        super.init(frame: frame)
        register()
        setupViews()
        initialSetup(refresh: true)
    }
    
    func register() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.receivedUINotificationNewItems),
                                               name:NSNotification.Name(rawValue: "NotificationNewItems"),
                                               object: nil)
    }
    
    // MARK: - Internal methods
    
    override public func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UIButton {
            return true
        }
        return false
    }

    private func setupViews() {
        self.clipsToBounds = true
        
        let rectContainerView = CGRect(origin: CGPoint(x: kStartButtonWidth + 1, y: 0),
                                       size: CGSize(width: self.bounds.size.width - (kStartButtonWidth + 1), height: self.frame.size.height))
        let containerView = UIView(frame:rectContainerView)
        containerView.autoresizingMask = [.flexibleWidth]
        
        self.addSubview(containerView)
        self.containerView = containerView
        self.contentSize = rectContainerView.size
    }
    
    func initialSetup(refresh: Bool, newItems: [String]? = nil) {
        guard let containerView = self.containerView else { return }

        self.backgroundColor = backgroundBCColor
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
        self.setItems(items: newItems ?? self._items, refresh: refresh, containerView: containerView)
    }

    func startRootButton() -> UIButton
    {
        let button = UIButton(type: .custom) as UIButton
        button.backgroundColor = backgroundRootButtonColor
        
        #if SWIFT_PACKAGE
            let resourceBundle = Bundle.module
        #else
            // cocoapods OR manually embedded in host app
            let podBundleURL = Bundle(for: type(of: self)).url(forResource: "BreadCrumbControl", withExtension: "bundle"/*xcassets*/) ?? Bundle.main.bundleURL
            let resourceBundle = Bundle(url: podBundleURL)
        #endif
        guard let bgImage = UIImage(named: "breadCrumb", in: resourceBundle, compatibleWith: nil) else {
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
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
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
    
    @objc func pressed(sender: UIButton!) {
        if animateOnPress {
            sender.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 0.2,
                           initialSpringVelocity: 6.0,
                           options: .allowUserInteraction,
                           animations: { sender.transform = .identity },
                           completion: nil)
        }
        
        if self.startButton != nil && self.startButton == sender {
            self.breadCrumbDelegate?.didTouchRootButton()
        } else {
            if let clickedButtonTitle = sender.titleLabel?.text,
                let index = self._items.firstIndex(of: clickedButtonTitle) {
                self.breadCrumbDelegate?.didTouchItem(index: index, item: clickedButtonTitle)
            }
        }
    }

    private static func addOffset(to view: UIView, offsetX: CGFloat) {
        let s = view.bounds.size
        view.frame = CGRect(origin: CGPoint(x: offsetX, y: 0), size: CGSize(width: s.width, height: s.height))
    }
    
    func setItems(items: [String], refresh: Bool, containerView: UIView) {
        self.animationInProgress = true

        if self._animating {
            return
        }
        
        if !refresh {
            let context = ItemUpdatingContext(items: _items, itemViews: _itemViews)
            // comparer with old items search the difference
            var endPosition: CGFloat = 0.0
            var idxToChange: Int = 0
            for idx: Int in 0 ..< context.items.count {
                if idx < items.count && context.items[idx] == items[idx] {
                    idxToChange += 1
                    endPosition += context.itemViews[idx].frame.width
                    continue
                } else {
                    endPosition -= context.itemViews[idx].frame.width
                    if context.evolutions.count > idx {
                    context.evolutions.insert(ItemEvolution(itemLabel: items[idx], operationItem: OperatorItem.remove, offsetX: endPosition), at: idxToChange)
                    } else {
                        context.evolutions.append(ItemEvolution(itemLabel: _items[idx], operationItem: OperatorItem.remove, offsetX: endPosition))
                    }
                }
            }
            for idx: Int in idxToChange ..< items.count {
                context.evolutions.append(ItemEvolution( itemLabel: items[idx], operationItem: OperatorItem.add, offsetX: endPosition))
            }
            
            processItem( context: context, refresh: false)
        } else {
            self.animationInProgress = false
 
            let context = ItemUpdatingContext(items: _items, itemViews: _itemViews)
            // comparer with old items search the difference
            let endPosition: CGFloat = 0.0
            for idx: Int in 0 ..< context.items.count {
                context.evolutions.append(ItemEvolution(itemLabel: items[idx], operationItem: OperatorItem.remove, offsetX: endPosition))
            }
            for idx: Int in 0 ..< context.items.count {
                context.evolutions.append(ItemEvolution(itemLabel: items[idx], operationItem: OperatorItem.add, offsetX: endPosition))
            }
            processItem(context: context, refresh: true)
        }
    }
    
    private func processItem( context: ItemUpdatingContext, refresh: Bool) {
        if context.evolutions.count <= 0 {
            for oldView in self._itemViews {
                if !context.itemViews.contains(oldView) {
                    oldView.removeFromSuperview()
                }
            }
            self._items = context.items
            self._itemViews = context.itemViews
            self.processIfItemsBreadCrumbInWaiting()  //self.animationInProgress = false
            return
        }
        
        let currentEvolution = context.evolutions[0]
        context.evolutions.remove(at: 0)
        
        let frame = self.frame
        let enabledAnimation = !refresh && (self.animationSpeed > 0)

        if currentEvolution.operationItem == .add {
            //create a new UIButton
            var startPosition: CGFloat = 0
            var endPosition: CGFloat = 0
            if context.itemViews.count > 0 {
                let indexTmp = context.itemViews.count - 1
                let lastViewShowing: UIView = context.itemViews[indexTmp]
                let rectLastViewShowing: CGRect = lastViewShowing.frame
                endPosition = rectLastViewShowing.origin.x + rectLastViewShowing.size.width - kBreadcrumbCover
            }

            let label = currentEvolution.itemLabel
            let itemButton = self.itemButton( item: label, position: context.itemViews.count)
            if context.evolutions.count == 0 {
                itemButton.isLast = true
            }
            if context.itemViews.count >= 1 {
                if let button = context.itemViews[context.itemViews.count-1] as? BreadCrumbButton {
                    button.isLast = false
                }
            }

            let widthButton = itemButton.frame.size.width
            startPosition = (context.itemViews.count > 0) ? endPosition - widthButton - kBreadcrumbCover : endPosition - widthButton
            var rectUIButton = itemButton.frame
            rectUIButton.origin.x = startPosition;
            itemButton.frame = rectUIButton
            containerView?.insertSubview( itemButton, at: 0)
            context.itemViews.append(itemButton)
            context.items.append( label)

            if enabledAnimation {
                UIView.animate( withDuration: self.animationSpeed, delay: 0, options:[.curveEaseInOut], animations: { [weak self] in
                    guard let this = self else { return }
                    CBreadcrumbControl.addOffset(to: itemButton, offsetX: endPosition)
                    
                    let contentWidth = context.itemViews.reduce(kBreadcrumbCover) { (width, button) in
                        return width + button.frame.size.width - kBreadcrumbCover
                    }
                    let contentSize = CGSize(width: contentWidth, height: this.contentSize.height)
                    this.contentSize = contentSize
                    if this.autoScrollEnabled {
                        this.setContentOffset(CGPoint(x: max(0, contentWidth - frame.size.width), y: 0), animated: false)
                    }
                    if let containerView = this.containerView {
                        containerView.frame = CGRect(origin: containerView.frame.origin, size: contentSize)
                    }
                }, completion: { [weak self] finished in
                    guard let this = self else { return }
                    this._animating = false
                    
                    let eventItem = EventItem(context: context)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NotificationNewItems"), object: eventItem)
                })
            } else {
                CBreadcrumbControl.addOffset(to: itemButton, offsetX: endPosition)
                
                if context.evolutions.count == 0 {
                    let contentWidth = context.itemViews.reduce(kBreadcrumbCover) { (width, button) in
                        return width + button.frame.size.width - kBreadcrumbCover
                    }
                    let contentSize = CGSize(width: contentWidth, height: self.contentSize.height)
                    self.contentSize = contentSize
                    if self.autoScrollEnabled && !refresh {
                        self.setContentOffset(CGPoint(x: max(0, contentWidth - frame.size.width), y: 0), animated: true)
                    }
                    if let containerView = self.containerView {
                        containerView.frame = CGRect(origin: containerView.frame.origin, size: contentSize)
                    }
                }
                
                processItem(context: context, refresh: refresh)
            }
        } else if currentEvolution.operationItem == .remove {
            
            //create a new UIButton
            var startPosition: CGFloat = 0
            var endPosition: CGFloat = 0
            if context.itemViews.count == 0 {
                return
            }
            
            let indexTmp = context.itemViews.count - 1
            let lastViewShowing = context.itemViews[indexTmp]
            let rectLastViewShowing = lastViewShowing.frame
            startPosition = rectLastViewShowing.origin.x
            let widthButton = lastViewShowing.frame.size.width
            endPosition = startPosition - widthButton
            var rectUIButton = lastViewShowing.frame
            rectUIButton.origin.x = startPosition;
            lastViewShowing.frame = rectUIButton
            
            if enabledAnimation {
                UIView.animate( withDuration: self.animationSpeed, delay: 0, options:[.curveEaseInOut], animations: { [weak self] in
                    guard let this = self else { return }
                    CBreadcrumbControl.addOffset(to: lastViewShowing, offsetX: endPosition)
                    
                    let contentWidth = context.itemViews.reduce(kBreadcrumbCover) { (width, button) in
                        return width + button.frame.size.width - kBreadcrumbCover
                    } - lastViewShowing.frame.size.width
                    let contentSize = CGSize(width: contentWidth, height: this.contentSize.height)
                    this.contentSize = contentSize
                    if let containerView = this.containerView {
                        containerView.frame = CGRect(origin: containerView.frame.origin, size: contentSize)
                    }
                    if this.autoScrollEnabled {
                        this.setContentOffset(CGPoint(x: max(0, contentWidth - frame.size.width), y: 0), animated: false)
                    }
                }, completion: { [weak self] finished in
                    guard let this = self else { return }
                    this._animating = false
                    
                    lastViewShowing.removeFromSuperview()
                    context.itemViews.removeLast()
                    context.items.removeLast()

                    if context.itemViews.count >= 1 {
                        if let button = context.itemViews[context.itemViews.count-1] as? BreadCrumbButton {
                            button.isLast = true
                        }
                    }
                    
                    let eventItem = EventItem(context: context)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NotificationNewItems"), object: eventItem)

                })
            } else {
                CBreadcrumbControl.addOffset(to: lastViewShowing, offsetX: endPosition)
                
                lastViewShowing.removeFromSuperview()
                context.itemViews.removeLast()
                context.items.removeLast()
                
                if context.itemViews.count >= 1 {
                    if let button = context.itemViews[context.itemViews.count-1] as? BreadCrumbButton {
                        button.isLast = true
                    }
                }
                
                if context.evolutions.count == 0 {
                    let contentWidth = context.itemViews.reduce(kBreadcrumbCover) { (width, button) in
                        return width + button.frame.size.width - kBreadcrumbCover
                    }
                    let contentSize = CGSize(width: contentWidth, height: self.contentSize.height)
                    self.contentSize = contentSize
                    if self.autoScrollEnabled && !refresh {
                        self.setContentOffset(CGPoint(x: max(0, contentWidth - frame.size.width), y: 0), animated: true)
                    }
                    if let containerView = self.containerView {
                        containerView.frame = CGRect(origin: containerView.frame.origin, size: contentSize)
                    }
                }
                
                processItem(context: context, refresh: refresh)
            }

        }
    }
    
    @objc func receivedUINotificationNewItems(notification: NSNotification){
        if let eventItems = notification.object as? EventItem {
            processItem(context: eventItems.context, refresh: false)
        }
    }

    func processIfItemsBreadCrumbInWaiting() {
        self.animationInProgress = false
        if itemsResisterQueue.count > 0 {
            if let nextItems = itemsResisterQueue.popLast() {
                initialSetup(refresh: false, newItems: nextItems)
            }
        }
    }
}
