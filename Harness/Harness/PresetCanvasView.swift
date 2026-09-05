import Mobster
import SwiftUI

struct PresetCanvasView: View {
    let frame: Frame
    /// Nil where the field is hidden and where it holds no path location, which are drawn the same way: not at all.
    let raster: FieldRaster?
    let paths: [[SIMD2<Float>]]
    let strokes: [Stroke]

    private static let margin: CGFloat = 24
    private static let guideWidth: CGFloat = 1.5
    private static let frameWidth: CGFloat = 1
    private static let pointRadius: CGFloat = 2.5
    private static let strokeWidth: CGFloat = 1
    private static let strokeOpacity: CGFloat = 0.45
    /// Amber against the cyan of the guides, which separates the points a Guide moves from the paths it moves them toward.
    private static let fixtureColor = Color(red: 1, green: 0.62, blue: 0.04)
    /// The field stays achromatic and dim, so hue belongs to the cyan and the amber alone and neither loses its contrast over a lit texel.
    private static let fieldOpacity: Double = 0.45

    var body: some View {
        Canvas { context, size in
            let scale = scale(for: size)
            let origin = origin(for: size, scale: scale)
            if let image = fieldImage() {
                var fog = context
                fog.opacity = Self.fieldOpacity
                fog.draw(Image(decorative: image, scale: 1).interpolation(.none), in: frameRect(scale: scale, origin: origin))
            }
            context.stroke(framePath(scale: scale, origin: origin), with: .color(.secondary), lineWidth: Self.frameWidth)
            for path in paths {
                context.stroke(guidePath(path, scale: scale, origin: origin), with: .color(.cyan), lineWidth: Self.guideWidth)
            }
            for stroke in strokes {
                let run = guidePath(stroke.samples.map(\.location), scale: scale, origin: origin)
                context.stroke(run, with: .color(Self.fixtureColor.opacity(Self.strokeOpacity)), lineWidth: Self.strokeWidth)
                context.fill(dots(stroke, scale: scale, origin: origin), with: .color(Self.fixtureColor))
            }
        }
        .background(Color.black)
        .frame(minWidth: 480, minHeight: 360)
    }

    private func scale(for size: CGSize) -> CGFloat {
        let width = CGFloat(frame.size.x)
        let height = CGFloat(frame.size.y)
        guard width > 0, height > 0 else { return 1 }
        return min((size.width - Self.margin * 2) / width, (size.height - Self.margin * 2) / height)
    }

    /// Where the Frame's own origin lands once the Frame is centred in the canvas.
    private func origin(for size: CGSize, scale: CGFloat) -> CGPoint {
        CGPoint(x: (size.width - CGFloat(frame.size.x) * scale) / 2 - CGFloat(frame.origin.x) * scale,
                y: (size.height - CGFloat(frame.size.y) * scale) / 2 - CGFloat(frame.origin.y) * scale)
    }

    private func location(_ scene: SIMD2<Float>, scale: CGFloat, origin: CGPoint) -> CGPoint {
        CGPoint(x: origin.x + CGFloat(scene.x) * scale, y: origin.y + CGFloat(scene.y) * scale)
    }

    private func frameRect(scale: CGFloat, origin: CGPoint) -> CGRect {
        let corner = location(frame.origin, scale: scale, origin: origin)
        return CGRect(x: corner.x, y: corner.y, width: CGFloat(frame.size.x) * scale, height: CGFloat(frame.size.y) * scale)
    }

    private func framePath(scale: CGFloat, origin: CGPoint) -> Path {
        Path(frameRect(scale: scale, origin: origin))
    }

    /// The texel counts round, so the raster is stretched across the Frame rather than laid down a texel at a time.
    private func fieldImage() -> CGImage? {
        guard let raster, raster.columns > 0, raster.rows > 0, raster.samples.count == raster.columns * raster.rows else { return nil }
        guard let provider = CGDataProvider(data: Data(raster.samples) as CFData) else { return nil }

        return CGImage(width: raster.columns,
                       height: raster.rows,
                       bitsPerComponent: 8,
                       bitsPerPixel: 8,
                       bytesPerRow: raster.columns,
                       space: CGColorSpaceCreateDeviceGray(),
                       bitmapInfo: CGBitmapInfo(rawValue: 0),
                       provider: provider,
                       decode: nil,
                       shouldInterpolate: false,
                       intent: .defaultIntent)
    }

    private func dots(_ stroke: Stroke, scale: CGFloat, origin: CGPoint) -> Path {
        var path = Path()
        for sample in stroke.samples {
            let center = location(sample.location, scale: scale, origin: origin)
            path.addEllipse(in: CGRect(x: center.x - Self.pointRadius, y: center.y - Self.pointRadius, width: Self.pointRadius * 2, height: Self.pointRadius * 2))
        }
        return path
    }

    private func guidePath(_ scene: [SIMD2<Float>], scale: CGFloat, origin: CGPoint) -> Path {
        var path = Path()
        guard let first = scene.first else { return path }
        path.move(to: location(first, scale: scale, origin: origin))
        for point in scene.dropFirst() {
            path.addLine(to: location(point, scale: scale, origin: origin))
        }
        return path
    }
}
