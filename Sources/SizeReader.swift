//
//  SizeReader.swift
//  FloatingHUD
//
//  Created by Buseong Kim on 11/18/25.
//

import SwiftUI

struct SizeReader: View {
    @Binding var size: CGSize
    
    var body: some View {
        GeometryReader { proxy in
            Color.clear
                .onAppear { size = proxy.size }
                .onChange(of: proxy.size) { size = $0 }
        }
    }
}

#if canImport(UIKit)
import UIKit

// Measures intrinsic size immediately by hosting the content off-screen in UIKit.
struct ImmediateSizeReader<Content: View>: UIViewRepresentable {
    var content: Content
    @Binding var size: CGSize
    
    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        container.isUserInteractionEnabled = false
        
        let controller = UIHostingController(rootView: resolvedContent(from: context.environment))
        controller.view.backgroundColor = .clear
        controller.view.isHidden = true
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(controller.view)
        NSLayoutConstraint.activate([
            controller.view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            controller.view.topAnchor.constraint(equalTo: container.topAnchor)
        ])
        
        context.coordinator.controller = controller
        return container
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let controller = context.coordinator.controller else { return }
        controller.rootView = resolvedContent(from: context.environment)
        let measured = controller.sizeThatFits(in: UIView.layoutFittingCompressedSize).ceiled()
        updateSizeIfNeeded(measured)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    private func updateSizeIfNeeded(_ newSize: CGSize) {
        guard newSize != size else { return }
        if Thread.isMainThread {
            size = newSize
        } else {
            DispatchQueue.main.async {
                self.size = newSize
            }
        }
    }
    
    private func resolvedContent(from environment: EnvironmentValues) -> AnyView {
        AnyView(
            content
                .environment(\.sizeCategory, environment.sizeCategory)
                .environment(\.layoutDirection, environment.layoutDirection)
                .environment(\.locale, environment.locale)
        )
    }
    
    final class Coordinator {
        var controller: UIHostingController<AnyView>?
    }
}
#elseif canImport(AppKit)
import AppKit

// macOS counterpart for immediate intrinsic size measurement.
struct ImmediateSizeReader<Content: View>: NSViewRepresentable {
    var content: Content
    @Binding var size: CGSize
    
    func makeNSView(context: Context) -> NSView {
        let container = NSView()
        container.isHidden = true
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let hostingView = NSHostingView(rootView: resolvedContent(from: context.environment))
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(hostingView)
        NSLayoutConstraint.activate([
            hostingView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            hostingView.topAnchor.constraint(equalTo: container.topAnchor)
        ])
        
        context.coordinator.hostingView = hostingView
        return container
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        guard let hostingView = context.coordinator.hostingView else { return }
        hostingView.rootView = resolvedContent(from: context.environment)
        hostingView.layoutSubtreeIfNeeded()
        let measured = hostingView.fittingSize.ceiled()
        updateSizeIfNeeded(measured)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    private func updateSizeIfNeeded(_ newSize: CGSize) {
        guard newSize != size else { return }
        if Thread.isMainThread {
            size = newSize
        } else {
            DispatchQueue.main.async {
                self.size = newSize
            }
        }
    }
    
    private func resolvedContent(from environment: EnvironmentValues) -> AnyView {
        AnyView(
            content
                .environment(\.sizeCategory, environment.sizeCategory)
                .environment(\.layoutDirection, environment.layoutDirection)
                .environment(\.locale, environment.locale)
        )
    }
    
    final class Coordinator {
        var hostingView: NSHostingView<AnyView>?
    }
}
#endif

private extension CGSize {
    func ceiled() -> CGSize {
        CGSize(width: ceil(width), height: ceil(height))
    }
}
