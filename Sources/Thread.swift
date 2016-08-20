import POSIX

final class Box<T> {
    let value: T
    init(_ value: T) {
        self.value = value
    }
}

final class Context {
    var done = false
    let routine: () -> UnsafeMutablePointer<Void>?
    init<T>(routine: () -> T) {
        self.routine = {
            let result = routine()
            let box = Box(result)
            return UnsafeMutablePointer(OpaquePointer(bitPattern: Unmanaged.passRetained(box)))
        }
    }
}

public final class Thread<T> {

    let pthread: pthread_t
    let context: Context
    var done: Bool { return context.done }

    public init(routine: () -> (T)) {

        let context = Context(routine: routine)

        let pthreadPointer = UnsafeMutablePointer<pthread_t?>(allocatingCapacity: 1)
        defer { pthreadPointer.deallocateCapacity(1) }

        let result = pthread_create(
            pthreadPointer,
            nil, // default attributes
            { context in
                let unmanaged = Unmanaged<Context>.fromOpaque(OpaquePointer(context!))
                defer { unmanaged.release() }

                let context = unmanaged.takeUnretainedValue()
                let result = context.routine()
                context.done = true
                return result
            },
            UnsafeMutablePointer(OpaquePointer(bitPattern: Unmanaged.passRetained(context)))
        )

        guard result == 0 else {
            fatalError("failed with error number \(result)")
        }

        self.pthread = pthreadPointer.pointee!
        self.context = context
    }

    public func join() -> T {
        var result: UnsafeMutablePointer<Void>?
        pthread_join(pthread, &result)

        guard result != nil else {
            fatalError("join did not return a result")
        }

        let unmanaged = Unmanaged<Box<T>>.fromOpaque(OpaquePointer(result!))
        defer { unmanaged.release() }
        let box = unmanaged.takeUnretainedValue()
        return box.value
    }

    func exit(with result: UnsafeMutablePointer<Void>? = nil) {
        pthread_exit(result)
    }

    deinit {
        pthread_detach(pthread)
    }
}
