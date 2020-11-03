//
//  GPInputBar.swift
//  Example
//
//  Created by Gapo on 10/28/20.
//  Copyright © 2020 Nathan Tannar. All rights reserved.
//

import UIKit
import InputBarAccessoryView
//import ISEmojiView

class GapoInputBar: InputBarAccessoryView {
    
    static let likeIcon: String = "👍"
    
    let leftStackCollapseWidth: CGFloat = 30.0
    let leftStackExpandWidth: CGFloat = 84.0
    let leftStackExpandWidthWithDonate: CGFloat = 120.0
    let rightStackWidth: CGFloat = 77.0
    let itemHeight: CGFloat = 36
    let middleContentPadding: CGFloat = -28.0
    
    var isCollapsed: Bool = false
    var isQuickSend: Bool = false
    var isEmoji: Bool = false
    
    var tapAlphabetGesture: UITapGestureRecognizer!
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    var shouldShowDonate: Bool = false
    
   
    
    lazy var expandButton: InputBarButtonItem = {
        let button = InputBarButtonItem()
            .configure {
                $0.image = UIImage(named: "ic_expand_chat")
                $0.setSize(CGSize(width: 24, height: itemHeight), animated: false)
        }
        .onTouchUpInside { [unowned self] item in
            self.expand()
        }
        return button
    }()
    
    lazy var cameraButton: InputBarButtonItem = {
        let button = InputBarButtonItem()
            .configure {
                $0.image = UIImage(named: "ic-camera-chat")
                $0.setSize(CGSize(width: 26, height: itemHeight), animated: false)
        }
        .onTouchUpInside { [weak self] item in
            self?.onCamera?()
        }
        return button
    }()
    
    lazy var galleryButton: InputBarButtonItem = {
        let button = InputBarButtonItem()
            .configure {
                $0.image = UIImage(named: "ic-photo-chat")
                $0.setSize(CGSize(width: 26, height: itemHeight), animated: false)
        }
        .onTouchUpInside { [weak self] item in
            self?.onGallery?()
        }
        return button
    }()
    
    
    lazy var stickerButton: InputBarButtonItem = {
        let button = InputBarButtonItem()
        .configure {
            $0.spacing = .none
            $0.contentMode = .scaleAspectFill
            $0.image = UIImage(named: "ic-emotion-chat-active")
            $0.setSize(CGSize(width: 21, height: itemHeight), animated: false)
        }
        .onTouchUpInside { [unowned self] item in
            guard let textView = item.inputBarAccessoryView?.inputTextView else { return }
            self.isEmoji = !self.isEmoji
            if self.isEmoji {
//                self.showSticker()
            } else {
                self.showKeyboard()
            }
            textView.reloadInputViews()
        }
        return button
    }()
    
    lazy var likeButton: InputBarButtonItem = {
        let button = InputBarButtonItem()
        .configure {
            $0.spacing = .none
            $0.contentMode = .scaleAspectFill
            $0.image = UIImage(named: "ic_like_chat")
            $0.setSize(CGSize(width: itemHeight, height: itemHeight), animated: false)
        }
        .onTouchUpInside { [weak self] item in
            self?.onQuickSend?()
        }
        return button
    }()
    
    lazy var quoteView: UIView = {
        let view: UIView = UIView()
       
        return view
    }()
    
    var onCamera: (() -> Void)?
    var onQuickSend: (() -> Void)?
    var onGallery: (() -> Void)?
    
    var onCloseReply: (() -> Void)?
    
    override func inputTextViewDidChange() {
        super.inputTextViewDidChange()
        if !isCollapsed {
            collapsed()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        separatorLine.isHidden = true
        setRightStackViewWidthConstant(to: rightStackWidth, animated: false)
        middleContentViewPadding.right = middleContentPadding
        self.topStackViewPadding = UIEdgeInsets(top: 3, left: 0, bottom: 0, right: 0)
        //Default show camera & gallery
        expand(animated: false)
        //Default show like button
        switchSend(animated: false)
        layoutSendButton()
        layoutInputTextView()
        textViewActions()
    }
    
    private func textViewActions() {
        tapAlphabetGesture = UITapGestureRecognizer(target: self, action: #selector(GapoInputBar.textViewTap))
        inputTextView.addGestureRecognizer(tapAlphabetGesture)
        tapAlphabetGesture.isEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(GapoInputBar.inputTextViewDidEndEditing), name: UITextView.textDidEndEditingNotification, object: inputTextView)
    }
    
    
    
    private func showQuoteView(active: Bool) {
        let topStackView = self.topStackView
        quoteView.isHidden = !active
        if active && !topStackView.arrangedSubviews.contains(self.quoteView) {
            topStackView.insertArrangedSubview(self.quoteView, at: topStackView.arrangedSubviews.count)
            topStackView.layoutIfNeeded()
            self.invalidateIntrinsicContentSize()
        } else if !active && topStackView.arrangedSubviews.contains(self.quoteView) {
            topStackView.removeArrangedSubview(self.quoteView)
            topStackView.layoutIfNeeded()
            self.invalidateIntrinsicContentSize()
        }
    }
    
    private func layoutSendButton() {
        sendButton.configure {
            $0.setSize(CGSize(width: itemHeight, height: itemHeight), animated: false)
            $0.setImage(UIImage(named: "ic-send-green"), for: UIControl.State.normal)
            $0.setTitle(nil, for: UIControl.State.normal)
        }.onEnabled { [weak self] (_) in
            self?.switchSend(show: false, animated: true)
        }.onDisabled { [weak self] (_) in
            self?.switchSend(show: true, animated: true)
        }
    }
    
    private func layoutInputTextView() {
        inputTextView.backgroundColor = UIColor.red
        inputTextView.tintColor = UIColor.green
        inputTextView.placeholderTextColor = UIColor.gray
        inputTextView.textContainerInset = UIEdgeInsets(top: 7, left: 8, bottom: 5, right: 28)
        inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 7, left: 12, bottom: 5, right: 20)
        inputTextView.layer.cornerRadius = 18
        inputTextView.layer.masksToBounds = true
        inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        maxTextViewHeight = 84.0
    }
    
    private func collapsed() {
        isCollapsed = true
        setStackViewItems([expandButton, InputBarButtonItem.fixedSpace(10)], forStack: .left, animated: false)
        setLeftStackViewWidthConstant(to: leftStackCollapseWidth, animated: true)
    }
    
    private func expand(animated: Bool = true) {
        isCollapsed = false
        if shouldShowDonate {
            setStackViewItems([InputBarButtonItem.fixedSpace(2), InputBarButtonItem.fixedSpace(15), cameraButton, InputBarButtonItem.fixedSpace(15), galleryButton, InputBarButtonItem.fixedSpace(15)], forStack: .left, animated: animated)
            setLeftStackViewWidthConstant(to: leftStackExpandWidthWithDonate, animated: animated)
        } else {
            setStackViewItems([InputBarButtonItem.fixedSpace(2), cameraButton, InputBarButtonItem.fixedSpace(15), galleryButton, InputBarButtonItem.fixedSpace(15)], forStack: .left, animated: animated)
            setLeftStackViewWidthConstant(to: leftStackExpandWidth, animated: animated)
        }
    }
    
    private func switchSend(show: Bool = true, animated: Bool = true) {
        if isQuickSend == show {
            return
        }
        isQuickSend = show
        var rightButtons: [InputBarButtonItem] = []
        if show {
            rightButtons = [stickerButton, InputBarButtonItem.fixedSpace(20), likeButton]
        } else {
            rightButtons = [stickerButton, InputBarButtonItem.fixedSpace(20), sendButton]
        }
        setStackViewItems(rightButtons, forStack: .right, animated: animated)
    }
    
    @objc open override func inputTextViewDidBeginEditing() {
        super.inputTextViewDidBeginEditing()
        collapsed()
    }
    
    @objc open override func inputTextViewDidEndEditing() {
        super.inputTextViewDidEndEditing()
        expand()
    }
    
    @objc func textViewTap() {
        tapAlphabetGesture.isEnabled = false
        showKeyboard()
    }
    
    
    func showKeyboard() {
        isEmoji = false
        inputTextView.inputView = nil
        inputTextView.reloadInputViews()
        inputTextView.becomeFirstResponder()
        collapsed()
    }

}
