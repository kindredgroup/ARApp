import Foundation

struct Objects: Codable, Identifiable {
    var id: UUID
    let name: String
    let x: Float
    let y: Float
    let z: Float
}
