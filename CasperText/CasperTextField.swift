//
//  CasperTextField.swift
//


import UIKit

open class CasperTextField: UITextField {

    // MARK: - Attributes

    @IBInspectable
    open dynamic var placeholderTextColor: UIColor = .gray {
        didSet {
            resetFloatingLabel()
            resetPlaceholder()
        }
    }

    @IBInspectable
    open dynamic var placeholderFont: UIFont? {
        didSet {
            resetPlaceholder()
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

    @IBInspectable
    open dynamic var bottomBarColorHighlight: UIColor? = nil {
        didSet {
            resetHighlight()
        }
    }

    @IBInspectable
    open dynamic var errorHighlight: UIColor? = nil {
        didSet {
            resetHighlight()
        }
    }

    @IBInspectable
    public dynamic var floatingLabelFont: UIFont? = nil {
        didSet {
            resetFloatingLabel()
        }
    }

    @IBInspectable
    open dynamic var floatingLabelTextColor: UIColor? = nil {
        didSet {
            resetFloatingLabel()
        }
    }

    open override var isSelected: Bool {
        didSet {
            resetHighlight()
        }
    }

    open var error: String? = nil {
        didSet {
            resetHighlight()
        }
    }

    fileprivate weak var floatingLabel: UILabel?

    fileprivate weak var bottomBar: UIView?

    open override var placeholder: String? {
        didSet {
            resetPlaceholder()
        }
    }

    open override var textAlignment: NSTextAlignment {
        didSet {
            floatingLabel?.textAlignment = textAlignment
        }
    }

    // MARK: - Init

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    private func commonInit() {

        autoresizesSubviews = false
        translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        addSubview(label)
        floatingLabel = label

        floatingLabel?.alpha = 0
        floatingLabel?.text = placeholder
        floatingLabel?.font = floatingLabelFont ?? self.font?.withSize(12)
        floatingLabel?.sizeToFit()
        resetPlaceholder()

        let bar = UIView()
        addSubview(bar)
        self.bottomBar = bar

        bottomBar?.isUserInteractionEnabled = false
        resetHighlight()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(CasperTextField.resetHighlight),
                                               name: UITextField.textDidEndEditingNotification,
                                               object: self)
    }

    // MARK: - Updating UI

    private func resetFloatingLabel() {
        floatingLabel?.font = floatingLabelFont
        floatingLabel?.textColor = floatingLabelTextColor ?? placeholderTextColor
    }

    private func resetPlaceholder() {
        guard let placeholder = self.placeholder else {
            return
        }

        var attrs: [NSAttributedString.Key: Any] = [.foregroundColor: placeholderTextColor]
        if let f = placeholderFont {
            attrs[.font] = f
        }
        attributedPlaceholder = NSAttributedString(string: placeholder,
                                                   attributes: attrs)
        resetHighlight()
    }

    @objc func resetHighlight() {
        floatingLabel?.text = error ?? placeholder
        floatingLabel?.sizeToFit()

        guard error == nil || errorHighlight == nil else {
            floatingLabel?.textColor = errorHighlight
            bottomBar?.backgroundColor = errorHighlight
            return
        }
        floatingLabel?.textColor = (isFirstResponder || isSelected) ? (colorHighlight ?? tintColor) : placeholderTextColor
        bottomBar?.backgroundColor = (isFirstResponder || isSelected) ? (bottomBarColorHighlight ?? colorHighlight ?? tintColor) : bottomBarColor
    }

    // MARK: - Displaying floating

    @discardableResult
    open override func becomeFirstResponder() -> Bool {
        let b = super.becomeFirstResponder()
        resetHighlight()
        return b
    }

    @discardableResult
    open override func resignFirstResponder() -> Bool {
        let b = super.resignFirstResponder()
        resetHighlight()
        layoutIfNeeded()
        return b
    }

    private func insetTextRect(_ rect: CGRect) -> CGRect {
        if let height = floatingLabel?.bounds.height {
            var temp = rect
            temp.origin.y += height
            temp.size.height -= height
            return temp
        }
        return rect
    }

    open override func textRect(forBounds bounds: CGRect) -> CGRect {
        return insetTextRect(super.textRect(forBounds: bounds)).integral
    }

    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return insetTextRect(super.editingRect(forBounds: bounds)).integral
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        guard let floatingLabel = floatingLabel else {
            return
        }

        let textRect = super.textRect(forBounds: bounds)
        let ty = floatingLabel.transform.ty
        floatingLabel.transform.ty = 0
        floatingLabel.frame = CGRect(x: textRect.minX,
                                     y: textRect.minY,
                                     width: textRect.width,
                                     height: floatingLabel.bounds.height)
        floatingLabel.transform.ty = ty
        bottomBar?.frame = CGRect(x: textRect.minX,
                                 y: textRect.maxY - 2,
                                 width: textRect.width,
                                 height: 2)

        let newAlpha: CGFloat = text!.isEmpty ? 0 : 1
        if newAlpha != floatingLabel.alpha {
            animateFloatingLabel(show: newAlpha == 1)
        }
    }

    open func animateFloatingLabel(show: Bool) {
        let ty: CGFloat = 8
        let duration: TimeInterval = 0.2

        if show {
            floatingLabel?.transform.ty = ty
            floatingLabel?.alpha = 0
            UIView.animate(withDuration: duration) {
                self.floatingLabel?.transform.ty = 0
                self.floatingLabel?.alpha = 1
            }
        } else {
            floatingLabel?.transform.ty = 0
            floatingLabel?.alpha = 1
            UIView.animate(withDuration: duration) {
                self.floatingLabel?.transform.ty = ty
                self.floatingLabel?.alpha = 0
            }
        }
    }
}
