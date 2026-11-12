import SwiftUI

struct TaskListView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var taskVM = TaskViewModel()

    @State private var showingAdd = false
    @State private var editingTask: TodoTask?

    var body: some View {
        NavigationStack {
            Group {
                if taskVM.tasks.isEmpty {
                    EmptyTasksView()
                } else {
                    List {
                        ForEach(taskVM.tasks) { task in
                            TaskRowView(
                                task: task,
                                onToggle: { taskVM.toggleCompleted(task) },
                                onTap: { editingTask = task }
                            )
                        }
                        .onDelete { offsets in
                            let toDelete = offsets.map { taskVM.tasks[$0] }
                            toDelete.forEach { taskVM.deleteTask($0) }
                        }
                    }
                }
            }
            .navigationTitle("My Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Sign Out", role: .destructive) {
                        authVM.signOut()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                TaskFormView(taskVM: taskVM, task: nil)
            }
            .sheet(item: $editingTask) { task in
                TaskFormView(taskVM: taskVM, task: task)
            }
            .alert("Error", isPresented: Binding(
                get: { taskVM.errorMessage != nil },
                set: { if !$0 { taskVM.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(taskVM.errorMessage ?? "")
            }
        }
        .onAppear { taskVM.startListening() }
        .onDisappear { taskVM.stopListening() }
    }
}

private struct EmptyTasksView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No tasks yet")
                .font(.headline)
            Text("Tap + to add your first task.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}
