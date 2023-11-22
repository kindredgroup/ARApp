import Foundation

struct Comments: Codable, Identifiable {
    let id = UUID()
    let name: String
    let email: String
    let body: String
}
