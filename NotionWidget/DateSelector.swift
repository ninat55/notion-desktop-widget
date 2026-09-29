import SwiftUI

struct DateSelector: View {
    let date: Date?
    let isHovering: Bool
    let onChange: (Date?) -> Void

    @State private var selectedDate: Date
    @State private var isCalendarOpen = false

    init(
        date: Date?,
        isHovering: Bool,
        onChange: @escaping (Date?) -> Void
    ) {
        self.date = date
        self.isHovering = isHovering
        self.onChange = onChange

        _selectedDate = State(initialValue: date ?? Date())
    }

    var body: some View {
        HStack(spacing: 3) {
            if let date {
                Button {
                    isCalendarOpen.toggle()
                } label: {
                    Text(date, style: .date)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .buttonStyle(.plain)

                if isHovering {
                    Button {
                        onChange(nil)
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 8))
                            .offset(y: -0.5)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                }
            } else {
                Button {
                    selectedDate = Date()
                    onChange(selectedDate)
                    isCalendarOpen = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 8))
                        .frame(height: 14)
                        .opacity(isHovering ? 1 : 0)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
        }
        .popover(isPresented: $isCalendarOpen) {
            VStack {
                DatePicker(
                    "",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .labelsHidden()
                .datePickerStyle(.graphical)
                .focusEffectDisabled()
                .onChange(of: selectedDate) { oldDate, newDate in
                    onChange(newDate)
                    isCalendarOpen = false
                }
            }
            .padding()
            .fixedSize()
        }
        .onChange(of: date) { oldDate, newDate in
            selectedDate = newDate ?? Date()
        }
    }
}
