import Cocoa

struct ColorizedGhosttyIcon: Codable, Equatable {
    init(screenColors: [NSColor], ghostColor: NSColor, frame: Ghostty.MacOSIconFrame) {
        self.screenColors = screenColors
        self.ghostColor = ghostColor
        self.frame = frame
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let screenColorHexes = try container.decode([String].self, forKey: .screenColors)
        let screenColors = screenColorHexes.compactMap(NSColor.init(hex:))
        let ghostColorHex = try container.decode(String.self, forKey: .ghostColor)
        guard let ghostColor = NSColor(hex: ghostColorHex) else {
            throw NSError(domain: "Custom Icon Error", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Failed to decode ghost color from \(ghostColorHex)"
            ])
        }
        let frame = try container.decode(Ghostty.MacOSIconFrame.self, forKey: .frame)
        self.init(screenColors: screenColors, ghostColor: ghostColor, frame: frame)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(screenColors.compactMap(\.hexString), forKey: .screenColors)
        try container.encode(ghostColor.hexString, forKey: .ghostColor)
        try container.encode(frame, forKey: .frame)
    }

    /// The colors that make up the gradient of the screen.
    let screenColors: [NSColor]

    /// The color of the ghost.
    let ghostColor: NSColor

    /// The frame type to use
    let frame: Ghostty.MacOSIconFrame

    private enum CodingKeys: String, CodingKey {
        case screenColors
        case ghostColor
        case frame
    }

    /// Make a custom colorized ghostty icon.
    func makeImage(in bundle: Bundle) -> NSImage? {
        // All of our layers (not in order)
        guard let screen = bundle.image(forResource: "CustomIconScreen") else { return nil }
        guard let screenMask = bundle.image(forResource: "CustomIconScreenMask") else { return nil }
        guard let ghost = bundle.image(forResource: "CustomIconGhost") else { return nil }
        guard let crt = bundle.image(forResource: "CustomIconCRT") else { return nil }
        guard let gloss = bundle.image(forResource: "CustomIconGloss") else { return nil }

        let baseName = switch frame {
        case .aluminum: "CustomIconBaseAluminum"
        case .beige: "CustomIconBaseBeige"
        case .chrome: "CustomIconBaseChrome"
        case .plastic: "CustomIconBasePlastic"
        }
        guard let base = bundle.image(forResource: baseName) else { return nil }

        // Apply our color in various ways to our layers.
        // NOTE: These functions are not built-in, they're implemented as an extension
        // to NSImage in NSImage+Extension.swift.
        guard let screenGradient = screenMask.gradient(colors: screenColors) else { return nil }
        guard let tintedGhost = ghost.tint(color: ghostColor) else { return nil }

        // Combine our layers using the proper blending modes
        return.combine(images: [
            base,
            screen,
            screenGradient,
            ghost,
            tintedGhost,
            crt,
            gloss,
        ], blendingModes: [
            .normal,
            .normal,
            .color,
            .normal,
            .color,
            .overlay,
            .normal,
        ])
    }
}
