//
//  RNCardVerifyStyle.swift
//  RNCardVerify
//
//  Created by Jaime Park on 7/20/21.
//

import Foundation

public enum TorchPosition: Int {
    case topRight = 0
    case bottom = 1
}

public struct RNCardVerifyViewStyle: Decodable {
  var backButtonTintColor: String?
  
  var backgroundColor: String?
  var backgroundColorOpacity: CGFloat?
  
  var cardDetailExpiryTextColor: String?
  var cardDetailNameTextColor: String?
  var cardDetailNumberTextColor: String?
  
  var descriptionHeaderText: String?
  var descriptionHeaderTextColor: String?
  var descriptionHeaderTextFont: String?
  var descriptionHeaderTextSize: CGFloat?
  
  var enableCameraPermissionText: String?
  var enableCameraPermissionTextColor: String?
  var enableCameraPermissionTextFont: String?
  var enableCameraPermissionTextSize: CGFloat?
  
  var enableManualCardEntry: Bool?
  
  var instructionText: String?
  var instructionTextFont: String?
  var instructionTextColor: String?
  var instructionTextSize: CGFloat?
  
  var manualCardEntryText: String?
  var manualCardEntryTextColor: String?
  var manualCardEntryTextFont: String?
  var manualCardEntryTextSize: CGFloat?
  
  var roiBorderColor: String?
  var roiCornerRadius: CGFloat?
  
  var torchButtonTintColor: String?
  var torchButtonPosition: Int?
  
  var wrongCardText: String?
}
