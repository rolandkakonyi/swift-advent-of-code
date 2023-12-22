import Foundation

extension Sequence {
    func map<T>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T] {
        var values: [T] = []

        for element in self {
            try await values.append(transform(element))
        }

        return values
    }

    func compactMap<T>(
        _ transform: (Element) async throws -> T?
    ) async rethrows -> [T] {
        var values: [T] = []

        for element in self {
            if let result = try await transform(element) {
                values.append(result)
            }
        }

        return values
    }

    func flatMap<T: Sequence>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T.Element] {
        var values: [T.Element] = []

        for element in self {
            try await values.append(contentsOf: transform(element))
        }

        return values
    }

    func forEach(
        _ operation: (Element) async throws -> Void
    ) async rethrows {
        for element in self {
            try await operation(element)
        }
    }

    func reduce<T>(
        _ initialResult: T,
        _ nextPartialResult: ((T, Element) async throws -> T)
    ) async rethrows -> T {
        var result = initialResult
        for element in self {
            result = try await nextPartialResult(result, element)
        }
        return result
    }
}

extension Sequence {
    func concurrentForEach(
        _ operation: @escaping (Element) async -> Void
    ) async {
        // A task group automatically waits for all of its
        // sub-tasks to complete, while also performing those
        // tasks in parallel:
        await withTaskGroup(of: Void.self) { group in
            for element in self {
                group.addTask {
                    await operation(element)
                }
            }
        }
    }
}

extension Sequence {
    func concurrentMap<T>(
        _ transform: @escaping (Element) async throws -> T
    ) async throws -> [T] {
        let tasks = map { element in
            Task {
                try await transform(element)
            }
        }

        return try await tasks.map { task in
            try await task.value
        }
    }
}
