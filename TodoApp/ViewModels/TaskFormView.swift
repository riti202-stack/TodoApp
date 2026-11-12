import SwiftUI

struct TaskFormView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var taskVM: TaskViewModel
    let task: TodoTask?          // nil = add, non-nil = edit

    @State private var title = ""
    @State private var details = ""

    private var isEditing: Bool { task != nil }
    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Title") {
                    TextField("Task title", text: $title)
                }
                Section("Description") {
                    TextEditor(text: $details)
                        .frame(minHeight: 120)
                }
                if let task = task {
                    Section {
                        Button("Delete Task", role: .destructive) {
                            taskVM.deleteTask(task)
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Task" : "New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let desc = details.trimmingCharacters(in: .whitespacesAndNewlines)
                        if let task = task {
                            taskVM.updateTask(task, title: trimmedTitle, description: desc)
                        } else {
                            taskVM.addTask(title: trimmedTitle, description: desc)
                        }
                        dismiss()
                    }
                    .disabled(trimmedTitle.isEmpty)
                }
            }
            .onAppear {
                if let task = task {
                    title = task.title
                    details = task.description
                }
            }
        }
    }
}
