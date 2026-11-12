import Foundation
import FirebaseAuth
import FirebaseFirestore

import FirebaseFirestoreSwift

@MainActor
final class TaskViewModel: ObservableObject {
    @Published var tasks: [TodoTask] = []
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    private var uid: String? { Auth.auth().currentUser?.uid }

    private func tasksRef(_ uid: String) -> CollectionReference {
        db.collection("users").document(uid).collection("tasks")
    }

    // READ (real-time)
    func startListening() {
        guard let uid = uid else { return }
        listener?.remove()
        listener = tasksRef(uid)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                Task { @MainActor in
                    guard let self = self else { return }
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        return
                    }
                    self.tasks = snapshot?.documents.compactMap {
                        try? $0.data(as: TodoTask.self)
                    } ?? []
                }
            }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
        tasks = []
    }

    // CREATE
    func addTask(title: String, description: String) {
        guard let uid = uid else { return }
        let task = TodoTask(title: title, description: description)
        do {
            _ = try tasksRef(uid).addDocument(from: task)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // UPDATE
    func updateTask(_ task: TodoTask, title: String, description: String) {
        guard let uid = uid, let id = task.id else { return }
        var updated = task
        updated.title = title
        updated.description = description
        updated.updatedAt = Date()
        do {
            try tasksRef(uid).document(id).setData(from: updated)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleCompleted(_ task: TodoTask) {
        guard let uid = uid, let id = task.id else { return }
        tasksRef(uid).document(id).updateData([
            "isCompleted": !task.isCompleted,
            "updatedAt": Date()
        ]) { [weak self] error in
            if let error = error {
                Task { @MainActor in self?.errorMessage = error.localizedDescription }
            }
        }
    }

    // DELETE
    func deleteTask(_ task: TodoTask) {
        guard let uid = uid, let id = task.id else { return }
        tasksRef(uid).document(id).delete { [weak self] error in
            if let error = error {
                Task { @MainActor in self?.errorMessage = error.localizedDescription }
            }
        }
    }
}
