import Foundation

final class NotionService {
    static let shared = NotionService()
    
    private let databaseID = "e124006d3ad283db8fb6819f09e45faa"
    private let dataSourceID = "6df4006d-3ad2-8211-805f-0735115169ac"

    private init() {}

    func testConnection(token: String) async {
        guard let url = URL(string: "https://api.notion.com/v1/users/me") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)

        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("2026-03-11", forHTTPHeaderField: "Notion-Version")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                print("Notion status code:", httpResponse.statusCode)
            }

            if let responseBody = String(data: data, encoding: .utf8) {
                print("Notion response:", responseBody)
            }
        } catch {
            print("Notion request failed:", error)
        }
    }
    
    func fetchTasks(token: String) async -> [NotionTask] {
        guard let url = URL(string: "https://api.notion.com/v1/data_sources/\(dataSourceID)/query") else {
            print("Invalid data source URL")
            return []
        }

        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("2026-03-11", forHTTPHeaderField: "Notion-Version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                print("Database status code:", httpResponse.statusCode)
            }

            do {
                let decodedResponse = try JSONDecoder().decode(
                    NotionQueryResponse.self,
                    from: data
                )

                let tasks = decodedResponse.results.map { page in
                    NotionTask(
                        id: page.id,
                        name: page.properties.name.title.first?.plainText ?? "",
                        subject: page.properties.subject.select?.name,
                        dueDate: parseNotionDate(page.properties.dueDate.date?.start),
                        priority: page.properties.priority.select?.name,
                        isCompleted: page.properties.checked.checkbox
                    )
                }

                return tasks

            } catch {
                print("Failed to decode Notion response:", error)
            }
            
        } catch {
            print("Database request failed:", error)
        }
        
        return []
    }
    
    private func parseNotionDate(_ dateString: String?) -> Date? {
        guard let dateString else {
            return nil
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        return formatter.date(from: dateString)
    }
    
    func fetchSelectOptions(token: String) async -> (subjects: [String], priorities: [String]) {
        guard let url = URL(string: "https://api.notion.com/v1/data_sources/\(dataSourceID)") else {
            return ([], [])
        }

        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("2026-03-11", forHTTPHeaderField: "Notion-Version")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Failed to fetch select options")
                return ([], [])
            }

            let dataSource = try JSONDecoder().decode(
                NotionDataSource.self,
                from: data
            )

            let subjects = dataSource.properties["Subject"]?
                .select?
                .options
                .map { $0.name } ?? []

            let priorities = dataSource.properties["Priority"]?
                .select?
                .options
                .map { $0.name } ?? []

            return (subjects, priorities)
        } catch {
            print("Failed to decode select options:", error)
            return ([], [])
        }
    }
    
    func updateTaskCompletion(pageID: String, isCompleted: Bool, token: String) async -> Bool {
        guard let url = URL(string: "https://api.notion.com/v1/pages/\(pageID)") else {
            return false
        }

        var request = URLRequest(url: url)
        
        request.httpMethod = "PATCH"

        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("2026-03-11", forHTTPHeaderField: "Notion-Version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "properties": [
                "Checked": [
                    "checkbox": isCompleted
                ]
            ]
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)

            let (_, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                return false
            }

            print("Update status code:", httpResponse.statusCode)

            return (200...299).contains(httpResponse.statusCode)
        } catch {
            print("Failed to update task:", error)
            return false
        }
    }
    
    func updateTaskName(pageID: String, name: String,token: String) async -> Bool {
        guard let url = URL(string: "https://api.notion.com/v1/pages/\(pageID)") else {
            return false
        }

        var request = URLRequest(url: url)
        
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("2026-03-11", forHTTPHeaderField: "Notion-Version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let titleContent: [String: Any] = ["text": ["content": name] ]
        let nameProperty: [String: Any] = ["title": [titleContent] ]
        let body: [String: Any] = ["properties": ["Name": nameProperty] ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)

            let (_, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                return false
            }

            print("Name update status code:", httpResponse.statusCode)

            return (200...299).contains(httpResponse.statusCode)
        } catch {
            print("Failed to update task name:", error)
            return false
        }
    }
    
    // To-do: refactor subject and priority!
    
    func updateTaskSubject(pageID: String, subject: String?, token: String) async -> Bool {
        guard let url = URL(string: "https://api.notion.com/v1/pages/\(pageID)") else {
            return false
        }

        var request = URLRequest(url: url)
        
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(token)",forHTTPHeaderField: "Authorization")
        request.setValue("2026-03-11", forHTTPHeaderField: "Notion-Version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let selectValue: Any

        if let subject {
            selectValue = ["name": subject]
        } else {
            selectValue = NSNull()
        }

        let subjectProperty: [String: Any] = ["select": selectValue]

        let body: [String: Any] = [
            "properties": [
                "Subject": subjectProperty
            ]
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)

            let (_, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                return false
            }

            print("Subject update status code:", httpResponse.statusCode)

            return (200...299).contains(httpResponse.statusCode)
        } catch {
            print("Failed to update task subject:", error)
            return false
        }
    }
    
    func updateTaskPriority(pageID: String, priority: String?, token: String) async -> Bool {
        guard let url = URL(string: "https://api.notion.com/v1/pages/\(pageID)") else {
            return false
        }

        var request = URLRequest(url: url)
        
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(token)",forHTTPHeaderField: "Authorization")
        request.setValue("2026-03-11", forHTTPHeaderField: "Notion-Version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let selectValue: Any

        if let priority {
            selectValue = ["name": priority]
        } else {
            selectValue = NSNull()
        }

        let priorityProperty: [String: Any] = ["select": selectValue]

        let body: [String: Any] = [
            "properties": [
                "Priority": priorityProperty
            ]
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)

            let (_, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                return false
            }

            print("Priority update status code:", httpResponse.statusCode)

            return (200...299).contains(httpResponse.statusCode)
        } catch {
            print("Failed to update task priority:", error)
            return false
        }
    }
    
    func updateTaskDueDate(pageID: String, dueDate: Date?, token: String) async -> Bool {
        guard let url = URL(string: "https://api.notion.com/v1/pages/\(pageID)") else {
            return false
        }

        var request = URLRequest(url: url)
        
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("2026-03-11", forHTTPHeaderField: "Notion-Version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let dateValue: Any

        if let dueDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            
            dateValue = ["start": formatter.string(from: dueDate)]
        } else {
            dateValue = NSNull()
        }

        let dueDateProperty: [String: Any] = ["date": dateValue]

        let body: [String: Any] = [
            "properties": [
                "Due date": dueDateProperty
            ]
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)

            let (_, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                return false
            }

            print("Due date update status code:", httpResponse.statusCode)

            return (200...299).contains(httpResponse.statusCode)
        } catch {
            print("Failed to update due date:", error)
            return false
        }
    }
}
