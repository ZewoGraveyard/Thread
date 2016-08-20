import POSIX

/// A wrapper for the pthread_cond_t type.
public final class Condition {
    internal let condition = UnsafeMutablePointer<pthread_cond_t>(allocatingCapacity: 1)

    /**
     Creates a condition using the default attributes
     */
    public init() {
        // default attributes
        // TOOD: Don't use default attributes
        pthread_cond_init(condition, nil)
    }

    deinit {
        condition.deallocateCapacity(1)
    }

    /**
     Resolves the condition, unblocking threads (single or all, depending on `globally`) waiting for the condition.

     - parameter globally: If true, then all threads waiting on the condition are unblocked. Otherwise, only unblocks a single thread.
     */
    func resolve(globally: Bool) {
        if globally {
            pthread_cond_broadcast(condition)
        } else {
            pthread_cond_signal(condition)
        }
    }
}
