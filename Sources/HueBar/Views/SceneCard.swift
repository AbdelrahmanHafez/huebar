import AppKit
import SwiftUI

struct SceneCard: View {
    let scene: HueScene
    let isActive: Bool
    var isDynamic: Bool = false
    let onTap: () -> Void
    var onPlayPause: (() -> Void)?

    var body: some View {
        let artwork = scene.artwork.imageName.flatMap(SceneArtworkImageLoader.image(named:))
        let foreground: Color = artwork == nil ? ColorCardStyle.foreground(for: scene.paletteColors) : .white

        ZStack {
            cardContent(artwork: artwork, foreground: foreground)
            if isActive && scene.supportsDynamic {
                playPauseButton(foreground: foreground)
                    .offset(y: -8)
            }
        }
    }

    private func cardContent(artwork: NSImage?, foreground: Color) -> some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                Spacer()
                Text(scene.name)
                    .font(.system(size: 10, weight: .medium))
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(foreground)
                    .shadow(color: foreground == .white ? .black.opacity(0.5) : .clear, radius: 2, y: 1)
            }
            .frame(maxWidth: .infinity, minHeight: 64)
            .padding(6)
            .background {
                if let artwork {
                    artworkBackground(artwork)
                }
            }
            .modifier(ColorCardStyle(colors: scene.paletteColors, cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(isActive ? Color.white : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(scene.name) scene\(isActive ? ", active" : "")")
    }

    private func playPauseButton(foreground: Color) -> some View {
        Button {
            onPlayPause?()
        } label: {
            Image(systemName: isDynamic ? "pause.fill" : "play.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(foreground)
                .frame(width: 34, height: 34)
                .background(isLiquidGlassAvailable ? .clear : .black.opacity(0.35), in: Circle())
        }
        .accessibilityLabel(isDynamic ? "Pause dynamic scene" : "Play dynamic scene")
        .hueGlassButtonStyle(fallback: .plain)
        .buttonBorderShape(.circle)
    }

    private func artworkBackground(_ artwork: NSImage) -> some View {
        GeometryReader { proxy in
            Image(nsImage: artwork)
                .resizable()
                .scaledToFill()
                .frame(width: proxy.size.width, height: proxy.size.height)
                .overlay {
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.6)],
                        startPoint: .top, endPoint: .bottom
                    )
                }
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .accessibilityHidden(true)
    }
}

@MainActor
private enum SceneArtworkImageLoader {
    static func image(named name: String) -> NSImage? {
        if let url = SceneArtworkCatalog.url(forImageNamed: name) {
            return NSImage(contentsOf: url)
        }
        return nil
    }
}
