//
//  WSTagView.swift
//  Whitesmith
//
//  Created by Ricardo Pereira on 12/05/16.
//  Copyright © 2016 Whitesmith. All rights reserved.
//

import UIKit

open class WSTagView: UIView, UITextInputTraits {
    
    let textLabel = UILabel()
    fileprivate let closeButton = UIButton(type: .custom)
    fileprivate let imageView : UIImageView = UIImageView()
    
    open var displayText: String = "" {
        didSet {
            updateLabelText()
            setNeedsDisplay()
        }
    }
    
    open var topicsImage : UIImage? {
        didSet {
            self.imageView.image = topicsImage
        }
    }
    
    open var closeButtonImage : UIImage?
    
    open var displayDelimiter: String = "" {
        didSet {
            updateLabelText()
            setNeedsDisplay()
        }
    }
    
    open var font: UIFont? {
        didSet {
            textLabel.font = font
            setNeedsDisplay()
        }
    }
    
    open var cornerRadius: CGFloat = 3.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
            setNeedsDisplay()
        }
    }
    
    open var borderWidth: CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = borderWidth
            setNeedsDisplay()
        }
    }
    
    open var borderColor: UIColor? {
        didSet {
            if let borderColor = borderColor {
                self.layer.borderColor = borderColor.cgColor
                setNeedsDisplay()
            }
        }
    }
    
    open var tagViewBackgroundColor : UIColor! {
        didSet { updateContent(animated: false) }
    }
    
    
    /// Background color to be used for selected state.
    open var selectedColor: UIColor? {
        didSet { updateContent(animated: false) }
    }
    
    open var textColor: UIColor? {
        didSet { updateContent(animated: false) }
    }
    
    open var selectedTextColor: UIColor? {
        didSet { updateContent(animated: false) }
    }
    
    internal var onDidRequestDelete: ((_ tagView: WSTagView, _ replacementText: String?) -> Void)?
    internal var onDidRequestSelection: ((_ tagView: WSTagView) -> Void)?
    internal var onDidInputText: ((_ tagView: WSTagView, _ text: String) -> Void)?
    
    open var selected: Bool = false {
        didSet {
            if !allowsMultipleSelection {
                if selected && !isFirstResponder {
                    _ = becomeFirstResponder()
                }
                else if !selected && isFirstResponder {
                    _ = resignFirstResponder()
                }
            }
            updateContent(animated: true)
        }
    }
    open var allowsMultipleSelection: Bool = false
    open var removable: Bool = true
    
    // MARK: - UITextInputTraits
    
    public var autocapitalizationType: UITextAutocapitalizationType = .none
    public var autocorrectionType: UITextAutocorrectionType  = .no
    public var spellCheckingType: UITextSpellCheckingType  = .no
    public var keyboardType: UIKeyboardType = .default
    public var keyboardAppearance: UIKeyboardAppearance = .default
    public var returnKeyType: UIReturnKeyType = .next
    public var enablesReturnKeyAutomatically: Bool = false
    public var isSecureTextEntry: Bool = false
    
    // MARK: - Initializers
    
    public init(tag: WSTag, closeButtonImage : UIImage? = nil, topicsImage : UIImage? = nil) {
        super.init(frame: CGRect.zero)
        self.closeButtonImage = closeButtonImage
        self.topicsImage = topicsImage
        self.backgroundColor = tintColor
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
        
        textColor = .white
        selectedColor = .gray
        selectedTextColor = .black
        
        textLabel.frame = CGRect(x: layoutMargins.left, y: layoutMargins.top, width: 0, height: 0)
        textLabel.font = font
        textLabel.textColor = .white
        addSubview(textLabel)
        
        self.displayText = tag.text
        updateLabelText()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer))
        addGestureRecognizer(tapRecognizer)
        
        if self.closeButtonImage != nil {
            closeButton.setTitle(nil, for: .normal)
            closeButton.setImage(closeButtonImage!, for: .normal)
            closeButton.addTarget(self, action:#selector(deleteButtonAction) , for: .touchUpInside)
            closeButton.backgroundColor = .clear
            addSubview(closeButton)
        }
        
        if self.topicsImage != nil {
            imageView.image = self.topicsImage
            imageView.contentMode = .center
            addSubview(imageView)
        }
        
        setNeedsLayout()
    }
    
    
    @objc private func deleteButtonAction () {
        onDidRequestDelete?(self, nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        assert(false, "Not implemented")
    }
    
    // MARK: - Styling
    
    fileprivate func updateColors() {
        self.backgroundColor = selected ? selectedColor : tagViewBackgroundColor
        textLabel.textColor = selected ? selectedTextColor : textColor
    }
    
    internal func updateContent(animated: Bool) {
        guard animated else {
            updateColors()
            return
        }
        
        UIView.animate(
            withDuration: 0.2,
            animations: { [weak self] in
                self?.updateColors()
                if self?.selected ?? false {
                    self?.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
                }
            },
            completion: { [weak self] _ in
                if self?.selected ?? false {
                    UIView.animate(withDuration: 0.1) { [weak self] in
                        self?.transform = CGAffineTransform.identity
                    }
                }
            }
        )
    }
    
    // MARK: - Size Measurements
    
    open override var intrinsicContentSize: CGSize {
        let labelIntrinsicSize = textLabel.intrinsicContentSize
        if self.closeButtonImage != nil {
            let buttonSize = closeButton.intrinsicContentSize
            return CGSize(width: labelIntrinsicSize.width + buttonSize.width + layoutMargins.left + layoutMargins.right,
                          height: labelIntrinsicSize.height + layoutMargins.top + layoutMargins.bottom)
        }
        if self.topicsImage != nil {
            let imageSize = imageView.intrinsicContentSize
            return CGSize(width: labelIntrinsicSize.width + imageSize.width  + layoutMargins.left*2 + layoutMargins.right,
                                     height: labelIntrinsicSize.height + layoutMargins.top + layoutMargins.bottom)
        }
        return CGSize(width: labelIntrinsicSize.width + layoutMargins.left + layoutMargins.right,
                      height: labelIntrinsicSize.height + layoutMargins.top + layoutMargins.bottom)
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        let layoutMarginsHorizontal = layoutMargins.left + layoutMargins.right
        let layoutMarginsVertical = layoutMargins.top + layoutMargins.bottom
        let fittingSize = CGSize(width: size.width - layoutMarginsHorizontal,
                                 height: size.height - layoutMarginsVertical)
        let labelSize = textLabel.sizeThatFits(fittingSize)
        return CGSize(width: labelSize.width + layoutMarginsHorizontal,
                      height: labelSize.height + layoutMarginsVertical)
    }
    
    open func sizeToFit(_ size: CGSize) -> CGSize {
        if intrinsicContentSize.width > size.width {
            return CGSize(width: size.width,
                          height: intrinsicContentSize.height)
        }
        return intrinsicContentSize
    }
    
    // MARK: - Attributed Text
    fileprivate func updateLabelText() {
        // Unselected shows "[displayText]," and selected is "[displayText]"
        textLabel.text = displayText + displayDelimiter
        // Expand Label
        let intrinsicSize = self.intrinsicContentSize
        frame = CGRect(x: 0, y: 0, width: intrinsicSize.width, height: intrinsicSize.height)
    }
    
    // MARK: - Laying out
    open override func layoutSubviews() {
        super.layoutSubviews()
        textLabel.frame = bounds.inset(by: layoutMargins)
        
        if self.closeButtonImage != nil {
            closeButton.frame = CGRect(x: textLabel.frame.origin.x + textLabel.frame.size.width - 15, y: layoutMargins.top, width: self.closeButtonImage!.size.width, height: self.closeButtonImage!.size.height)
        }
        if self.topicsImage != nil {
            if imageView.frame.origin.x == 0.0 {
                 imageView.frame = CGRect(x: textLabel.frame.origin.x + textLabel.frame.size.width - 15, y: layoutMargins.top, width: self.topicsImage!.size.width, height: self.topicsImage!.size.height)
            }
        }
        
        if frame.width == 0 || frame.height == 0 {
            frame.size = self.intrinsicContentSize
        }
    }
    
    // MARK: - First Responder (needed to capture keyboard)
    open override var canBecomeFirstResponder: Bool {
        return true
    }
    
    open override func becomeFirstResponder() -> Bool {
        let didBecomeFirstResponder = super.becomeFirstResponder()
        selected = true
        return didBecomeFirstResponder
    }
    
    open override func resignFirstResponder() -> Bool {
        let didResignFirstResponder = super.resignFirstResponder()
        selected = false
        return didResignFirstResponder
    }
    
    // MARK: - Gesture Recognizers
    @objc func handleTapGestureRecognizer(_ sender: UITapGestureRecognizer) {
        if selected && !allowsMultipleSelection {
            return
        }
        onDidRequestSelection?(self)
    }
    
}

extension WSTagView: UIKeyInput {
    
    public var hasText: Bool {
        return true
    }
    
    public func insertText(_ text: String) {
        onDidInputText?(self, text)
    }
    
    public func deleteBackward() {
        onDidRequestDelete?(self, nil)
    }
    
}
