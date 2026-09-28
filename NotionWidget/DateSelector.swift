import SwiftUI

struct DateSelector: View {
    let date: Date
    let onChange: (Date) -> Void

    @State private var selectedDate: Date
    @State private var isCalendarOpen = false

    init(
        date: Date,
        onChange: @escaping (Date) -> Void
    ) {
        self.date = date
        self.onChange = onChange

        _selectedDate = State(initialValue: date)
    }

    var body: some View {
        Button {
            isCalendarOpen.toggle()
        } label: {
            Text(selectedDate, style: .date)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
        .overlay(alignment: .topTrailing) {
            if isCalendarOpen {
                DatePicker(
                    "",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .labelsHidden()
                .datePickerStyle(.graphical)
                .padding(8)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 8)
                .fixedSize()
                .offset(y: 24)
                .zIndex(100)
                .onChange(of: selectedDate) { oldDate, newDate in
                    onChange(newDate)
                    isCalendarOpen = false
                }
            }
        }
        .onChange(of: date) { oldDate, newDate in
            selectedDate = newDate
        }
    }
}
