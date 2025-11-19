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
            labelView(.compact, isProxy: isProxy, measure: measureLabel, participatesInMatch: !isProxy)
        }
        .padding(.horizontal, constants.compact.horizontalPadding)
        .padding(.vertical, constants.compact.verticalPadding)
        .background(SizeReader(size: contentSizeBinding))
    }
    
    private func expandedBody(
        isProxy: Bool = false,
        participatesInMatch: Bool = true,
        measureLabel: Bool = true
    ) -> some View {
        VStack(alignment: .leading, spacing: constants.expanded.bodySpacing) {
            HStack(alignment: .center, spacing: constants.expanded.headerSpacing) {
                iconView(isProxy: isProxy)
                labelView(
                    .expanded,
                    isProxy: isProxy,
                    measure: measureLabel,
                    participatesInMatch: participatesInMatch && !isProxy
                )
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
            if !isProxy {
                compactBody(isProxy: true)
                    .hidden()
                    .accessibilityHidden(true)
                    .allowsHitTesting(false)
            }
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

    private var expandedLabelBinding: Binding<CGSize> {
        Binding<CGSize>(
            get: { expandedState.observedLabel },
            set: { updateExpandedLabelSize($0) }
        )
    }
    
    private func iconView(isProxy: Bool = false) -> some View {
        icon()
            .conditionalMatchedGeometryEffect(id: "floatinghud-icon", in: namespace, isProxy: isProxy)
    }
    
    private enum LabelMode {
        case compact
        case expanded
    }
    
    private func labelView(
        _ mode: LabelMode,
        isProxy: Bool = false,
        measure: Bool,
        participatesInMatch: Bool = true
    ) -> AnyView {
        var view = AnyView(compactContent())
        if mode == .compact, let font = constants.compact.labelFont {
            view = AnyView(view.font(font))
        } else if mode == .expanded, let expandedFont = constants.expanded.labelFont {
            view = AnyView(view.font(expandedFont))
        }
        if measure {
            view = AnyView(
                view.background(SizeReader(size: measurementBinding(for: mode)))
            )
        }
        view = AnyView(
            view
                .lineLimit(1)
                .allowsTightening(false)
                .fixedSize(horizontal: mode == .compact, vertical: false)
        )
        if participatesInMatch {
            return AnyView(
                view.conditionalMatchedGeometryEffect(
                    id: "floatinghud-label",
                    in: namespace,
                    isProxy: isProxy,
                    properties: .position,
                    anchor: .topLeading
                )
            )
        } else {
            return view
        }
    }

    private func measurementBinding(for mode: LabelMode) -> Binding<CGSize> {
        switch mode {
        case .compact:
            return labelSizeBinding
        case .expanded:
            return expandedLabelBinding
        }
    }
    
    

    private var expandedMeasurementOverlay: some View {
        expandedBody(isProxy: true, participatesInMatch: false, measureLabel: true)
            .frame(width: expandedTargetWidth)
            .background(SizeReader(size: expandedSizeBinding))
            .hidden()
            .accessibilityHidden(true)
            .allowsHitTesting(false)
    }
    
    private func updateLabelSize(_ newSize: CGSize) {
        guard newSize.width > 0, newSize.height > 0 else { return }
        withAnimation(constants.animations.expansion) {
            var state = compactState
            state.updateLabelSize(newSize)
            compactState = state
        }
    }
    
    private func updateContentSize(_ newSize: CGSize) {
        guard newSize.width > 0, newSize.height > 0 else { return }
        var state = compactState
        state.updateContentSize(newSize)
        compactState = state
    }

    private func updateExpandedLabelSize(_ newSize: CGSize) {
        guard newSize.width > 0, newSize.height > 0 else { return }
        withAnimation(constants.animations.expansion) {
            expandedState.updateLabelSize(newSize)
        }
    }
}

extension View {
    func conditionalMatchedGeometryEffect(
        id: String,
        in namespace: Namespace.ID,
        isProxy: Bool,
        properties: MatchedGeometryProperties = .frame,
        anchor: UnitPoint = .center
    ) -> some View {
        if isProxy {
            return AnyView(self)
        } else {
            return AnyView(self.matchedGeometryEffect(id: id, in: namespace, properties: properties, anchor: anchor))
        }
    }
}
