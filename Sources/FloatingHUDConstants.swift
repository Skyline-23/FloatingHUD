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
    public var verticalMargin: CGFloat
    public var expansionAnimation: Animation
    public var attachmentAnimation: Animation
    public var dramaticCollapseSpring: Animation
    public var cardStyle: FloatingHUDCardStyle
    public var expandedLabelScale: CGFloat
    
    public init(
        compactIconSize: CGFloat = 20,
        compactIconPadding: CGFloat = 1,
        compactSpacing: CGFloat = 4,
        compactHorizontalPadding: CGFloat = 8,
        compactVerticalPadding: CGFloat = 10,
        expandedHeight: CGFloat = 260,
        expandedWidthMax: CGFloat = 360,
        horizontalMargin: CGFloat = 8,
        verticalMargin: CGFloat = 10,
        expansionAnimation: Animation = .interactiveSpring(response: 0.27, dampingFraction: 0.7, blendDuration: 0.02),
        attachmentAnimation: Animation = .interactiveSpring(response: 0.3, dampingFraction: 0.74, blendDuration: 0.04),
        dramaticCollapseSpring: Animation = .spring(response: 0.48, dampingFraction: 0.6, blendDuration: 0.05),
        cardStyle: FloatingHUDCardStyle = .material,
        expandedLabelScale: CGFloat = 1.25
    ) {
        self.compactIconSize = compactIconSize
        self.compactIconPadding = compactIconPadding
        self.compactSpacing = compactSpacing
        self.compactHorizontalPadding = compactHorizontalPadding
        self.compactVerticalPadding = compactVerticalPadding
        self.expandedHeight = expandedHeight
        self.expandedWidthMax = expandedWidthMax
        self.horizontalMargin = horizontalMargin
        self.verticalMargin = verticalMargin
        self.expansionAnimation = expansionAnimation
        self.attachmentAnimation = attachmentAnimation
        self.dramaticCollapseSpring = dramaticCollapseSpring
        self.cardStyle = cardStyle
        self.expandedLabelScale = expandedLabelScale
    }
    
    // Return a fresh instance to avoid sharing mutable state across concurrency domains.
    public static var `default`: FloatingHUDConstants {
        FloatingHUDConstants()
    }
}

public struct FloatingHUDCardStyle {
    public struct Shadow {
        public var color: Color
        public var radius: CGFloat
        public var x: CGFloat
        public var y: CGFloat
        
        public init(color: Color, radius: CGFloat, x: CGFloat = 0, y: CGFloat = 0) {
            self.color = color
            self.radius = radius
            self.x = x
            self.y = y
        }
    }
    
    public struct Visuals {
        public var background: (RoundedRectangle) -> AnyView
        public var shadow: Shadow?
        
        public init(
            background: @escaping (RoundedRectangle) -> AnyView,
            shadow: Shadow? = nil
        ) {
            self.background = background
            self.shadow = shadow
        }
    }
    
    public var compact: Visuals
    public var expanded: Visuals
    
    public init(compact: Visuals, expanded: Visuals) {
        self.compact = compact
        self.expanded = expanded
    }
    
    public func visuals(for isExpanded: Bool) -> Visuals {
        isExpanded ? expanded : compact
    }
    
    public static var material: FloatingHUDCardStyle {
        let strokeColor = Color.white.opacity(0.2)
        let compactShadow = Shadow(color: Color.black.opacity(0.18), radius: 14, x: 0, y: 10)
        let expandedShadow = Shadow(color: Color.black.opacity(0.25), radius: 22, x: 0, y: 16)
        let background: (RoundedRectangle) -> AnyView = { shape in
            AnyView(
                shape
                    .fill(.ultraThinMaterial)
                    .overlay(shape.stroke(strokeColor, lineWidth: 1))
            )
        }
        return FloatingHUDCardStyle(
            compact: Visuals(background: background, shadow: compactShadow),
            expanded: Visuals(background: background, shadow: expandedShadow)
        )
    }
    
}
