//
//  UITipView.swift
//
//
//  Created by Seb Vidal on 21/09/2023.
//

import UIKit
import TipKit
import SwiftUI

public class UITipView: UIView {
    // MARK: - Private Properties
    private var contentView: UIView!
    private var _closeButton: UIButton!
    private var imageView: UIImageView!
    private var titleLabel: UILabel!
    private var messageLabel: UILabel!
    private var actionButtons: [UIButton] = []
    private var separatorViews: [UIView] = []
    
    // MARK: - Public Properties
    public var closeButton: UIButton {
        return _closeButton
    }
    
    public var configuration: UITipView.Configuration? = nil {
        didSet { updateUI(for: configuration) }
    }
    
    public override var intrinsicContentSize: CGSize {
        return _intrinsicContentSize()
    }
    
    // MARK: - init(frame:)
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupContentView()
        setupCloseButton()
        setupImageView()
        setupTitleLabel()
        setupMessageLabel()
    }
    
    // MARK: - init?(coder:)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    private func setupContentView() {
        contentView = UIView()
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 12
        contentView.layer.cornerCurve = .continuous
        contentView.backgroundColor = .secondarySystemBackground
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setupCloseButton() {
        let sizeConfig = UIImage.SymbolConfiguration(textStyle: .footnote)
        let weightConfig = UIImage.SymbolConfiguration(weight: .bold)
        
        let image = UIImage(systemName: "xmark")?
            .applyingSymbolConfiguration(sizeConfig)?
            .applyingSymbolConfiguration(weightConfig)
        
        _closeButton = UIButton(type: .system)
        _closeButton.tintColor = .quaternaryLabel
        _closeButton.setImage(image, for: .normal)
        _closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        contentView.addSubview(_closeButton)
    }
    
    @objc private func closeButtonTapped(_ sender: UIButton) {
        
    }
    
    private func setupImageView() {
        imageView = UIImageView()
        imageView.tintColor = .tintColor
        
        contentView.addSubview(imageView)
    }
    
    private func setupTitleLabel() {
        titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        
        contentView.addSubview(titleLabel)
    }
    
    private func setupMessageLabel() {
        messageLabel = UILabel()
        messageLabel.numberOfLines = 0
        messageLabel.textColor = .secondaryLabel
        messageLabel.font = .preferredFont(forTextStyle: .subheadline)
        
        contentView.addSubview(messageLabel)
    }
    
    private func setupActionsButtons(for actions: [UIAction]?) {
        for actionButton in actionButtons {
            actionButton.removeFromSuperview()
        }
        
        actionButtons.removeAll()
        
        for action in actions ?? [] {
            let actionButton = UIButton(type: .system)
            actionButton.setTitle(action.title, for: .normal)
            actionButton.setTitleColor(.tintColor, for: .normal)
            actionButton.addAction(action, for: .touchUpInside)
            actionButton.contentHorizontalAlignment = .leading
            actionButton.titleLabel?.font = .preferredFont(forTextStyle: .body)
            
            actionButtons.append(actionButton)
            contentView.addSubview(actionButton)
        }
    }
    
    private func setupSeparatorViews(for actionButtons: [UIButton]) {
        for _ in actionButtons {
            let separatorView = UIView()
            separatorView.backgroundColor = .separator
            
            separatorViews.append(separatorView)
            contentView.addSubview(separatorView)
        }
    }
    
    private func updateUI(for configuration: UITipView.Configuration?) {
        imageView.image = configuration?.image
        titleLabel.text = configuration?.title
        messageLabel.text = configuration?.message
        setupActionsButtons(for: configuration?.actions)
        setupSeparatorViews(for: actionButtons)
        
        contentView.backgroundColor = configuration?.background.backgroundColor ?? .secondarySystemBackground
        contentView.layer.cornerRadius = configuration?.background.cornerRadius ?? 12
        
        layoutSubviews()
    }
    
    private func _intrinsicContentSize() -> CGSize {
        let subviews = contentView.subviews.sorted { lhs, rhs in
            return lhs.frame.maxY > rhs.frame.maxY
        }
        
        let width = window?.frame.width ?? -1
        var height: CGFloat = subviews[0].frame.maxY
        
        switch subviews[0] {
        case imageView:
            height += 18
        case titleLabel:
            height += 16
        case _closeButton:
            height += 15
        case messageLabel:
            height += 16
        default:
            height += 2
        }
        
        return CGSize(width: width, height: height)
    }
    
    // MARK: - layoutSubviews()
    public override func layoutSubviews() {
        super.layoutSubviews()
        layoutCloseButton()
        layoutImageView()
        layoutTitleLabel()
        layoutMessageLabel()
        layoutActionButtons()
        layoutSeparatorViews()
        invalidateIntrinsicContentSize()
    }
    
    private func layoutCloseButton() {
        let size = _closeButton.sizeThatFits(frame.size)
        let x = frame.width - size.width - 13
        let y: CGFloat = 15
        
        _closeButton.frame.size = size
        _closeButton.frame.origin = CGPoint(x: x, y: y)
    }
    
    private func layoutImageView() {
        if let image = imageView.image {
            let x: CGFloat = 9
            let y: CGFloat = 15
            let width: CGFloat = 52.333
            let height = width / (image.size.width / image.size.height)
            imageView.frame = CGRect(x: x, y: y, width: width, height: height)
        } else {
            imageView.frame = CGRect.zero
        }
    }
    
    private func layoutTitleLabel() {
        if let _ = imageView.image {
            let maxWidth = frame.width - imageView.frame.maxX - _closeButton.frame.width - 28
            let maxSize = CGSize(width: maxWidth, height: frame.height)
            titleLabel.frame.size = titleLabel.sizeThatFits(maxSize)
            
            let x: CGFloat = imageView.frame.maxX + 8
            let y: CGFloat = imageView.frame.minY - 1
            titleLabel.frame.origin = CGPoint(x: x, y: y)
        } else {
            let maxWidth = frame.width - _closeButton.frame.width - 28
            let maxSize = CGSize(width: maxWidth, height: frame.height)
            titleLabel.frame.size = titleLabel.sizeThatFits(maxSize)
            
            let x: CGFloat = 13
            let y: CGFloat = 14
            titleLabel.frame.origin = CGPoint(x: x, y: y)
        }
    }
    
    private func layoutMessageLabel() {
        if let _ = configuration?.message {
            let maxWidth = frame.width - titleLabel.frame.minX - 12
            let maxSize = CGSize(width: maxWidth, height: frame.height)
            messageLabel.frame.size = messageLabel.sizeThatFits(maxSize)
            
            let x: CGFloat = titleLabel.frame.origin.x
            let y: CGFloat = titleLabel.frame.maxY + 4
            messageLabel.frame.origin = CGPoint(x: x, y: y)
        } else {
            messageLabel.frame = .zero
        }
    }
    
    private func layoutActionButtons() {
        let maxWidth = frame.width - titleLabel.frame.origin.x
        let maxSize = CGSize(width: maxWidth, height: frame.height)
        
        let x =  titleLabel.frame.origin.x
        let minY = messageLabel.frame.maxY + 9
        
        for (index, actionButton) in actionButtons.enumerated() {
            let y = index > 0 ? actionButtons[index - 1].frame.maxY : minY
            actionButton.frame.origin = CGPoint(x: x, y: y)
            
            let width = maxWidth
            let height = actionButton.sizeThatFits(maxSize).height + 10
            
            actionButton.frame.size = CGSize(width: width, height: height)
        }
    }
    
    private func layoutSeparatorViews() {
        let x = titleLabel.frame.origin.x
        let width = frame.width - x
        let height: CGFloat = 1.0 / 3.0
        
        for (index, separatorView) in separatorViews.enumerated() {
            let y = actionButtons[index].frame.origin.y
            separatorView.frame = CGRect(x: x, y: y, width: width, height: height)
        }
    }
}
