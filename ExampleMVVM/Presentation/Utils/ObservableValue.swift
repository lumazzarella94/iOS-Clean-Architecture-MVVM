import Foundation

    /// A property wrapper class to make a value observable and notify observers when the value changes.
    /// This class is thread-safe and uses event coalescence to handle multiple events efficiently.
@propertyWrapper
class ObservableValue<Value> {
    
        /// The actual value being observed.
    var value: Value {
        didSet {
            scheduleNotification()
        }
    }
    
        /// The list of observers. Each observer is a tuple containing an identifier and a closure to execute when the value changes.
    private var observers: [(String, (Value) -> Void)] = []
    
        // Make ObservableValue thread-safe
        /// A debouncer to coalesce multiple events into a single notification.
    private var debouncer: DispatchSourceTimer?
    
        /// The interval for debouncing events.
    private let debounceInterval: TimeInterval = 0.1
    
        /// A concurrent queue for accessing the value.
    private let valueAccessQueue = DispatchQueue(label: "ObservableValue", attributes: .concurrent)
    
        /// A serial queue for accessing the observers.
    private let observerAccessQueue = DispatchQueue(label: "Observers")
    
        /// The wrapped value that triggers observers when it changes.
    var wrappedValue: Value {
        get {
            return valueAccessQueue.sync { value }
        }
        set {
            valueAccessQueue.async(flags: .barrier) {
                self.value = newValue
            }
        }
    }
    
        /// The projected value, which is the `ObservableValue` itself.
    var projectedValue: ObservableValue<Value> {
        self
    }
    
        /// Initializes the observable value with an initial value.
        /// - Parameter wrappedValue: The initial value.
    init(wrappedValue: Value) {
        self.value = wrappedValue
    }
    
    deinit {
        debouncer?.cancel()  // Cancel the existing timer if any.
    }
    
        /// Adds an observer to the value.
        /// - Parameter observer: The closure to execute when the value changes.
        /// - Returns: A unique identifier for the observer.
    func bind(observer: @escaping (Value) -> Void) -> String {
        let id = UUID().uuidString
        observerAccessQueue.sync {
            observers.append((id, observer))
        }
        observer(wrappedValue)
        return id
    }
    
        /// Removes an observer with the given identifier.
        /// - Parameter id: The unique identifier of the observer to remove.
    func unbind(_ id: String) {
        observerAccessQueue.sync {
            observers.removeAll { $0.0 == id }
        }
    }
    
        /// Notifies all observers of the value change.
    private func notifyObservers() {
        observerAccessQueue.sync {
            observers.forEach { _, observer in observer(value) }
        }
    }
    
        /// Schedules a notification to observers, using a debounce mechanism to coalesce events.
    private func scheduleNotification() {
        debouncer?.cancel() // Cancel the existing timer
        
        let timer = DispatchSource.makeTimerSource()
        timer.schedule(deadline: .now() + debounceInterval)
        timer.setEventHandler { [weak self] in
            self?.notifyObservers()
        }
        timer.resume()
        debouncer = timer
    }
}

protocol ObserverValue {
    associatedtype Value
    var binderID: String { get }
    var observableValue: ObservableValue<Value> { get }
}

struct Observer<Value>: ObserverValue {
    let binderID: String
    let observableValue: ObservableValue<Value>
}

class AnyObserverValue {
    let binderID: String
    private let _unbind: (String) -> Void
    
    init<O: ObserverValue>(_ observer: O) {
        self.binderID = observer.binderID
        self._unbind = observer.observableValue.unbind
    }
    
    func unbind() {
        _unbind(binderID)
    }
}
