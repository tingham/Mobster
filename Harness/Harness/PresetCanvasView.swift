import Mobster
import SwiftUI

struct PresetCanvasView: View {
    let frame: Frame
    /// Nil where the field is hidden and where it holds no path location, which are drawn the same way: not at all.
    let raster: FieldRaster?
    /// Nil where the identities are hidden and where the preset extracts nothing.
    let identities: MeshIdentityRaster?
    let paths: [[SIMD2<Float>]]
    /// The anchors, held undisplaced by the consumer's stand in.
    let lines: [Line]
    /// What the Guide returned for the time on screen, in the order the anchors were supplied.
    let displaced: [Line]

    private static let margin: CGFloat = 24
    private static let guideWidth: CGFloat = 1.5
    private static let frameWidth: CGFloat = 1
    private static let pointRadius: CGFloat = 2.5
    private static let strokeWidth: CGFloat = 1
    private static let strokeOpacity: CGFloat = 0.45
    /// Amber against the cyan of the guides, which separates the verts a Guide moves from the paths it moves them toward.
    private static let fixtureColor = Color(red: 1, green: 0.62, blue: 0.04)
    /// The field stays achromatic and dim, so hue belongs to the cyan and the amber alone and neither loses its contrast over a lit texel.
    private static let fieldOpacity: Double = 0.45
    /// The identity raster is the one thing here that is hued, and it is dim enough that the cyan of the paths still reads over it.
    private static let identityOpacity: Double = 0.4
    /// Where a vert started reads as a dim amber ring and where it stands now as a solid amber disc, so the run is legible without a second hue.
    private static let originOpacity: CGFloat = 0.3
    private static let originWidth: CGFloat = 1

    var body: some View {
        Canvas { context, size in
            let scale = scale(for: size)
            let origin = origin(for: size, scale: scale)
            if let image = fieldImage() {
                var fog = context
                fog.opacity = Self.fieldOpacity
                fog.draw(Image(decorative: image, scale: 1).interpolation(.none), in: frameRect(scale: scale, origin: origin))
            }
            if let image = identityImage() {
                var lit = context
                lit.opacity = Self.identityOpacity
                lit.draw(Image(decorative: image, scale: 1).interpolation(.none), in: frameRect(scale: scale, origin: origin))
            }
            context.stroke(framePath(scale: scale, origin: origin), with: .color(.secondary), lineWidth: Self.frameWidth)
            for path in paths {
                context.stroke(guidePath(path, scale: scale, origin: origin), with: .color(.cyan), lineWidth: Self.guideWidth)
            }
            for line in lines {
                let seeded = line.verts.map(\.location)
                context.stroke(guidePath(seeded, scale: scale, origin: origin), with: .color(Self.fixtureColor.opacity(Self.originOpacity)), lineWidth: Self.strokeWidth)
                context.stroke(dots(seeded, scale: scale, origin: origin), with: .color(Self.fixtureColor.opacity(Self.originOpacity)), lineWidth: Self.originWidth)
            }
            for line in displaced {
                let carried = line.verts.map(\.location)
                context.stroke(guidePath(carried, scale: scale, origin: origin), with: .color(Self.fixtureColor.opacity(Self.strokeOpacity)), lineWidth: Self.strokeWidth)
                context.fill(dots(carried, scale: scale, origin: origin), with: .color(Self.fixtureColor))
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

    /// One colour an identity, laid down a fragment at a time. A fragment covering no component is left clear, so the background of the canvas still reads as the background.
    private func identityImage() -> CGImage? {
        guard let identities, identities.columns > 0, identities.rows > 0, identities.identities.count == identities.columns * identities.rows else { return nil }

        var pixels = [UInt8]()
        pixels.reserveCapacity(identities.identities.count * 4)
        for identity in identities.identities {
            guard identity != MeshIdentityRaster.background else {
                pixels.append(contentsOf: [0, 0, 0, 0])
                continue
            }
            let colour = Self.colour(identity)
            pixels.append(contentsOf: [colour.x, colour.y, colour.z, .max])
        }

        guard let provider = CGDataProvider(data: Data(pixels) as CFData) else { return nil }

        return CGImage(width: identities.columns,
                       height: identities.rows,
                       bitsPerComponent: 8,
                       bitsPerPixel: 32,
                       bytesPerRow: identities.columns * 4,
                       space: CGColorSpaceCreateDeviceRGB(),
                       bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
                       provider: provider,
                       decode: nil,
                       shouldInterpolate: false,
                       intent: .defaultIntent)
    }

    /// Hues spaced by the golden angle, so that identities emitted one after another never land on the same colour and a boundary between two of them reads.
    private static func colour(_ identity: UInt32) -> SIMD3<UInt8> {
        let turn = Float(identity) * 0.6180339

        return SIMD3<UInt8>(channel(turn), channel(turn + 1.0 / 3), channel(turn + 2.0 / 3))
    }

    /// A triangle wave of the turn, which three channels a third of a turn apart carry around a colour wheel.
    private static func channel(_ turn: Float) -> UInt8 {
        let fraction = turn - turn.rounded(.down)

        return UInt8(min(255, max(0, (abs(fraction * 2 - 1) * 255).rounded())))
    }

    private func dots(_ scene: [SIMD2<Float>], scale: CGFloat, origin: CGPoint) -> Path {
        var path = Path()
        for point in scene {
            let center = location(point, scale: scale, origin: origin)
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
