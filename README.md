# FloatingHUD
A lightweight SwiftUI overlay for a draggable, expandable HUD card. Compact and expanded layouts stay in sync, and the card snaps to screen edges with smooth animations.

## Requirements
- iOS 17+
- SwiftUI
- No external dependencies

## Installation
- Xcode: `File > Add Packages…` (or `Add Local…`) and point to the `FloatingHUD` directory.
- Import: `import FloatingHUD`

## Quick Start
Minimal memory-usage HUD with compact + expanded states.
```swift
import FloatingHUD

struct ContentView: View {
    @State private var containerSize: CGSize = .zero
    @State private var value: Double = 123

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color(.systemBackground)
                    .onAppear { containerSize = proxy.size }
                    .onChange(of: proxy.size) { containerSize = $0 }

                FloatingHUDOverlay(
                    containerSize: containerSize,
                    compact: {
                        HStack(spacing: 8) {
                            Text(String(format: "%.0f MB", value))
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .monospacedDigit()
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 10)
                    },
                    expanded: {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(String(format: "%.1f MB", value))
                                .font(.system(size: 28, weight: .semibold, design: .rounded))
                                .monospacedDigit()
                            Text("Current memory usage")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 18)
                    },
                    icon: {
                        Image(systemName: "memorychip")
                            .font(.title3.weight(.semibold))
                            .symbolRenderingMode(.hierarchical)
                            .frame(width: 20, height: 20)
                            .padding(6)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color.white.opacity(0.12))
                            )
                    }
                )
            }
        }
    }
}
```

## Examples
### Compact-only HUD (no expanded body)
```swift
FloatingHUDOverlay(
    containerSize: containerSize,
    compact: { Text("Ready").padding(.horizontal, 8).padding(.vertical, 10) },
    expanded: { EmptyView() },
    icon: { Circle().fill(.green).frame(width: 12, height: 12) }
)
```

### Custom metric styling (fonts/colors/icon)
```swift
FloatingHUDOverlay(
    containerSize: containerSize,
    compact: {
        HStack(spacing: 4) {
            Text("42%")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundStyle(.mint)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
    },
    expanded: {
        VStack(alignment: .leading, spacing: 6) {
            Text("42.3% CPU")
                .font(.title2.weight(.bold))
                .foregroundStyle(.mint)
            Text("Load average 1.02")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
    },
    icon: {
        Image(systemName: "bolt.fill")
            .font(.headline)
            .foregroundStyle(.yellow)
            .padding(8)
            .background(Circle().fill(.black.opacity(0.2)))
    }
)
```

## Behavior & Contract (with targeted snippets)
- **Snapping**: pass a custom margin for tighter snap.
```swift
let snapConstants = FloatingHUDConstants(horizontalMargin: 2)
FloatingHUDOverlay(
    containerSize: proxy.size,
    compact: { Text("Snap me") },
    expanded: { Text("Anchors left/right") },
    icon: { Image(systemName: "arrow.left.and.right") },
    constants: snapConstants
)
```

- **Sizing**: increase expanded max width/height.
```swift
let sizingConstants = FloatingHUDConstants(expandedWidthMax: 480, expandedHeight: 300)
FloatingHUDOverlay(
    containerSize: proxy.size,
    compact: { Text("Compact fits content") },
    expanded: { Text("Expanded clamps to 480pt max") },
    icon: { Image(systemName: "rectangle.3.offgrid") },
    constants: sizingConstants
)
```

- **Animations**: soften the springs.
```swift
let animationConstants = FloatingHUDConstants(
    expansionAnimation: .interactiveSpring(response: 0.35, dampingFraction: 0.8),
    attachmentAnimation: .interactiveSpring(response: 0.25, dampingFraction: 0.7)
)
FloatingHUDOverlay(
    containerSize: proxy.size,
    compact: { Text("Animated") },
    expanded: { Text("Custom springs") },
    icon: { Image(systemName: "sparkles") },
    constants: animationConstants
)
```

- **Container**: always feed current geometry size for correct snapping/clamping.
```swift
GeometryReader { proxy in
    FloatingHUDOverlay(
        containerSize: proxy.size,
        compact: { Text("Uses proxy.size") },
        expanded: { Text("Snaps within this container") },
        icon: { Image(systemName: "ruler") }
    )
}
```

- **Content**: use any SwiftUI views; keep elements consistent for smooth matched-geometry transitions.
```swift
FloatingHUDOverlay(
    containerSize: proxy.size,
    compact: { Label("72%", systemImage: "gauge") },
    expanded: { VStack { Text("72% load"); Text("Smooth transition") } },
    icon: { Image(systemName: "gauge") }
)
```

- **Card style**: swap material for a solid blur, tint, or stroke.
```swift
let style = FloatingHUDCardStyle(
    compact: .init(
        background: { shape in
            AnyView(
                shape
                    .fill(Color.orange.opacity(0.15))
                    .overlay(shape.stroke(Color.orange.opacity(0.4), lineWidth: 1))
            )
        },
        shadow: .init(color: Color.orange.opacity(0.35), radius: 12, y: 6)
    ),
    expanded: .init(
        background: { shape in
            AnyView(
                shape
                    .fill(.thinMaterial)
                    .overlay(shape.stroke(Color.orange.opacity(0.5), lineWidth: 1.5))
            )
        },
        shadow: .init(color: Color.orange.opacity(0.35), radius: 18, y: 10)
    )
)

FloatingHUDOverlay(
    containerSize: proxy.size,
    compact: { Text("Custom card") },
    expanded: { Text("Styled background + shadow") },
    icon: { Image(systemName: "paintpalette.fill") },
    constants: FloatingHUDConstants(cardStyle: style)
)
```

- **Expanded label override**: match-animate a differently styled label in the expanded header.
```swift
FloatingHUDOverlay(
    containerSize: proxy.size,
    compact: {
        Text("72%")
            .font(.system(size: 18, weight: .semibold, design: .rounded))
    },
    expanded: {
        VStack(alignment: .leading, spacing: 6) {
            Text("72.3% load")
            Text("Current memory usage")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    },
    expandedLabel: {
        VStack(alignment: .leading, spacing: 4) {
            Text("72.3% load").font(.system(size: 26, weight: .semibold, design: .rounded))
            Text("Current memory usage").font(.footnote.weight(.semibold)).foregroundStyle(.secondary)
        }
    },
    icon: { Image(systemName: "gauge") }
)
```

## Customization Tables

**Layout**

| Setting                 | Default                 | How to change                               |
|-------------------------|-------------------------|---------------------------------------------|
| Compact padding         | 8h / 10v                | Pass custom `FloatingHUDConstants`          |
| Icon size / padding     | 20pt / 1pt              | Pass custom `FloatingHUDConstants`          |
| Snap margin             | 8pt                     | `FloatingHUDConstants.horizontalMargin`     |
| Vertical margin         | 10pt (default inset)    | `FloatingHUDConstants.verticalMargin`       |
| Expanded height         | 260pt                   | `FloatingHUDConstants.expandedHeight`       |
| Expanded max width      | 360pt                   | `FloatingHUDConstants.expandedWidthMax`     |
| Card style              | Material + light stroke + soft shadow | Set `FloatingHUDConstants.cardStyle` |

**Animations**

| Setting                 | Default spring                                 | How to change                                     |
|-------------------------|-------------------------------------------------|---------------------------------------------------|
| Expand / collapse       | interactiveSpring(response: 0.27, damping: 0.7) | Set `expansionAnimation` in `FloatingHUDConstants` |
| Drag snap               | interactiveSpring(response: 0.3, damping: 0.74)| Set `attachmentAnimation` in `FloatingHUDConstants`|
| Dramatic collapse       | spring(response: 0.48, damping: 0.6)            | Set `dramaticCollapseSpring` in `FloatingHUDConstants` |

**Interaction**

| Setting             | Default                        | How to change                       |
|---------------------|--------------------------------|-------------------------------------|
| Drag min distance   | 8pt                            | Edit drag gesture in overlay        |
| Anchor logic        | Drop-based left/right choice   | Edit anchor decision in overlay     |

**Styling**

| Setting             | Default                                      | How to change                                                |
|---------------------|----------------------------------------------|--------------------------------------------------------------|
| Background/shadow   | Material blur + light stroke + soft shadow   | Wrap overlay with your own modifiers, or replace the background/shadow in `FlexibleHUDView`. |

## Notes
- Pure SwiftUI; no external dependencies.
- Icon + compact label are now matched-geometry animated into the expanded header; keep those elements consistent across states for the smoothest transitions.

## License
MIT
