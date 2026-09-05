import Foundation

/// Preset geometry held as a bundled JSON resource, plotted in a design rectangle running from zero to size.
struct PresetResource: Decodable {
    let size: SIMD2<Float>
    let paths: [[SIMD2<Float>]]

    /// The resource ships in the package bundle, so its absence or corruption is a build defect and not a runtime condition to recover from.
    static func load(_ name: String) -> PresetResource {
        guard let url = Bundle.module.url(forResource: name, withExtension: "json") else {
            fatalError("Preset resource \(name).json is missing from the Mobster bundle")
        }

        do {
            return try JSONDecoder().decode(PresetResource.self, from: Data(contentsOf: url))
        } catch {
            fatalError("Preset resource \(name).json could not be read: \(error)")
        }
    }
}
