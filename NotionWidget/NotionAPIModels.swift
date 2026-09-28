import Foundation

struct NotionQueryResponse: Codable {
    let results: [NotionPage]
}

struct NotionPage: Codable {
    let id: String
    let properties: NotionProperties
}

struct NotionProperties: Codable {
    let name: NotionTitleProperty
    let subject: NotionSelectProperty
    let dueDate: NotionDateProperty
    let priority: NotionSelectProperty
    let checked: NotionCheckboxProperty

    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case subject = "Subject"
        case dueDate = "Due date"
        case priority = "Priority"
        case checked = "Checked"
    }
}

// ------------------------------------

struct NotionTitleProperty: Codable {
    let title: [NotionRichText]
}

struct NotionSelectProperty: Codable {
    let select: NotionSelectOption?
}

struct NotionDateProperty: Codable {
    let date: NotionDateValue?
}

struct NotionCheckboxProperty: Codable {
    let checkbox: Bool
}

// ------------------------------------

struct NotionRichText: Codable {
    let plainText: String

    enum CodingKeys: String, CodingKey {
        case plainText = "plain_text"
    }
}

struct NotionSelectOption: Codable {
    let name: String
}

struct NotionDateValue: Codable {
    let start: String
}

// ------------------------------------

struct NotionDataSource: Codable {
    let properties: [String: NotionSchemaProperty]
}

struct NotionSchemaProperty: Codable {
    let select: NotionSelectSchema?
}

struct NotionSelectSchema: Codable {
    let options: [NotionSelectOption]
}
