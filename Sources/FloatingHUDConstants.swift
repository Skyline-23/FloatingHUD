//
//  FloatingHUDConstants.swift
//  FloatingHUD
//
//  Created by Buseong Kim on 11/18/25.
//

import SwiftUI

public struct FloatingHUDConstants {
    public struct CompactConfig {
        /// Icon square size in the compact card.
        public var iconSize: CGFloat
        /// Extra padding around the icon in the compact card.
        public var iconPadding: CGFloat
        /// Spacing between icon and label in compact mode.
        public var spacing: CGFloat
        /// Optional font override for the compact label (if nil, use caller-provided font).
        public var labelFont: Font?
        /// Horizontal padding of the compact card content.
        public var horizontalPadding: CGFloat
        /// Vertical padding of the compact card content.
        public var verticalPadding: CGFloat
        /// Corner radius when compact.
        public var cornerRadius: CGFloat

        public init(
            iconSize: CGFloat,
            iconPadding: CGFloat,
            spacing: CGFloat,
            labelFont: Font?,
            horizontalPadding: CGFloat,
            verticalPadding: CGFloat,
            cornerRadius: CGFloat
        ) {
            self.iconSize = iconSize
            self.iconPadding = iconPadding
            self.spacing = spacing
            self.labelFont = labelFont
            self.horizontalPadding = horizontalPadding
            self.verticalPadding = verticalPadding
            self.cornerRadius = cornerRadius
        }
        
        public static var `default`: CompactConfig {
            CompactConfig(
                iconSize: 20,
                iconPadding: 1,
                spacing: 4,
                labelFont: nil,
                horizontalPadding: 8,
                verticalPadding: 10,
                cornerRadius: 18
            )
        }
    }
    
    public struct ExpandedConfig {
        /// Spacing between icon and label in the expanded header.
        public var headerSpacing: CGFloat
        /// Padding applied to the expanded card content.
        public var horizontalPadding: CGFloat
        public var verticalPadding: CGFloat
        /// Vertical spacing within the expanded body.
        public var bodySpacing: CGFloat
        /// Vertical spacing above/below the divider inside the expanded body.
        public var dividerSpacing: CGFloat
        /// Whether to render the divider in the expanded header/body.
        public var showsDivider: Bool
        /// Optional divider color when expanded (nil = default overlay blend).
        public var dividerColor: Color?
        /// Optional font to apply to the header label while expanded.
        public var labelFont: Font?
        /// Corner radius when expanded.
        public var cornerRadius: CGFloat
        /// Maximum width the expanded card may grow to.
        public var widthMax: CGFloat

        public init(
            headerSpacing: CGFloat,
            horizontalPadding: CGFloat,
            verticalPadding: CGFloat,
            bodySpacing: CGFloat,
            dividerSpacing: CGFloat,
            showsDivider: Bool,
            dividerColor: Color?,
            labelFont: Font?,
            cornerRadius: CGFloat,
            widthMax: CGFloat
        ) {
            self.headerSpacing = headerSpacing
            self.horizontalPadding = horizontalPadding
            self.verticalPadding = verticalPadding
            self.bodySpacing = bodySpacing
            self.dividerSpacing = dividerSpacing
            self.showsDivider = showsDivider
            self.dividerColor = dividerColor
            self.labelFont = labelFont
            self.cornerRadius = cornerRadius
            self.widthMax = widthMax
        }
        
        public static var `default`: ExpandedConfig {
            ExpandedConfig(
                headerSpacing: 14,
                horizontalPadding: 20,
                verticalPadding: 18,
                bodySpacing: 18,
                dividerSpacing: 0,
                showsDivider: true,
                dividerColor: nil,
                labelFont: nil,
                cornerRadius: 28,
                widthMax: 360
            )
        }
    }
    
    public struct Layout {
        /// Horizontal margin used when snapping to edges.
        public var horizontalMargin: CGFloat
        /// Vertical margin used when snapping to edges.
        public var verticalMargin: CGFloat

        public init(horizontalMargin: CGFloat, verticalMargin: CGFloat) {
            self.horizontalMargin = horizontalMargin
            self.verticalMargin = verticalMargin
        }
        
        public static var `default`: Layout {
            Layout(horizontalMargin: 8, verticalMargin: 10)
        }
    }
    
    public struct Animations {
        /// Spring used when expanding/collapsing the card.
        public var expansion: Animation
        /// Spring used when snapping after a drag or size change.
        public var attachment: Animation
        /// Spring used for dramatic collapse on tap.
        public var dramaticCollapse: Animation

        public init(expansion: Animation, attachment: Animation, dramaticCollapse: Animation) {
            self.expansion = expansion
            self.attachment = attachment
            self.dramaticCollapse = dramaticCollapse
        }
        
        public static var `default`: Animations {
            Animations(
                expansion: .interactiveSpring(response: 0.27, dampingFraction: 0.7, blendDuration: 0.02),
                attachment: .interactiveSpring(response: 0.3, dampingFraction: 0.74, blendDuration: 0.04),
                dramaticCollapse: .spring(response: 0.48, dampingFraction: 0.6, blendDuration: 0.05)
            )
        }
    }
    
    /// Compact-mode configuration.
    public var compact: CompactConfig
    /// Expanded-mode configuration.
    public var expanded: ExpandedConfig
    /// Layout margins for snapping.
    public var layout: Layout
    /// Animations used throughout the HUD.
    public var animations: Animations
    /// Card background and shadow styling for compact/expanded.
    public var cardStyle: FloatingHUDCardStyle
    
    /// Initialize all layout/animation knobs for the HUD.
    /// - Parameters:
    ///   - compact: Compact-mode configuration.
    ///   - expanded: Expanded-mode configuration.
    ///   - layout: Margins for snapping/clamping in the container.
    ///   - animations: Springs used for expand/collapse/attach.
    ///   - cardStyle: Background/stroke/shadow configuration.
    public init(
        compact: CompactConfig = .default,
        expanded: ExpandedConfig = .default,
        layout: Layout = .default,
        animations: Animations = .default,
        cardStyle: FloatingHUDCardStyle = .material
    ) {
        self.compact = compact
        self.expanded = expanded
        self.layout = layout
        self.animations = animations
        self.cardStyle = cardStyle
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
