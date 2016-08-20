import POSIX

/// A wrapper for the POSIX pthread_mutex_t type.
public final class Lock {
    internal let mutex = UnsafeMutablePointer<pthread_mutex_t>(allocatingCapacity: 1)

    /**
     Creates a pthread_mutex using the default attributes.
     */
    public init() {
        // default attributes
        pthread_mutex_init(mutex, nil)
    }

    deinit {
        mutex.deallocateCapacity(1)
    }

    /**
     Acquires the lock for the duration of the closure.
     */
    public func acquire(_ closure: () -> ()) {
        lock()
        closure()
        unlock()
    }

    /**
     Acquires the lock for the duration of the closure.

     - parameter closure: A closure returning a value of type T.

     - returns: Returns the result of the closure
     */
    public func acquire<T>(_ closure: () -> (T)) -> T {
        lock()
        let result = closure()
        unlock()
        return result
    }

    /**
     Locks the lock
     */
    public func lock() {
        pthread_mutex_lock(mutex)
    }

    /**
     Unlocks the lock
     */
    public func unlock() {
        pthread_mutex_unlock(mutex)
    }

    /**
     Blocks until the condition has been resolved.

     - note: Unlocks the lock while waiting, re-locks afterwards.
     */
    public func wait(for condition: Condition) {
        pthread_cond_wait(condition.condition, mutex)
    }
}
