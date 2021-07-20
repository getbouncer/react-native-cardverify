//
//  CustomVerifyCardAddViewController.swift
//  RNCardVerify
//
//  Created by Jaime Park on 7/16/21.
//

import CardVerify
import Foundation
import UIKit

// MARK: Custom Verify
class RNCardVerifyAddViewController: VerifyCardAddViewController {
    var verifyStyle = RNCardVerifyViewStyle()
    lazy var instructionLabel = UILabel()
    
    init(userId: String, viewStyle: NSDictionary?) {
        super.init(userId: userId)
        handleVerifyStyleDictionary(viewStyle: viewStyle)
    }
    
    @objc required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        enableManualEntry = verifyStyle.enableManualCardEntry ?? true
        super.viewDidLoad()
    }
    
    func handleVerifyStyleDictionary(viewStyle: NSDictionary?) {
        guard let dict = viewStyle,
              let data = try? JSONSerialization.data(withJSONObject: dict, options: []),
              let decodedVerifyStyle = try? JSONDecoder().decode(RNCardVerifyViewStyle.self, from: data) else {
            return
        }
        
        self.verifyStyle = decodedVerifyStyle
    }
        
    override func setupUiComponents() {
        super.setupUiComponents()
        setupInstructionUI()
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // only turn on these constraints if we have instructions to show
        if let _ = verifyStyle.instructionText {
            instructionLabel.translatesAutoresizingMaskIntoConstraints = false
            instructionLabel.centerXAnchor.constraint(equalTo: roiView.centerXAnchor, constant: 0).isActive = true
            instructionLabel.topAnchor.constraint(equalTo: roiView.bottomAnchor, constant: 15).isActive = true
            RNCardVerifyAddViewController.manualCardEntryButton.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 10).isActive = true
        }
    }
    
    // MARK: -- Instruction UI --
    func setupInstructionUI() {
        if let instructionText = verifyStyle.instructionText {
            instructionLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 75))
            instructionLabel.text = instructionText
            instructionLabel.textAlignment = .center
            instructionLabel.numberOfLines = 2
            instructionLabel.textColor = .white
            
            if let instructionTextColor = verifyStyle.instructionTextColor {
                instructionLabel.textColor = UIColor(hexString: instructionTextColor)
            }
            
            if let intructionTextFont = verifyStyle.instructionTextFont {
                instructionLabel.font = UIFont(name: intructionTextFont, size: 15)
            }
            
            if let instructionTextSize = verifyStyle.instructionTextSize {
                instructionLabel.font = instructionLabel.font.withSize(instructionTextSize)
            }
            
            self.view.addSubview(instructionLabel)
        }
    }
    
    //MARK: -- Background UI --
    override public func setupBlurViewUi() {
        super.setupBlurViewUi()
        
        if let backgroundColor = verifyStyle.backgroundColor {
            blurView.backgroundColor = UIColor(hexString: backgroundColor).withAlphaComponent(verifyStyle.backgroundColorOpacity ?? 0.5)
        }
    }
    
    // MARK: -- ROI UI --
    override public func setupRoiViewUi() {
        super.setupRoiViewUi()
        if let roiCornerRadius = verifyStyle.roiCornerRadius {
            regionOfInterestCornerRadius = roiCornerRadius
        }
        
        if let roiBorderColor = verifyStyle.roiBorderColor {
            roiView.layer.borderColor = UIColor(hexString: roiBorderColor).cgColor
        }
    }

    // MARK: -- Description UI --
    override public func setupDescriptionTextUi() {
        super.setupDescriptionTextUi()
        
        if let descriptionHeaderText = verifyStyle.descriptionHeaderText {
            descriptionText.text = descriptionHeaderText
        }
        
        if let descriptionTextColor = verifyStyle.descriptionHeaderTextColor {
            descriptionText.textColor = UIColor(hexString: descriptionTextColor)
        }
        
        if let descriptionTextFont = verifyStyle.descriptionHeaderTextFont {
            descriptionText.font = UIFont(name: descriptionTextFont, size: 30)
        }
        
        if let descriptionTextSize = verifyStyle.descriptionHeaderTextSize {
            descriptionText.font = descriptionText.font.withSize(descriptionTextSize)
        }
    }

    // MARK: -- Close UI --
    override public func setupCloseButtonUi() {
        super.setupCloseButtonUi()
        closeButton.setTitle("", for: .normal)
        
        if let backButtonTintColor = verifyStyle.backButtonTintColor {
            closeButton.tintColor = UIColor(hexString: backButtonTintColor)
        }
        
        if let backArrowImage = UIImage(named: "bouncer_verify_back") {
            closeButton.setImage(backArrowImage, for: .normal)
        }
    }

    // MARK: -- Torch UI --
    override public func setupTorchButtonUi() {
        super.setupTorchButtonUi()
        torchButton.setTitle("", for: .normal)
        
        if let torchButtonTintColor = verifyStyle.torchButtonTintColor {
            torchButton.tintColor = UIColor(hexString: torchButtonTintColor)
        }
        
        if let torchImage = UIImage(named: "bouncer_verify_flash_on") {
            torchButton.setImage(torchImage, for: .normal)
        }
    }

    override public func setupTorchButtonConstraints() {
        let torchButtonPosition = TorchPosition(rawValue: verifyStyle.torchButtonPosition ?? 0)
        let margins = view.layoutMarginsGuide

        let topRightConstraints = [
            torchButton.topAnchor.constraint(equalTo: margins.topAnchor, constant: 16.0),
            torchButton.trailingAnchor.constraint(equalTo: margins.trailingAnchor)
        ]

        let bottomConstraints = [
            torchButton.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -50.0),
            torchButton.centerXAnchor.constraint(equalTo: margins.centerXAnchor, constant: 0.0)
        ]

        switch torchButtonPosition {
        case .topRight:
            NSLayoutConstraint.activate(topRightConstraints)
        case .bottom:
            NSLayoutConstraint.activate(bottomConstraints)
        case .none:
            NSLayoutConstraint.activate(topRightConstraints)
        }
    }

    override func torchButtonPress() {
        super.torchButtonPress()

        if isTorchOn() {
            torchButton.setImage(UIImage(named: "bouncer_verify_flash_off"), for: .normal)
        } else {
            torchButton.setImage(UIImage(named: "bouncer_verify_flash_on"), for: .normal)
        }
    }

    // MARK: -- Permissions UI --
    override public func setupDenyUi() {
        super.setupDenyUi()
        
        let text = verifyStyle.enableCameraPermissionText ?? RNCardVerifyAddViewController.enableCameraPermissionString
        let attributedString = NSMutableAttributedString(string: text)
        enableCameraPermissionsText.text = text
        
        if let textColor = verifyStyle.enableCameraPermissionTextColor {
            attributedString.addAttribute(NSAttributedString.Key.underlineColor, value: UIColor(hexString: textColor), range: NSRange(location: 0, length: text.count))
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(hexString: textColor), range: NSRange(location: 0, length: text.count))
            attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: text.count))
            enableCameraPermissionsText.textColor = UIColor(hexString: textColor)
        }
        
        var font: UIFont? = UIFont.systemFont(ofSize: 15)
        
        if let enableCameraPermissionFont = verifyStyle.enableCameraPermissionTextFont {
            font = UIFont(name: enableCameraPermissionFont, size: 15)
        }
        
        if let fontSize = verifyStyle.enableCameraPermissionTextSize {
            font = font?.withSize(fontSize)
        }
        
        attributedString.addAttribute(NSAttributedString.Key.font, value: font, range: NSRange(location: 0, length: text.count))
        enableCameraPermissionsButton.setAttributedTitle(attributedString, for: .normal)
        enableCameraPermissionsText.textAlignment = .center
    }

    // MARK: -- Manual Card Entry --
    override func setUpManualCardEntryButtonUI() {
        super.setUpManualCardEntryButtonUI()

        let text = verifyStyle.manualCardEntryText ?? RNCardVerifyAddViewController.manualCardEntryText
        let attributedString = NSMutableAttributedString(string: text)
        
        if let textColor = verifyStyle.manualCardEntryTextColor {
            attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: text.count))
            attributedString.addAttribute(NSAttributedString.Key.underlineColor, value: UIColor(hexString: textColor), range: NSRange(location: 0, length: text.count))
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(hexString: textColor), range: NSRange(location: 0, length: text.count))
        }
        
        var font: UIFont? = UIFont.systemFont(ofSize: 15)
        
        if let manualCardEntryFont = verifyStyle.manualCardEntryTextFont {
            font = UIFont(name: manualCardEntryFont, size: 15)
        }
        
        if let manualCardEntryFontsize = verifyStyle.manualCardEntryTextSize {
            font = font?.withSize(manualCardEntryFontsize)
        }
        
        attributedString.addAttribute(NSAttributedString.Key.font, value: font, range: NSRange(location: 0, length: text.count))
        RNCardVerifyAddViewController.manualCardEntryButton.setAttributedTitle(attributedString, for: .normal)
    }

    //MARK: -- Card Detail UI --
    override public func setupCardDetailsUi() {
        super.setupCardDetailsUi()
        
        if let numberColor = verifyStyle.cardDetailNumberTextColor {
            numberText.textColor = UIColor(hexString: numberColor)
        }
        
        if let nameColor = verifyStyle.cardDetailNameTextColor {
            nameText.textColor = UIColor(hexString: nameColor)
        }
        
        if let expiryColor = verifyStyle.cardDetailExpiryTextColor {
            expiryText.textColor = UIColor(hexString: expiryColor)
        }
    }
}
