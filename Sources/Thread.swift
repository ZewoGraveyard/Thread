import POSIX

/// A wrapper for the POSIX pthread_t type.
public final class Thread<T> {

    internal let thread: pthread_t
    private let context: ThreadContext

    public var done: Bool { return context.done }

    /**
     Creates a new thread which immediately begins executing the passed routine.
     */
    public init(routine: () -> (T)) {

        let context = ThreadContext(routine: routine)

        let pthreadPointer = UnsafeMutablePointer<pthread_t?>(allocatingCapacity: 1)
        defer { pthreadPointer.deallocateCapacity(1) }

        let result = pthread_create(
            pthreadPointer,
            nil, // default attributes
            pthreadRunner,
            encode(context)
        )

        guard result == 0 else {
            fatalError("failed with error number \(result)")
        }

        self.thread = pthreadPointer.pointee!
        self.context = context
    }

    deinit {
        pthread_detach(thread)
    }

    /**
     Blocks until the thread's routine has finished executing.

     - returns: Returns the result of the routine.
     */
    public func join() -> T {
        var result: UnsafeMutablePointer<Void>?
        pthread_join(thread, &result)

        //TODO: proper error handling (stuff can fail)
        guard result != nil else {
            fatalError("join did not return a result")
        }

        return decode(result!)
    }

    /**
     Cancels the execution of the thread.
     */
    public func cancel() {
        pthread_cancel(thread)
    }
}

private final class ThreadContext {
    var done = false
    let routine: () -> UnsafeMutablePointer<Void>?
    init<T>(routine: () -> T) {
        self.routine = {
            let result = routine()
            return encode(result)
        }
    }
}

private final class Box<T> {
    let value: T
    init(_ value: T) {
        self.value = value
    }
}

private func pthreadRunner(context: UnsafeMutablePointer<Void>?) -> UnsafeMutablePointer<Void>? {
    // TODO: don't force unwrap
    let context = decode(context!) as ThreadContext
    let result = context.routine()
    context.done = true
    return result
}

private func decode<T>(_ memory: UnsafeMutablePointer<Void>) -> T {
    let unmanaged = Unmanaged<Box<T>>.fromOpaque(OpaquePointer(memory))
    defer { unmanaged.release() }
    return unmanaged.takeUnretainedValue().value
}

private func encode<T>(_ t: T) -> UnsafeMutablePointer<Void> {
    return UnsafeMutablePointer(OpaquePointer(bitPattern: Unmanaged.passRetained(Box(t))))
}
