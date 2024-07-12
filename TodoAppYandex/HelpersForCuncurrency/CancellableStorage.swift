import Foundation


public final class CancellablesStorage: Cancellable, @unchecked Sendable {
    public enum State {
        case active
        case cancelled
        case deactivated
    }

    private let lock = NSLock()
    private var cancellables: [Cancellable] = []
    private var _state = State.active

    
    public var state: State {
        defer { lock.unlock() }

        lock.lock()

        return _state
    }

    public init() { }

    
    
    public func cancel() {
        lock.lock()

        if _state != State.active {
            return lock.unlock()
        }

        _state = State.cancelled

        let cancellables = self.cancellables
        
        self.cancellables.removeAll()

        lock.unlock()

        cancellables.forEach { $0.cancel() }
    }

    
    @discardableResult public func add(_ cancellable: Cancellable) -> Bool {
        lock.lock()

        switch _state {
        case .active:
            cancellables.append(cancellable)

            lock.unlock()

            return true

        case .cancelled:
            lock.unlock()

            cancellable.cancel()

            return false

        case .deactivated:
            lock.unlock()

            return false
        }
    }

    
    public func deactivate() -> Bool {
        lock.lock()

        if _state != State.active {
            lock.unlock()

            return false
        }

        _state = State.deactivated

        self.cancellables.removeAll()

        lock.unlock()

        return true
    }
}
