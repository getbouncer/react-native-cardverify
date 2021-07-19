//
//  CustomVerifyViewController.swift
//  RNCardVerify
//
//  Created by Jaime Park on 7/16/21.
//

import CardVerify
import Foundation
import UIKit


// MARK: Custom Verify
class CustomVerifyCardViewController: VerifyCardViewController {
    // image should be set in Images.xcassets with the same names
    var backgroundColor: UIColor = #colorLiteral(red: 0.4303786599, green: 1, blue: 0.8281913605, alpha: 0.4982385928)
    var backgroundColorOpacity: CGFloat = 0.5
    
    var cornerRadius: CGFloat = 0.0
    
    var descriptionLabelText = "Description Text"
    var descriptionLabelTextSize: CGFloat = 20.0
    var descriptionLabelTextColor = UIColor.blue
    
    var cardDetailNameTextColor = UIColor.white
    var cardDetailExpiryTextColor = UIColor.white
    var cardDetailNumberTextColor = UIColor.white
    
    var instructionText = "Position your card"
    
    var enableCameraPermissionText = "Enable Camera Permission Text~~~"
    var enableCameraPermissionTextColor = UIColor.white
    
    var torchPosition: TorchPosition = .topRight
    
    init(userId: String?,
         lastFour: String,
         bin: String?,
         viewStyle: NSDictionary?
    ) {
        super.init(userId: userId, lastFour: lastFour, bin: bin, cardNetwork: nil)
        handleVerifyStyleDictionary(viewStyle: viewStyle)
    }
    
    @objc required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        instructionUI()
    }
    
    func handleVerifyStyleDictionary(viewStyle: NSDictionary?) {
        guard let dict = viewStyle else {
            return
        }
        
        if let color = dict["backgroundColor"] as? String {
            let opacity = dict["backgroundColorOpacity"] as? CGFloat
            self.backgroundColor =
                UIColor(hexString: color).withAlphaComponent(opacity ?? backgroundColorOpacity)
        }
        
        if let cornerRadius = dict["cornerRadius"] as? CGFloat {
            self.cornerRadius = cornerRadius
        }
        
        if let descriptionText = dict["descriptionHeaderText"] as? String {
            self.descriptionLabelText = descriptionText
        }
        
        if let descriptionTextColor = dict["descriptionHeaderTextColor"] as? String {
            self.descriptionLabelTextColor = UIColor(hexString: descriptionTextColor)
        }
        
        if let descriptionTextSize = dict["descriptionHeaderTextSize"] as? CGFloat {
            self.descriptionLabelTextSize = descriptionTextSize
        }
        
        if let enableCameraPermissionText = dict["enableCameraPermissionText"] as? String {
            self.enableCameraPermissionText = enableCameraPermissionText
        }
        
        if let enableCameraPermissionTextColor = dict["enableCameraPermissionTextColor"] as? String {
            self.enableCameraPermissionTextColor = UIColor.init(hexString: enableCameraPermissionTextColor)
        }
        
        if let torchPositionValue = dict["torchPosition"] as? Int,
           let torchPosition = TorchPosition(rawValue: torchPositionValue) {
            self.torchPosition = torchPosition
        }
    }
    
    //MARK: -- Background UI --
    override public func setupBlurViewUi() {
        super.setupBlurViewUi()
        blurView.backgroundColor = backgroundColor
    }
    
    // MARK: -- ROI UI --
    override public func setupRoiViewUi() {
        super.setupRoiViewUi()
        regionOfInterestCornerRadius = cornerRadius
    }
    
    // MARK: -- Description UI --
    override public func setupDescriptionTextUi() {
        super.setupDescriptionTextUi()
        descriptionText.text = descriptionLabelText
        descriptionText.font = UIFont.boldSystemFont(ofSize: descriptionLabelTextSize)
        descriptionText.textColor = descriptionLabelTextColor
    }
    
    // MARK: -- Close UI --
    override public func setupCloseButtonUi() {
        super.setupCloseButtonUi()
        closeButton.setTitle("", for: .normal)
        
        if let backArrowImage = UIImage(named: "bouncer_verify_back") {
            closeButton.setImage(backArrowImage, for: .normal)
        }
    }
    
    // MARK: -- Torch UI --
    override public func setupTorchButtonUi() {
        super.setupTorchButtonUi()
        torchButton.setTitle("", for: .normal)
        
        if let torchImage = UIImage(named: "bouncer_verify_flash_on") {
            torchButton.setImage(torchImage, for: .normal)
        }
    }
    
    override public func setupTorchButtonConstraints() {
        let margins = view.layoutMarginsGuide
        
        let topRightConstraints = [
            torchButton.topAnchor.constraint(equalTo: margins.topAnchor, constant: 16.0),
            torchButton.trailingAnchor.constraint(equalTo: margins.trailingAnchor)
        ]
        
        let bottomConstraints = [
            torchButton.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -30.0),
            torchButton.centerXAnchor.constraint(equalTo: margins.centerXAnchor, constant: 0.0)
        ]
        
        switch torchPosition {
        case .topRight:
            NSLayoutConstraint.activate(topRightConstraints)
        case .bottom:
            NSLayoutConstraint.activate(bottomConstraints)
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
        let text = "Enable Camera Access Button"
        let font = UIFont.systemFont(ofSize: 20.0)
        
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSAttributedString.Key.underlineColor, value: UIColor.purple, range: NSRange(location: 0, length: text.count))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.purple, range: NSRange(location: 0, length: text.count))
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: text.count))
        attributedString.addAttribute(NSAttributedString.Key.font, value: font, range: NSRange(location: 0, length: text.count))

        enableCameraPermissionsButton.setAttributedTitle(attributedString, for: .normal)
        
        enableCameraPermissionsText.text = enableCameraPermissionText
        enableCameraPermissionsText.textColor = enableCameraPermissionTextColor
        enableCameraPermissionsText.textAlignment = .center
    }
    
    // MARK: -- Instruction UI --
    func instructionUI() {
        let instructionLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 60))
        instructionLabel.text = instructionText

        self.view.addSubview(instructionLabel)

        let instructionLabelConstraints = [
            instructionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            instructionLabel.topAnchor.constraint(equalTo: roiView.bottomAnchor, constant: 15)
        ]

        NSLayoutConstraint.activate(instructionLabelConstraints)
    }
    
    //MARK: -- Card Detail UI --
    override public func setupCardDetailsUi() {
        super.setupCardDetailsUi()
        numberText.textColor = cardDetailNameTextColor
        expiryText.textColor = cardDetailExpiryTextColor
        nameText.textColor = cardDetailNameTextColor
    }
}

