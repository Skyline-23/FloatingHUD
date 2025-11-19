//
//  FlexibleHUDView.swift
//  FloatingHUD
//
//  Created by Buseong Kim on 11/18/25.
//

import SwiftUI

struct FlexibleHUDView<CompactContent: View, ExpandedContent: View, Icon: View>: View {
    let isExpanded: Bool
    let targetSize: CGSize
    @Binding var compactState: CompactCardState
    @Binding var expandedState: ExpandedCardState
    let expandedTargetWidth: CGFloat
    let namespace: Namespace.ID
    let compactContent: () -> CompactContent
    let expandedContent: () -> ExpandedContent
    let icon: () -> Icon
    let constants: FloatingHUDConstants
    
    var body: some View {
        Group {
            if targetSize.width > 0, targetSize.height > 0 {
                content
            } else {
                Color.clear
            }
        }
    }
    
    private var content: some View {
        let cornerRadius: CGFloat = isExpanded ? constants.expanded.cornerRadius : constants.compact.cornerRadius
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        let stackAlignment: Alignment = isExpanded ? .topLeading : .topTrailing
        let visuals = constants.cardStyle.visuals(for: isExpanded)
        
        return ZStack(alignment: stackAlignment) {
            if isExpanded {
                expandedBody()
            } else {
                compactBody(isProxy: false)
            }
        }
        .animation(constants.animations.dramaticCollapse, value: isExpanded)
        .frame(
            width: isExpanded ? targetSize.width : nil,
            height: isExpanded ? targetSize.height : nil,
            alignment: stackAlignment
        )
        .background {
            let base = visuals.background(shape)
            if let shadow = visuals.shadow {
                base.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
            } else {
                base
            }
        }
        .foregroundStyle(.primary)
        .onChange(of: compactState.observedContent) { _, newSize in
            updateContentSize(newSize)
        }
        .onChange(of: compactState.observedLabel) { _, newSize in
            updateLabelSize(newSize)
        }
        .background {
            expandedMeasurementOverlay
        }
    }
    
    private func compactBody(isProxy: Bool, measureLabel: Bool = true) -> some View {
        HStack(alignment: .center, spacing: constants.compact.spacing) {
            iconView(isProxy: isProxy)
            compactContentView(isProxy: isProxy, measureLabel: measureLabel)
        }
        .padding(.horizontal, constants.compact.horizontalPadding)
        .padding(.vertical, constants.compact.verticalPadding)
        .fixedSize()
        .background(SizeReader(size: contentSizeBinding))
    }
    
    private func expandedBody(isProxy: Bool = false, forceExpandedStyle: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: constants.expanded.bodySpacing) {
            HStack(alignment: .center, spacing: constants.expanded.headerSpacing) {
                iconView(isProxy: isProxy)
                headerLabelView(isProxy: isProxy, forceExpandedStyle: forceExpandedStyle)
                Spacer(minLength: 0)
            }
            
            if constants.expanded.showsDivider {
                Divider()
                    .foregroundStyle(constants.expanded.dividerColor ?? .primary.opacity(0.2))
                    .blendMode(constants.expanded.dividerColor == nil ? .overlay : .normal)
                    .padding(.vertical, constants.expanded.dividerSpacing)
            }
            
            expandedContent()
        }
        .padding(.horizontal, constants.expanded.horizontalPadding)
        .padding(.vertical, constants.expanded.verticalPadding)
        .overlay(alignment: .topTrailing) {
            // Keep the compact body in the tree (but hidden) so size observations stay fresh while expanded.
            compactBody(isProxy: true)
                .opacity(0.001)
                .allowsHitTesting(false)
        }
    }
    
    private var contentSizeBinding: Binding<CGSize> {
        Binding<CGSize>(
            get: { compactState.observedContent },
            set: { updateContentSize($0) }
        )
    }
    
    private var labelSizeBinding: Binding<CGSize> {
        Binding<CGSize>(
            get: { compactState.observedLabel },
            set: { updateLabelSize($0) }
        )
    }
    
    private var expandedSizeBinding: Binding<CGSize> {
        Binding<CGSize>(
            get: { expandedState.observedSize },
            set: { expandedState.updateSizeIfNeeded($0) }
        )
    }
    
    private func iconView(isProxy: Bool = false) -> some View {
        icon()
            .conditionalMatchedGeometryEffect(id: "floatinghud-icon", in: namespace, isProxy: isProxy)
    }
    
    private func compactContentView(isProxy: Bool = false, measureLabel: Bool = true, applyScale: Bool = true, forceExpandedStyle: Bool = false) -> AnyView {
        var view: AnyView = AnyView(compactContent())
        if let font = constants.compact.labelFont, !forceExpandedStyle {
            view = AnyView(view.font(font))
        }
        // Apply expanded font override when requested (used for pre-measurement and expanded state).
        if forceExpandedStyle, let expandedFont = constants.expanded.labelFont {
            view = AnyView(view.font(expandedFont))
        }
        if applyScale {
            view = AnyView(view.minimumScaleFactor(constants.labelMinimumScaleFactor))
        }
        let matched: AnyView
        if shouldMatchLabelGeometry {
            matched = AnyView(
                view.conditionalMatchedGeometryEffect(id: "floatinghud-label", in: namespace, isProxy: isProxy)
            )
        } else {
            matched = view
        }
        if measureLabel {
            return AnyView(matched.background(SizeReader(size: labelSizeBinding)))
        } else {
            return AnyView(matched)
        }
    }
    
    private func headerLabelView(isProxy: Bool = false, forceExpandedStyle: Bool = false) -> AnyView {
        let shouldUseExpanded = forceExpandedStyle || isExpanded
        var view = compactContentView(
            isProxy: isProxy,
            measureLabel: false,
            applyScale: !shouldUseExpanded,
            forceExpandedStyle: shouldUseExpanded
        )
        return view
    }
    
    private var expandedMeasurementOverlay: some View {
        expandedBody(isProxy: true, forceExpandedStyle: true)
            .frame(width: expandedTargetWidth)
            .background(SizeReader(size: expandedSizeBinding))
            .opacity(0.001)
            .allowsHitTesting(false)
    }
    
    private var shouldMatchLabelGeometry: Bool {
        // If fonts differ between states, skip matchedGeometryEffect to avoid unintended scaling.
        constants.compact.labelFont == nil && constants.expanded.labelFont == nil
    }
    
    private func updateLabelSize(_ newSize: CGSize) {
        guard newSize.width > 0, newSize.height > 0 else { return }
        var state = compactState
        state.updateLabelSize(newSize)
        compactState = state
    }
    
    private func updateContentSize(_ newSize: CGSize) {
        guard newSize.width > 0, newSize.height > 0 else { return }
        var state = compactState
        state.updateContentSize(newSize)
        compactState = state
    }
}

extension View {
    func conditionalMatchedGeometryEffect(id: String, in namespace: Namespace.ID, isProxy: Bool) -> some View {
        if isProxy {
            return AnyView(self)
        } else {
            return AnyView(self.matchedGeometryEffect(id: id, in: namespace))
        }
    }
}
