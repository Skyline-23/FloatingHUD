//
//  CompactCardState.swift
//  FloatingHUD
//
//  Created by Buseong Kim on 11/18/25.
//

import SwiftUI

struct CompactCardState: Equatable {
    var metrics: HUDCompactMetrics = HUDCompactMetrics()
    var observedContent: CGSize = .zero
    var observedLabel: CGSize = .zero
    
    var measuredWidth: CGFloat {
        let metricWidth = metrics.contentSize.width > 0 ? metrics.contentSize.width : metrics.intrinsicWidth
        let observedWidth = observedContent.width
        return max(metricWidth, max(observedWidth, metrics.minimumWidth))
    }
    
    var measuredHeight: CGFloat {
        if observedContent.height > 0 {
            return max(observedContent.height, metrics.intrinsicHeight)
        }
        return metrics.intrinsicHeight
    }
    
    var compactSize: CGSize {
        CGSize(width: measuredWidth, height: measuredHeight)
    }
    
    mutating func updateLabelSize(_ newSize: CGSize) {
        _ = metrics.updateLabelSizeIfNeeded(newSize)
        if newSize.width > 0, newSize.height > 0 {
            observedLabel = newSize
        }
    }
    
    mutating func updateContentSize(_ newSize: CGSize) {
        _ = metrics.updateContentSizeIfNeeded(newSize)
        if newSize.width > 0, newSize.height > 0 {
            observedContent = newSize
        }
    }
}

struct HUDCompactMetrics: Equatable {
    var labelSize: CGSize = CGSize(width: 80, height: 24)
    var contentSize: CGSize = .zero
    
    var minimumWidth: CGFloat {
        iconBlockWidth + (FloatingHUDConstants.default.compact.horizontalPadding * 2)
    }
    
    var intrinsicWidth: CGFloat {
        if contentSize.width > 0 {
            return max(contentSize.width, minimumWidth)
        }
        return max(fallbackWidthFromLabel, minimumWidth)
    }
    
    var intrinsicHeight: CGFloat {
        if contentSize.height > 0 {
            return max(contentSize.height, fallbackHeightFromLabel)
        }
        return fallbackHeightFromLabel
    }
    
    mutating func updateLabelSizeIfNeeded(_ newSize: CGSize) -> Bool {
        guard newSize.width > 0, newSize.height > 0 else { return false }
        let delta = abs(newSize.width - labelSize.width) + abs(newSize.height - labelSize.height)
        guard delta > 0.5 else { return false }
        labelSize = newSize
        return true
    }
    
    mutating func updateContentSizeIfNeeded(_ newSize: CGSize) -> Bool {
        guard newSize.width > 0, newSize.height > 0 else { return false }
        let delta = abs(newSize.width - contentSize.width) + abs(newSize.height - contentSize.height)
        guard delta > 0.5 else { return false }
        contentSize = newSize
        return true
    }
    
    private var fallbackWidthFromLabel: CGFloat {
        guard labelSize.width > 0 else { return minimumWidth }
        return iconBlockWidth
            + FloatingHUDConstants.default.compact.spacing
            + labelSize.width
            + (FloatingHUDConstants.default.compact.horizontalPadding * 2)
    }
    
    private var fallbackHeightFromLabel: CGFloat {
        let measuredHeight = labelSize.height > 0 ? labelSize.height : iconBlockHeight
        let contentHeight = max(iconBlockHeight, measuredHeight)
        return contentHeight + (FloatingHUDConstants.default.compact.verticalPadding * 2)
    }
    
    private var iconBlockWidth: CGFloat {
        FloatingHUDConstants.default.compact.iconSize + (FloatingHUDConstants.default.compact.iconPadding * 2)
    }
    
    private var iconBlockHeight: CGFloat {
        FloatingHUDConstants.default.compact.iconSize + (FloatingHUDConstants.default.compact.iconPadding * 2)
    }
}

enum HorizontalAnchor {
    case left
    case right
}
