
public protocol Copyable {
  func copy() -> Self
}

/// This is an implementation detail. You shouldn't conform to this yourself.
@dynamicMemberLookup
public protocol _CopyOnWriteValue {
  associatedtype _COWStorage: AnyObject, Copyable
}
internal protocol _COWHider {
    var _storage: AnyObject { get set }
}
typealias CopyOnWriteValue = _CopyOnWriteValue & _COWHider

extension _CopyOnWriteValue {

    private var _storage: _COWStorage {
        get {
            ((self as! _COWHider)._storage as? _COWStorage).unsafelyUnwrapped
        }
        _modify {
            var c = (self as! _COWHider)._storage as! _COWStorage
            yield &c
        }
        set {
            var c = (self as! _COWHider)
            c._storage = newValue
            self = c as! Self
        }
    }
    
    public subscript<T>(dynamicMember keypath: KeyPath<_COWStorage, T>) -> T {
        get { _storage[keyPath: keypath] }
    }
    
    public subscript<T>(dynamicMember keypath: ReferenceWritableKeyPath<_COWStorage, T>) -> T {
        get { _storage[keyPath: keypath] }
        _modify {
            if !isKnownUniquelyReferenced(&_storage) { _storage = _storage.copy() }
            yield &_storage[keyPath: keypath]
        }
        set {
            if !isKnownUniquelyReferenced(&_storage) { _storage = _storage.copy() }
            _storage[keyPath: keypath] = newValue
        }
    }
}

public struct TestObj: CopyOnWriteValue {
    public final class _COWStorage: Copyable {
        public var propOne: Int
        public var propTwo: String
        public func copy() -> Self {
            print("copying")
            return Self(propOne, propTwo)
        }
        
        init(_ p1: Int, _ p2: String) { self.propOne = p1; self.propTwo = p2 }
    }
	var _storage: AnyObject = _COWStorage(0, "")
  
  public init() {}
}
