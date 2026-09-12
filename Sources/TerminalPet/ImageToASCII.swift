import AppKit
import Foundation

enum ASCIICharacterSet: String, CaseIterable, Identifiable {
    case classic = "Classic"
    case soft = "Soft"
    case blocks = "Blocks"
    case binary = "Binary"

    var id: String { rawValue }

    var characters: [Character] {
        switch self {
        case .classic: return Array(" .:-=+*#%@")
        case .soft: return Array("  .oO@")
        case .blocks: return Array("  ░▒▓█")
        case .binary: return Array(" 01")
        }
    }
}

struct ASCIIConversionSettings {
    var width: Int = 42
    var contrast: Double = 1.2
    var inverted: Bool = false
    var removeFlatBackground: Bool = true
    var characterSet: ASCIICharacterSet = .classic
}

enum ImageToASCII {
    static func convert(image: NSImage, settings: ASCIIConversionSettings) -> String {
        let sourceSize = image.size
        guard sourceSize.width > 0, sourceSize.height > 0 else {
            return "[ image could not be read ]"
        }

        let width = max(16, min(settings.width, 88))
        let aspectRatio = sourceSize.height / sourceSize.width
        // Terminal glyphs are roughly twice as tall as they are wide.
        let height = max(4, min(80, Int((CGFloat(width) * aspectRatio * 0.48).rounded())))

        guard let bitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: width,
            pixelsHigh: height,
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        ) else {
            return "[ image conversion failed ]"
        }

        NSGraphicsContext.saveGraphicsState()
        if let context = NSGraphicsContext(bitmapImageRep: bitmap) {
            NSGraphicsContext.current = context
            context.imageInterpolation = .high
            NSColor.clear.setFill()
            NSRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)).fill()
            image.draw(
                in: NSRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)),
                from: NSRect(origin: .zero, size: sourceSize),
                operation: .copy,
                fraction: 1.0
            )
            context.flushGraphics()
        }
        NSGraphicsContext.restoreGraphicsState()

        let ramp = settings.characterSet.characters
        let background = settings.removeFlatBackground
            ? backgroundReference(in: bitmap, width: width, height: height)
            : nil
        var lines: [String] = []

        for y in stride(from: height - 1, through: 0, by: -1) {
            var line = ""
            for x in 0..<width {
                guard let rawColor = bitmap.colorAt(x: x, y: y),
                      let color = rawColor.usingColorSpace(.deviceRGB) else {
                    line.append(" ")
                    continue
                }

                if color.alphaComponent < 0.08 {
                    line.append(" ")
                    continue
                }

                if let background {
                    let redDelta = color.redComponent - background.red
                    let greenDelta = color.greenComponent - background.green
                    let blueDelta = color.blueComponent - background.blue
                    let distanceSquared = redDelta * redDelta + greenDelta * greenDelta + blueDelta * blueDelta
                    if distanceSquared < 0.028 {
                        line.append(" ")
                        continue
                    }
                }

                var luminance = 0.2126 * color.redComponent
                    + 0.7152 * color.greenComponent
                    + 0.0722 * color.blueComponent

                if settings.inverted {
                    luminance = 1.0 - luminance
                }

                luminance = ((luminance - 0.5) * CGFloat(settings.contrast)) + 0.5
                luminance = min(1.0, max(0.0, luminance))
                let index = Int((luminance * CGFloat(ramp.count - 1)).rounded())
                line.append(ramp[index])
            }
            lines.append(line.trimmingTrailingWhitespace())
        }

        while lines.first?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            lines.removeFirst()
        }
        while lines.last?.trimmingCharacters(in: .whitespaces).isEmpty == true {
            lines.removeLast()
        }

        return lines.isEmpty ? "[ your pet has become one with the void ]" : lines.joined(separator: "\n")
    }

    private static func backgroundReference(
        in bitmap: NSBitmapImageRep,
        width: Int,
        height: Int
    ) -> (red: CGFloat, green: CGFloat, blue: CGFloat)? {
        let points = [
            (1, 1),
            (max(1, width - 2), 1),
            (1, max(1, height - 2)),
            (max(1, width - 2), max(1, height - 2))
        ]
        var colors: [NSColor] = []
        for point in points {
            let (x, y) = point
            if let rawColor = bitmap.colorAt(x: min(x, width - 1), y: min(y, height - 1)),
               let color = rawColor.usingColorSpace(NSColorSpace.deviceRGB),
               color.alphaComponent > 0.08 {
                colors.append(color)
            }
        }

        guard colors.count >= 3 else { return nil }
        let count = CGFloat(colors.count)
        var redTotal = CGFloat.zero
        var greenTotal = CGFloat.zero
        var blueTotal = CGFloat.zero
        for color in colors {
            redTotal += color.redComponent
            greenTotal += color.greenComponent
            blueTotal += color.blueComponent
        }
        let reference: (red: CGFloat, green: CGFloat, blue: CGFloat) = (
            red: redTotal / count,
            green: greenTotal / count,
            blue: blueTotal / count
        )

        let cornersAreSimilar = colors.allSatisfy { color in
            let redDelta = color.redComponent - reference.red
            let greenDelta = color.greenComponent - reference.green
            let blueDelta = color.blueComponent - reference.blue
            return redDelta * redDelta + greenDelta * greenDelta + blueDelta * blueDelta < 0.045
        }
        return cornersAreSimilar ? reference : nil
    }
}

private extension String {
    func trimmingTrailingWhitespace() -> String {
        guard let last = lastIndex(where: { !$0.isWhitespace }) else { return "" }
        return String(self[...last])
    }
}
