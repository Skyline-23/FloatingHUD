//
//  FlexibleHUDView.swift
//  FloatingHUD
//
//  Created by Buseong Kim on 11/18/25.
//

import SwiftUI

struct FlexibleHUDView<CompactContent: View, ExpandedContent: View, Icon: View, ExpandedLabel: View>: View {
    let isExpanded: Bool
    let targetSize: CGSize
    @Binding var compactState: CompactCardState
    let namespace: Namespace.ID
    let compactContent: () -> CompactContent
    let expandedContent: () -> ExpandedContent
    let icon: () -> Icon
    let expandedLabel: () -> ExpandedLabel
    let usesCustomExpandedLabel: Bool
    let constants: FloatingHUDConstants
    
    var body: some View {
        let cornerRadius: CGFloat = isExpanded ? 28 : 18
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        let stackAlignment: Alignment = isExpanded ? .topLeading : .topTrailing
        let visuals = constants.cardStyle.visuals(for: isExpanded)
        
        ZStack(alignment: stackAlignment) {
            if isExpanded {
                expandedBody
            } else {
                compactBody(isProxy: false)
            }
        }
        .animation(constants.dramaticCollapseSpring, value: isExpanded)
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
        .onChange(of: compactState.observedContent) { newSize in
            updateContentSize(newSize)
        }
        .onChange(of: compactState.observedLabel) { newSize in
            updateLabelSize(newSize)
        }
    }
    
    private func compactBody(isProxy: Bool, measureLabel: Bool = true) -> some View {
        HStack(alignment: .center, spacing: constants.compactSpacing + 2) {
            iconView(isProxy: isProxy)
            compactContentView(isProxy: isProxy, measureLabel: measureLabel)
        }
        .padding(.horizontal, constants.compactHorizontalPadding)
        .padding(.vertical, constants.compactVerticalPadding)
        .fixedSize()
        .background(SizeReader(size: contentSizeBinding))
    }
    
    private var expandedBody: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 14) {
                iconView()
                headerLabelView()
                Spacer(minLength: 0)
            }
            
            Divider().blendMode(.overlay)
            
            expandedContent()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
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
    
    private func iconView(isProxy: Bool = false) -> some View {
        icon()
            .conditionalMatchedGeometryEffect(id: "floatinghud-icon", in: namespace, isProxy: isProxy)
    }
    
    private func compactContentView(isProxy: Bool = false, measureLabel: Bool = true) -> AnyView {
        let view = compactContent()
            .conditionalMatchedGeometryEffect(id: "floatinghud-label", in: namespace, isProxy: isProxy)
        if measureLabel {
            return AnyView(view.background(SizeReader(size: labelSizeBinding)))
        } else {
            return AnyView(view)
        }
    }
    
    private func headerLabelView() -> AnyView {
        if usesCustomExpandedLabel {
            return AnyView(
                expandedLabel()
                    .conditionalMatchedGeometryEffect(id: "floatinghud-label", in: namespace, isProxy: false)
            )
        } else {
            return compactContentView(isProxy: false, measureLabel: false)
        }
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
