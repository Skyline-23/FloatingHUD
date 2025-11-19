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
                .onChange(of: proxy.size) { _, newSize in size = newSize }
        }
    }
}
