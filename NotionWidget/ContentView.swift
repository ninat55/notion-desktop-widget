import SwiftUI
import AppKit

struct ContentView: View {
    @State private var tasks: [NotionTask] = []
    @State private var subjectOptions: [String] = []
    @State private var priorityOptions: [String] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Tasks")
                    .font(.title)
                    .fontWeight(.semibold)

                Spacer()

                Button {
                    Task {
                        await loadData()
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.plain)
                .help("Refresh tasks")
            }
            
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(tasks) { task in
                        TaskRow(
                            task: task,
                            subjectOptions: subjectOptions,
                            priorityOptions: priorityOptions,
                            onToggleCompleted: {
                                toggleCompleted(task)
                            },
                            onNameChanged: { newName in
                                changeName(task, to: newName)
                            },
                            onSubjectChanged: { newSubject in
                                changeSubject(task, to: newSubject)
                            },
                            onPriorityChanged: { newPriority in
                                changePriority(task, to: newPriority)
                            },
                            onDueDateChanged: { newDate in
                                changeDueDate(task, to: newDate)
                            }
                        )
                        
                        Divider()
                    }
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
//        .onTapGesture {
//            NSApplication.shared.keyWindow?.makeFirstResponder(nil)
//        }
        .task {
            await loadData()
        }
    }
    
    private func loadData() async {
        guard let token = ProcessInfo.processInfo.environment["NOTION_TOKEN"] else {
            print("NOTION_TOKEN is missing")
            return
        }

        tasks = await NotionService.shared.fetchTasks(token: token)

        let options = await NotionService.shared.fetchSelectOptions(token: token)

        subjectOptions = options.subjects
        priorityOptions = options.priorities
    }
    
    private func toggleCompleted(_ task: NotionTask) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else {
            return
        }

        let newValue = !tasks[index].isCompleted

        // Update the UI immediately
        tasks[index].isCompleted = newValue

        Task {
            guard let token = ProcessInfo.processInfo.environment["NOTION_TOKEN"] else {
                print("NOTION_TOKEN is missing")
                tasks[index].isCompleted = !newValue
                return
            }

            let success = await NotionService.shared.updateTaskCompletion(
                pageID: task.id,
                isCompleted: newValue,
                token: token
            )

            // If Notion rejected the update, undo the local change
            if !success {
                tasks[index].isCompleted = !newValue
            }
        }
    }
    
    private func changeName(_ task: NotionTask, to newName: String) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else {
            return
        }

        let oldName = tasks[index].name

        // Nothing actually changed
        guard newName != oldName else {
            return
        }

        // Update the UI immediately
        tasks[index].name = newName

        Task {
            guard let token = ProcessInfo.processInfo.environment["NOTION_TOKEN"] else {
                print("NOTION_TOKEN is missing")
                tasks[index].name = oldName
                return
            }

            let success = await NotionService.shared.updateTaskName(
                pageID: task.id,
                name: newName,
                token: token
            )

            if !success {
                tasks[index].name = oldName
            }
        }
    }
    
    private func changeSubject(_ task: NotionTask, to newSubject: String?) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else {
            return
        }

        let oldSubject = tasks[index].subject

        guard newSubject != oldSubject else {
            return
        }

        tasks[index].subject = newSubject

        Task {
            guard let token = ProcessInfo.processInfo.environment["NOTION_TOKEN"] else {
                print("NOTION_TOKEN is missing")
                tasks[index].subject = oldSubject
                return
            }

            let success = await NotionService.shared.updateTaskSubject(
                pageID: task.id,
                subject: newSubject,
                token: token
            )

            if !success {
                tasks[index].subject = oldSubject
            }
        }
    }
    
    private func changePriority(_ task: NotionTask, to newPriority: String?) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else {
            return
        }

        let oldPriority = tasks[index].priority

        guard newPriority != oldPriority else {
            return
        }

        tasks[index].priority = newPriority

        Task {
            guard let token = ProcessInfo.processInfo.environment["NOTION_TOKEN"] else {
                print("NOTION_TOKEN is missing")
                tasks[index].priority = oldPriority
                return
            }

            let success = await NotionService.shared.updateTaskPriority(
                pageID: task.id,
                priority: newPriority,
                token: token
            )

            if !success {
                tasks[index].priority = oldPriority
            }
        }
    }
    
    private func changeDueDate(_ task: NotionTask, to newDate: Date?) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else {
            return
        }

        let oldDate = tasks[index].dueDate

        guard newDate != oldDate else {
            return
        }

        tasks[index].dueDate = newDate

        Task {
            guard let token = ProcessInfo.processInfo.environment["NOTION_TOKEN"] else {
                print("NOTION_TOKEN is missing")
                tasks[index].dueDate = oldDate
                return
            }

            let success = await NotionService.shared.updateTaskDueDate(
                pageID: task.id,
                dueDate: newDate,
                token: token
            )

            if !success {
                tasks[index].dueDate = oldDate
            }
        }
    }
}

#Preview {
    ContentView()
}
