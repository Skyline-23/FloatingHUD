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
    let namespace: Namespace.ID
    let compactContent: () -> CompactContent
    let expandedContent: () -> ExpandedContent
    let icon: () -> Icon
    let constants: FloatingHUDConstants
    
    var body: some View {
        let cornerRadius: CGFloat = isExpanded ? 28 : 18
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        let stackAlignment: Alignment = isExpanded ? .topLeading : .topTrailing
        
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
        .background(
            shape
                .fill(.ultraThinMaterial)
                .overlay(shape.stroke(Color.white.opacity(0.2), lineWidth: 1))
        )
        .shadow(color: Color.black.opacity(isExpanded ? 0.25 : 0.18), radius: isExpanded ? 22 : 14, x: 0, y: isExpanded ? 16 : 10)
        .foregroundStyle(.primary)
        .onChange(of: compactState.observedContent) { newSize in
            updateContentSize(newSize)
        }
        .onChange(of: compactState.observedLabel) { newSize in
            updateLabelSize(newSize)
        }
    }
    
    private func compactBody(isProxy: Bool) -> some View {
        HStack(alignment: .center, spacing: constants.compactSpacing + 2) {
            icon()
            compactContent()
        }
        .padding(.horizontal, constants.compactHorizontalPadding)
        .padding(.vertical, constants.compactVerticalPadding)
        .fixedSize()
        .background(SizeReader(size: contentSizeBinding))
    }
    
    private var expandedBody: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 14) {
                icon()
                expandedContent()
                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
    }
    
    private var contentSizeBinding: Binding<CGSize> {
        Binding<CGSize>(
            get: { compactState.observedContent },
            set: { updateContentSize($0) }
        )
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
