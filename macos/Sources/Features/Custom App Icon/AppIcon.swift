import AppKit
import System

/// The icon style for the Ghostty App.
enum AppIcon: Equatable, Codable {
    case official
    case blueprint
    case chalkboard
    case glass
    case holographic
    case microchip
    case paper
    case retro
    case xray
    /// Save full image data to avoid sandboxing issues
    case custom(fileData: Data)
    case customStyle(ghostColorHex: String, screenColorHexes: [String], iconFrame: Ghostty.MacOSIconFrame)
    
#if !DOCK_TILE_PLUGIN
    init?(config: Ghostty.Config) {
        switch config.macosIcon {
        case .official:
            return nil
        case .blueprint:
            self = .blueprint
        case .chalkboard:
            self = .chalkboard
        case .glass:
            self = .glass
        case .holographic:
            self = .holographic
        case .microchip:
            self = .microchip
        case .paper:
            self = .paper
        case .retro:
            self = .retro
        case .xray:
            self = .xray
        case .custom:
            if let data = try? Data(contentsOf: URL(filePath: config.macosCustomIcon, relativeTo: nil)) {
                self = .custom(fileData: data)
            } else {
                return nil
            }
        case .customStyle:
            // Discard saved icon name
            // if no valid colours were found
            guard
                let ghostColor = config.macosIconGhostColor?.hexString,
                let screenColors = config.macosIconScreenColor?.compactMap(\.hexString)
            else {
                return nil
            }
            self = .customStyle(ghostColorHex: ghostColor, screenColorHexes: screenColors, iconFrame: config.macosIconFrame)
        }
    }
#endif
    
    /// Restore the icon from previously saved values
    init?(string: String) {
        switch string {
        case Ghostty.MacOSIcon.official.rawValue:
            self = .official
        case Ghostty.MacOSIcon.blueprint.rawValue:
            self = .blueprint
        case Ghostty.MacOSIcon.chalkboard.rawValue:
            self = .chalkboard
        case Ghostty.MacOSIcon.glass.rawValue:
            self = .glass
        case Ghostty.MacOSIcon.holographic.rawValue:
            self = .holographic
        case Ghostty.MacOSIcon.microchip.rawValue:
            self = .microchip
        case Ghostty.MacOSIcon.paper.rawValue:
            self = .paper
        case Ghostty.MacOSIcon.retro.rawValue:
            self = .retro
        case Ghostty.MacOSIcon.xray.rawValue:
            self = .xray
        default:
            var parts = string.split(separator: "_").map(String.init)
            if
                let _ = parts.first.flatMap(NSColor.init(hex:)),
                let frame = parts.last.flatMap(Ghostty.MacOSIconFrame.init(rawValue:))
            {
                let ghostC = parts.removeFirst()
                _ = parts.removeLast()
                self = .customStyle(
                    ghostColorHex: ghostC,
                    screenColorHexes: parts,
                    iconFrame: frame
                )
            } else {
                // Due to sandboxing with `com.apple.dock.external.extra.arm64`,
                // we can’t restore custom icon file automatically.
                // The user must open the app to update it.
                return nil
            }
        }
    }
    
    func image(in bundle: Bundle) -> NSImage? {
        switch self {
        case .official:
            return nil
        case .blueprint:
            return bundle.image(forResource: "BlueprintImage")!
        case .chalkboard:
            return bundle.image(forResource: "ChalkboardImage")!
        case .glass:
            return bundle.image(forResource: "GlassImage")!
        case .holographic:
            return bundle.image(forResource: "HolographicImage")!
        case .microchip:
            return bundle.image(forResource: "MicrochipImage")!
        case .paper:
            return bundle.image(forResource: "PaperImage")!
        case .retro:
            return bundle.image(forResource: "RetroImage")!
        case .xray:
            return bundle.image(forResource: "XrayImage")!
        case let .custom(file):
            if let userIcon = NSImage(data: file) {
                return userIcon
            } else {
                return nil
            }
        case let .customStyle(ghostColorHex, screenColorHexes, macosIconFrame):
            let screenColors = screenColorHexes.compactMap(NSColor.init(hex:))
            guard
                let ghostColor = NSColor(hex: ghostColorHex),
                let icon = ColorizedGhosttyIcon(
                    screenColors: screenColors,
                    ghostColor: ghostColor,
                    frame: macosIconFrame
                ).makeImage(in: bundle)
            else {
                return nil
            }
            return icon
        }
    }
}
