/// Represents a property that allows observation of its changes.
public protocol PropertyType {
	typealias Value

	/// The current value of the property.
	var value: Value { get }

	/// A producer for Signals that will send the property's current value,
	/// followed by all changes over time.
	var producer: SignalProducer<Value, NoError> { get }
}

/// Represents a read-only view to a property of type T that allows observation
/// of its changes.
public struct PropertyOf<T>: PropertyType {
	public typealias Value = T

	private let _value: () -> T
	private let _producer: () -> SignalProducer<T, NoError>

	public var value: T {
		return _value()
	}

	public var producer: SignalProducer<T, NoError> {
		return _producer()
	}

	/// Initializes the receiver as a wrapper around the given property.
	public init<P: PropertyType where P.Value == T>(_ property: P) {
		_value = { property.value }
		_producer = { property.producer }
	}
}

/// A property that never changes.
public struct ConstantProperty<T>: PropertyType {
	typealias Value = T

	public let value: T
	public let producer: SignalProducer<T, NoError>

	/// Initializes the property to have the given value.
	public init(_ value: T) {
		self.value = value
		self.producer = SignalProducer(value: value)
	}
}

/// A mutable property of type T that allows observation of its changes.
///
/// Instances of this class are thread-safe.
public final class MutableProperty<T>: PropertyType {
	public typealias Value = T

	private let observer: Signal<T, NoError>.Observer

	/// The current value of the property.
	///
	/// Setting this to a new value will notify all observers of any Signals
	/// created from the `values` producer.
	public var value: T {
		get {
			let result = producer |> first
			return result!.value!
		}

		set(x) {
			sendNext(observer, x)
		}
	}

	/// A producer for Signals that will send the property's current value,
	/// followed by all changes over time, then complete when the property has
	/// deinitialized.
	public let producer: SignalProducer<T, NoError>

	/// Initializes the property with the given value to start.
	public init(_ initialValue: T) {
		let (producer, observer) = SignalProducer<T, NoError>.buffer(1)
		self.producer = producer
		self.observer = observer

		value = initialValue
	}

	deinit {
		sendCompleted(observer)
	}
}

extension MutableProperty: SinkType {
	public func put(value: T) {
		self.value = value
	}
}

infix operator <~ {
	associativity right
	precedence 90
}

/// Binds a signal to a property, updating the property's value to the latest
/// value sent by the signal.
///
/// The binding will automatically terminate when the property is deinitialized,
/// or when the signal sends a `Completed` event.
public func <~ <T>(property: MutableProperty<T>, signal: Signal<T, NoError>) -> Disposable {
	let disposable = CompositeDisposable()
	let propertyDisposable = property.producer.start(completed: {
		disposable.dispose()
	})

	disposable.addDisposable(propertyDisposable)

	let signalDisposable = signal.observe(next: { [weak property] value in
		property?.value = value
		return
	}, completed: {
		disposable.dispose()
	})

	disposable.addDisposable(signalDisposable)
	return disposable
}

/*
FIXME: DISABLED DUE TO COMPILER BUG

/// Creates a signal from the given producer, which will be immediately bound to
/// the given property, updating the property's value to the latest value sent
/// by the signal.
///
/// The binding will automatically terminate when the property is deinitialized,
/// or when the created signal sends a `Completed` event.
public func <~ <T>(property: MutableProperty<T>, producer: SignalProducer<T, NoError>) -> Disposable {
	let disposable = CompositeDisposable()
	let propertyDisposable = property.producer.start(completed: {
		disposable.dispose()
	})

	disposable.addDisposable(propertyDisposable)

	producer.startWithSignal { signal, signalDisposable in
		disposable.addDisposable(signalDisposable)

		signal.observe(next: { [weak property] value in
			property?.value = value
			return
		}, completed: {
			disposable.dispose()
		})
	}

	return disposable
}

/// Binds `destinationProperty` to the latest values of `sourceProperty`.
///
/// The binding will automatically terminate when either property is
/// deinitialized.
public func <~ <T, P: PropertyType where P.Value == T>(destinationProperty: MutableProperty<T>, sourceProperty: P) -> Disposable {
	let disposable = CompositeDisposable()
	let destinationDisposable = destinationProperty.producer.start(completed: {
		disposable.dispose()
	})

	disposable.addDisposable(destinationDisposable)

	sourceProperty.producer.startWithSignal { signal, sourceDisposable in
		disposable.addDisposable(sourceDisposable)

		signal.observe(next: { [weak destinationProperty] value in
			destinationProperty?.value = value
			return
		}, completed: {
			disposable.dispose()
		})
	}

	return disposable
}
*/
