//
//  ExpandedCardState.swift
//  FloatingHUD
//
//  Created by Buseong Kim on 11/19/25.
//

import SwiftUI

struct ExpandedCardState {
    var observedSize: CGSize = .zero
    
    func measuredHeight(fallback: CGFloat) -> CGFloat {
        if observedSize.height > 0 { return observedSize.height }
        return fallback
    }
    
    mutating func updateSizeIfNeeded(_ newSize: CGSize) {
        guard newSize.width > 0, newSize.height > 0 else { return }
        let delta = abs(newSize.width - observedSize.width) + abs(newSize.height - observedSize.height)
        guard delta > 0.5 else { return }
        observedSize = newSize
    }
}
