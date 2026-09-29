import SwiftUI

struct TaskRow: View {
    let task: NotionTask
    let subjectOptions: [String]
    let priorityOptions: [String]
    
    let onToggleCompleted: () -> Void
    let onNameChanged: (String) -> Void
    let onSubjectChanged: (String?) -> Void
    let onPriorityChanged: (String?) -> Void
    let onDueDateChanged: (Date?) -> Void
    
    @State private var editedName: String
    @State private var isHoveringMetadata = false
    @FocusState private var isNameFocused: Bool
    
    init(
            task: NotionTask,
            subjectOptions: [String],
            priorityOptions: [String],
            onToggleCompleted: @escaping () -> Void,
            onNameChanged: @escaping (String) -> Void,
            onSubjectChanged: @escaping (String?) -> Void,
            onPriorityChanged: @escaping (String?) -> Void,
            onDueDateChanged: @escaping (Date?) -> Void,
        ) {
            self.task = task
            self.subjectOptions = subjectOptions
            self.priorityOptions = priorityOptions
            self.onToggleCompleted = onToggleCompleted
            self.onNameChanged = onNameChanged
            self.onSubjectChanged = onSubjectChanged
            self.onPriorityChanged = onPriorityChanged
            self.onDueDateChanged = onDueDateChanged
            
            _editedName = State(initialValue: task.name)
        }

    var body: some View {
        HStack(spacing: 12) {

            // Checkbox
            Button(action: onToggleCompleted) {
                Image(
                    systemName: task.isCompleted
                        ? "checkmark.circle.fill"
                        : "circle"
                )
                .font(.title3)
            }
            .buttonStyle(.plain)

            // Left side: name + subject
            VStack(alignment: .leading, spacing: 3) {

                TextField("Task name", text: $editedName)
                    .textFieldStyle(.plain)
                    .font(.body)
                    .fontWeight(.medium)
                    .focused($isNameFocused)
                    .onSubmit {
                        isNameFocused = false
                    }
                    .onExitCommand {
                        editedName = task.name
                        isNameFocused = false
                    }
                    .onChange(of: isNameFocused) { wasFocused, isFocused in
                        if wasFocused && !isFocused {
                            onNameChanged(editedName)
                        }
                    }

                Menu {
                    ForEach(subjectOptions, id: \.self) { subject in
                        Button(subject) {
                            onSubjectChanged(subject)
                        }
                    }

                    Divider()

                    Button("None") {
                        onSubjectChanged(nil)
                    }
                } label: {
                    Text(task.subject ?? "No Subject")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .menuStyle(.borderlessButton)
            }

            Spacer()

            // Right side: due date + priority
            VStack(alignment: .trailing, spacing: 3) {

                DateSelector(
                    date: task.dueDate,
                    isHovering: isHoveringMetadata,
                    onChange: { newDate in
                        onDueDateChanged(newDate)
                    }
                )

                Menu {
                    ForEach(priorityOptions, id: \.self) { priority in
                        Button(priority) {
                            onPriorityChanged(priority)
                        }
                    }

                    Divider()

                    Button("None") {
                        onPriorityChanged(nil)
                    }
                } label: {
                    Text(task.priority ?? "No Priority")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .menuStyle(.borderlessButton)
            }
            .onHover { isHoveringMetadata = $0 }
        }
        .padding(.vertical, 6)
    }
}
