import POSIX

/// A wrapper for the POSIX pthread_mutex_t type.
public final class Lock {
    internal var mutex = pthread_mutex_t()

    /**
     Creates a pthread_mutex using the default attributes.
     */
    public init() {
        // default attributes
        pthread_mutex_init(&mutex, nil)
    }

    deinit {
        pthread_mutex_destroy(&mutex)
    }

    /**
     Acquires the lock for the duration of the closure. Releases afterwards.

     - note: If lock is already acquired, suspends execution until
     lock is released.
     */
    public func acquire(_ closure: () -> ()) {
        acquire()
        closure()
        release()
    }

    /**
     Acquires the lock for the duration of the closure. Releases afterwards.

     - note: If lock is already acquired, suspends execution until
     lock is released.

     - parameter closure: A closure returning a value of type T. Executed after
     the lock has been acquired.

     - returns: Returns the result of the closure
     */
    public func acquire<T>(_ closure: () -> (T)) -> T {
        acquire()
        let result = closure()
        release()
        return result
    }

    /**
     Acquires the lock.

     - note: If lock is acquired by a different thread, current thread's execution
     is suspended until the lock is released.
     */
    public func acquire() {
        // TODO: error handling
        pthread_mutex_lock(&mutex)
    }

    /**
     Releases the lock.

     - note: Behavior when releasing an unacquired lock is undefined.
     */
    public func release() {
        pthread_mutex_unlock(&mutex)
    }

    /**
     Suspends execution until the condition has been resolved.

     - note: Releases the lock while waiting, re-acquires afterwards.

     - precondition: Lock is already acquired. Behavior is undefined otherwise.
     */
    public func wait(for condition: Condition) {
        pthread_cond_wait(&condition.condition, &mutex)
    }
}
