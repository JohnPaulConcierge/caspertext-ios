//
//  CasperTextView.swift
//

import UIKit

public class CasperTextView: UITextView {

    @IBInspectable
    public var displayBottomBar: Bool = true

    @IBInspectable
    public var floatingPlaceholder: String? = nil {
        didSet {
            floatingLabel.text = floatingPlaceholder ?? placeholder
        }
    }

    @IBInspectable
    public var placeholder: String = "" {
        didSet {
            placeholderLabel.text = placeholder
            floatingLabel.text = floatingPlaceholder ?? placeholder
        }
    }

    @IBInspectable
    open dynamic var bottomBarColor: UIColor = .lightGray {
        didSet {
            resetHighlight()
        }
    }

    @IBInspectable
    open dynamic var colorHighlight: UIColor? = nil {
        didSet {
            resetHighlight()
        }
    }

    fileprivate weak var placeholderLabel: UILabel!

    fileprivate weak var floatingLabel: UILabel!

    fileprivate weak var bottomBar: UIView!

    @IBInspectable
    open dynamic var minHeight: CGFloat = 48

    @IBInspectable
    open dynamic var floatingLabelFont: UIFont? {
        didSet {
            floatingLabel.font = floatingLabelFont ?? self.font?.withSize(12)
        }
    }

    @IBInspectable
    open dynamic var floatingLabelTextColor: UIColor? = nil {
        didSet {
            floatingLabel.textColor = floatingLabelTextColor ?? placeholderColor
        }
    }

    @IBInspectable
    public dynamic var placeholderFont: UIFont? {
        didSet {
            placeholderLabel.font = placeholderFont ?? self.font
        }
    }

    @IBInspectable
    public dynamic var placeholderColor: UIColor = .gray {
        didSet {
            placeholderLabel.textColor = placeholderColor
            floatingLabel.textColor = floatingLabelTextColor ?? placeholderColor
        }
    }

    @IBInspectable
    open dynamic var errorHighlight: UIColor? = nil {
        didSet {
            resetHighlight()
        }
    }

    open var isSelected: Bool = false {
        didSet {
            resetHighlight()
        }
    }

    open var isError: Bool = false {
        didSet {
            resetHighlight()
        }
    }

    @IBInspectable
    open var shouldAlwaysDisplayFloatingLabel: Bool = false {
        didSet {
            refreshFloatingLabel(animated: false)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }

    private func commonInit() {

        autoresizesSubviews = false
        translatesAutoresizingMaskIntoConstraints = false

        contentInset = .zero
        textContainerInset = .zero
        textContainer.lineFragmentPadding = 0

        let flabel = UILabel()
        addSubview(flabel)
        floatingLabel = flabel

        floatingLabel.alpha = 0
        floatingLabel.text = placeholder
        floatingLabel.font = floatingLabelFont ?? self.font?.withSize(12)
        floatingLabel.backgroundColor = backgroundColor
        floatingLabel.textColor = floatingLabelTextColor ?? placeholderColor
        floatingLabel.sizeToFit()

        let plabel = UILabel()
        insertSubview(plabel, at: 0)
        placeholderLabel = plabel

        placeholderLabel.textColor = placeholderColor
        placeholderLabel.font = placeholderFont ?? self.font
        placeholderLabel.numberOfLines = 0

        let bar = UIView()
        insertSubview(bar, at: 0)
        bottomBar = bar

        bottomBar.isUserInteractionEnabled = false
        resetHighlight()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(CasperTextView.textViewTextDidChange(sender:)),
                                               name: UITextView.textDidChangeNotification,
                                               object: self)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(CasperTextView.textViewDidEndEditing(sender:)),
                                               name: UITextView.textDidEndEditingNotification,
                                               object: self)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(CasperTextView.textViewDidBeginEditing(sender:)),
                                               name: UITextView.textDidBeginEditingNotification,
                                               object: self)
    }

    var textRect: CGRect {
        var rect = self.bounds.inset(by: self.contentInset)

        rect.origin.x += self.textContainer.lineFragmentPadding
        rect.origin.y += self.textContainerInset.top

        return rect.integral
    }

    public override var backgroundColor: UIColor? {
        didSet {
            floatingLabel?.backgroundColor = backgroundColor
        }
    }

    public override var textAlignment: NSTextAlignment {
        didSet {
            floatingLabel?.textAlignment = textAlignment
            placeholderLabel?.textAlignment = textAlignment
        }
    }

    fileprivate func resetBottomBarFrame() {
        let y = min(max(contentSize.height + 4, placeholderLabel.frame.maxY + 4), bounds.height - 2)
        bottomBar.frame = CGRect(x: 0, y: bounds.origin.y + y,
                                 width: bounds.width, height: 2)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        bottomBar.isHidden = !displayBottomBar

        if contentSize.height < frame.size.height {
            contentOffset.y = 0
        }
        let textRect = bounds

        let ty = floatingLabel.transform.ty
        floatingLabel.transform.ty = 0
        floatingLabel.sizeToFit()
        floatingLabel.frame = CGRect(x: textRect.origin.x,
                                     y: textRect.origin.y,
                                     width: textRect.width,
                                     height: floatingLabel.bounds.height)
        floatingLabel.transform.ty = ty

        textContainerInset.top = floatingLabel.bounds.height + 4
        textContainerInset.bottom = 2

        let size = placeholderLabel.sizeThatFits(bounds.size)
        placeholderLabel.frame = CGRect(x: textRect.origin.x,
                                        y: textRect.origin.y + textContainerInset.top,
                                        width: textRect.width,
                                        height: size.height)
        resetBottomBarFrame()
    }

    fileprivate func resetHighlight() {
        guard !isError || errorHighlight == nil else {
            floatingLabel.textColor = errorHighlight
            bottomBar?.backgroundColor = errorHighlight
            return
        }

        floatingLabel.textColor = (isFirstResponder || isSelected) ? (colorHighlight ?? tintColor) : placeholderColor
        bottomBar?.backgroundColor = (isFirstResponder || isSelected) ? (colorHighlight ?? tintColor) : bottomBarColor
    }

    @objc public func textViewDidEndEditing(sender: NSNotification) {
        resetHighlight()
    }

    @objc public func textViewDidBeginEditing(sender: NSNotification) {
        resetHighlight()
    }

    public override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.height = max(minHeight, contentSize.height + 4)
        return size
    }

    @objc public func textViewTextDidChange(sender: NSNotification) {
        refreshFloatingLabel()
        invalidateIntrinsicContentSize()
        resetBottomBarFrame()
    }

    public var isFloatingLabelDisplayed: Bool {
        return self.floatingLabel.alpha > 0
    }

    public func showFloatingLabel(animated: Bool ) {
        let show: () -> Void = {
            self.floatingLabel.alpha = 1
            self.floatingLabel.transform.ty = 0
        }
        if animated {
            self.floatingLabel.transform.ty = 8
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: show, completion: nil)
        } else {
            self.floatingLabel.alpha = 1
        }
    }

    public func hideFloatingLabel(animated: Bool) {
        let hide: () -> Void = {
            self.floatingLabel.alpha = 0
            self.floatingLabel.transform.ty = 8
        }
        if animated {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: hide, completion: nil)
        } else {
            hide()
        }
    }

    public func refreshFloatingLabel(animated: Bool = true) {
        if text?.isEmpty ?? true && !shouldAlwaysDisplayFloatingLabel {
            if isFloatingLabelDisplayed {
                hideFloatingLabel(animated: animated)
            }
        } else {
            if !isFloatingLabelDisplayed {
                showFloatingLabel(animated: animated)
            }
        }
        self.placeholderLabel.isHidden = !(text?.isEmpty ?? true)
    }

    public override var text: String! {
        didSet {
            refreshFloatingLabel()
            invalidateIntrinsicContentSize()
            resetBottomBarFrame()
        }
    }
}
