//
//  FloatingHUDConstants.swift
//  FloatingHUD
//
//  Created by Buseong Kim on 11/18/25.
//

import SwiftUI

public struct FloatingHUDConstants {
    public var compactIconSize: CGFloat
    public var compactIconPadding: CGFloat
    public var compactSpacing: CGFloat
    public var compactHorizontalPadding: CGFloat
    public var compactVerticalPadding: CGFloat
    public var expandedHeight: CGFloat
    public var expandedWidthMax: CGFloat
    public var horizontalMargin: CGFloat
    public var expansionAnimation: Animation
    public var attachmentAnimation: Animation
    public var dramaticCollapseSpring: Animation
    
    public init(
        compactIconSize: CGFloat = 20,
        compactIconPadding: CGFloat = 1,
        compactSpacing: CGFloat = 4,
        compactHorizontalPadding: CGFloat = 8,
        compactVerticalPadding: CGFloat = 10,
        expandedHeight: CGFloat = 260,
        expandedWidthMax: CGFloat = 360,
        horizontalMargin: CGFloat = 8,
        expansionAnimation: Animation = .interactiveSpring(response: 0.27, dampingFraction: 0.7, blendDuration: 0.02),
        attachmentAnimation: Animation = .interactiveSpring(response: 0.3, dampingFraction: 0.74, blendDuration: 0.04),
        dramaticCollapseSpring: Animation = .spring(response: 0.48, dampingFraction: 0.6, blendDuration: 0.05)
    ) {
        self.compactIconSize = compactIconSize
        self.compactIconPadding = compactIconPadding
        self.compactSpacing = compactSpacing
        self.compactHorizontalPadding = compactHorizontalPadding
        self.compactVerticalPadding = compactVerticalPadding
        self.expandedHeight = expandedHeight
        self.expandedWidthMax = expandedWidthMax
        self.horizontalMargin = horizontalMargin
        self.expansionAnimation = expansionAnimation
        self.attachmentAnimation = attachmentAnimation
        self.dramaticCollapseSpring = dramaticCollapseSpring
    }
    
    // Return a fresh instance to avoid sharing mutable state across concurrency domains.
    public static var `default`: FloatingHUDConstants {
        FloatingHUDConstants()
    }
}
