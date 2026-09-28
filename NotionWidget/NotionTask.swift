import Foundation

struct NotionTask: Identifiable {
    let id: String
    var name: String
    var subject: String?
    var dueDate: Date?
    var priority: String?
    var isCompleted: Bool
}
