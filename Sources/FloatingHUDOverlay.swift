//
//  FloatingHUDOverlay.swift
//  FloatingHUD
//
//  Created by Buseong Kim on 11/18/25.
//

import SwiftUI

public struct FloatingHUDOverlay<CompactContent: View, ExpandedContent: View, Icon: View>: View {
    @State private var cardIsExpanded = false
    @State private var storedCenter: CGPoint? = nil
    @State private var dragOffset: CGSize = .zero
    @State private var compactState = CompactCardState()
    @State private var expandedState = ExpandedCardState()
    @State private var hasBeenDragged = false
    @State private var currentAnchor: HorizontalAnchor = .right
    @Namespace private var hudNamespace
    
    private let containerSize: CGSize
    private let compactContent: () -> CompactContent
    private let expandedContent: () -> ExpandedContent
    private let icon: () -> Icon
    private let constants: FloatingHUDConstants
    // Keep a configurable offset from the vertical edges; defaults mirror the sample (10pt).
    private var verticalMargin: CGFloat { constants.layout.verticalMargin }
    
    /// Floating HUD entry point.
    /// - Parameters:
    ///   - containerSize: Size of the parent container (usually GeometryReader.size) for snapping/clamping.
    ///   - compact: Compact body content.
    ///   - expanded: Expanded body content.
    ///   - icon: Leading icon shown in both states.
    ///   - constants: Layout/animation/styling knobs; pass a customized `FloatingHUDConstants` to tweak spacing, radii, fonts, etc.
    public init(
        containerSize: CGSize,
        @ViewBuilder compact: @escaping () -> CompactContent,
        @ViewBuilder expanded: @escaping () -> ExpandedContent,
        @ViewBuilder icon: @escaping () -> Icon,
        constants: FloatingHUDConstants = .default
    ) {
        self.containerSize = containerSize
        self.compactContent = compact
        self.expandedContent = expanded
        self.icon = icon
        self.constants = constants
    }
    
    public var body: some View {
        let compactSize = compactState.compactSize
        let baseResolvedSize = cardIsExpanded
            ? resolvedCardSize(in: containerSize, expanded: true)
            : compactSize
        let cardSize = baseResolvedSize
        let baseCenter = storedCenter ?? defaultCenter(for: cardSize, in: containerSize)
        let clampedCenter = snapCenter(baseCenter, cardSize: cardSize, in: containerSize, anchorOverride: nil)
        let dragAdjustedCenter = CGPoint(
            x: clampedCenter.x + dragOffset.width,
            y: clampedCenter.y + dragOffset.height
        )
        
        FlexibleHUDView(
            isExpanded: cardIsExpanded,
            targetSize: cardSize,
            compactState: $compactState,
            namespace: hudNamespace,
            compactContent: compactContent,
            expandedContent: expandedContent,
            icon: icon,
            constants: constants
        )
        .background {
            if cardIsExpanded {
                SizeReader(size: expandedSizeBinding)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            let nextExpanded = !cardIsExpanded
            let nextSize = resolvedCardSize(in: containerSize, expanded: nextExpanded)
            let referencePoint = storedCenter ?? defaultCenter(for: nextSize, in: containerSize)
            let anchor = hasBeenDragged ? currentAnchor : .right
            let nextCenter = snapCenter(referencePoint, cardSize: nextSize, in: containerSize, anchorOverride: anchor)
            withAnimation(constants.animations.dramaticCollapse) {
                storedCenter = nextCenter
                cardIsExpanded = nextExpanded
            }
        }
        .frame(
            width: cardSize.width,
            height: cardSize.height,
            alignment: cardIsExpanded ? .topLeading : .topTrailing
        )
        .position(dragAdjustedCenter)
        .animation(constants.animations.dramaticCollapse, value: cardIsExpanded)
        .highPriorityGesture(dragGesture(cardSize: cardSize, origin: clampedCenter))
        .onAppear {
            storedCenter = clampedCenter
            currentAnchor = .right
        }
        .onChange(of: cardSize.width) { _, _ in
            guard !cardIsExpanded else { return }
            let anchor = currentAnchor
            storedCenter = snapCenter(defaultCenter(for: cardSize, in: containerSize), cardSize: cardSize, in: containerSize, anchorOverride: anchor)
        }
        .onChange(of: compactState.compactSize) { _, newSize in
            guard !cardIsExpanded else { return }
            let anchor = currentAnchor
            withAnimation(constants.animations.attachment) {
                storedCenter = snapCenter(defaultCenter(for: newSize, in: containerSize), cardSize: newSize, in: containerSize, anchorOverride: anchor)
            }
        }
        .onChange(of: containerSize) { _, newValue in
            let collapsedWidth = resolvedCompactWidth(in: newValue)
            let collapsed = CGSize(width: collapsedWidth, height: compactState.measuredHeight)
            let nextCard = cardIsExpanded ? resolvedCardSize(in: newValue, expanded: true) : collapsed
            let reference = hasBeenDragged ? (storedCenter ?? defaultCenter(for: nextCard, in: newValue)) : defaultCenter(for: nextCard, in: newValue)
            withAnimation(constants.animations.attachment) {
                let anchor = hasBeenDragged ? currentAnchor : .right
                storedCenter = snapCenter(reference, cardSize: nextCard, in: newValue, anchorOverride: anchor)
            }
        }
        .onChange(of: expandedState.observedSize) { _, newSize in
            guard cardIsExpanded, newSize.height > 0 else { return }
            let nextCard = resolvedCardSize(in: containerSize, expanded: true)
            withAnimation(constants.animations.attachment) {
                storedCenter = snapCenter(storedCenter ?? defaultCenter(for: nextCard, in: containerSize), cardSize: nextCard, in: containerSize, anchorOverride: currentAnchor)
            }
        }
        .onChange(of: cardIsExpanded) { _, newValue in
            let nextCard = resolvedCardSize(in: containerSize, expanded: newValue)
            withAnimation(constants.animations.expansion) {
                storedCenter = snapCenter(storedCenter ?? defaultCenter(for: nextCard, in: containerSize), cardSize: nextCard, in: containerSize, anchorOverride: currentAnchor)
            }
        }
    }
    
    private func dragGesture(cardSize: CGSize, origin: CGPoint) -> some Gesture {
        DragGesture(minimumDistance: 8)
            .onChanged { value in
                dragOffset = value.translation
                hasBeenDragged = true
            }
            .onEnded { value in
                let finalCenter = CGPoint(
                    x: origin.x + value.translation.width,
                    y: origin.y + value.translation.height
                )
                withAnimation(constants.animations.attachment) {
                    let snapped = snapCenter(finalCenter, cardSize: cardSize, in: containerSize, anchorOverride: nil)
                    storedCenter = snapped
                    dragOffset = .zero
                    currentAnchor = snapped.x >= containerSize.width / 2 ? .right : .left
                    if isDockedToDefault(cardSize: cardSize) {
                        hasBeenDragged = false
                    }
                }
            }
    }
    
    private func resolvedCardSize(in container: CGSize, expanded: Bool) -> CGSize {
        if expanded {
            let compactWidth = resolvedCompactWidth(in: container)
            let availableWidth = max(container.width - (constants.layout.horizontalMargin * 2), compactWidth)
            let width = min(availableWidth, constants.expanded.widthMax)
            let height = expandedState.measuredHeight(fallback: compactState.measuredHeight)
            return CGSize(width: width, height: height)
        } else {
            return compactState.compactSize
        }
    }
    
    private func defaultCenter(for cardSize: CGSize, in container: CGSize) -> CGPoint {
        CGPoint(
            x: container.width - cardSize.width / 2 - constants.layout.horizontalMargin,
            y: container.height - cardSize.height / 2 - (verticalMargin * 2)
        )
    }
    
    private func snapCenter(_ point: CGPoint, cardSize: CGSize, in container: CGSize, anchorOverride: HorizontalAnchor?) -> CGPoint {
        let halfHeight = cardSize.height / 2
        let minY = halfHeight + verticalMargin
        let maxY = max(container.height - halfHeight - verticalMargin, minY)
        let anchor: HorizontalAnchor = anchorOverride ?? (point.x >= container.width / 2 ? .right : .left)
        let anchoredX = anchoredXPosition(for: anchor, cardSize: cardSize, in: container)
        let clampedY = min(max(point.y, minY), maxY)
        return CGPoint(
            x: anchoredX,
            y: clampedY
        )
    }
    
    private func anchoredXPosition(for anchor: HorizontalAnchor, cardSize: CGSize, in container: CGSize) -> CGFloat {
        let halfWidth = cardSize.width / 2
        let minX = halfWidth + constants.layout.horizontalMargin
        let maxX = max(container.width - halfWidth - constants.layout.horizontalMargin, minX)
        switch anchor {
        case .left:
            return minX
        case .right:
            return maxX
        }
    }
    
    private func isDockedToDefault(cardSize: CGSize) -> Bool {
        guard let storedCenter else { return true }
        let defaultPoint = defaultCenter(for: cardSize, in: containerSize)
        return abs(storedCenter.x - defaultPoint.x) < 1.0 && abs(storedCenter.y - defaultPoint.y) < 1.0
    }

    private func resolvedCompactWidth(in container: CGSize) -> CGFloat {
        clampCompactWidth(compactState.measuredWidth, in: container)
    }
    
    private func clampCompactWidth(_ measured: CGFloat, in container: CGSize) -> CGFloat {
        let minWidth = compactState.metrics.minimumWidth
        let available = max(container.width - (constants.layout.horizontalMargin * 2), minWidth)
        let normalized = max(measured, minWidth)
        return min(normalized, available)
    }
    
    private var expandedSizeBinding: Binding<CGSize> {
        Binding<CGSize>(
            get: { expandedState.observedSize },
            set: { expandedState.updateSizeIfNeeded($0) }
        )
    }
}
