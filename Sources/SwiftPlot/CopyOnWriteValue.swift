
public protocol Copyable {
  func copy() -> Self
}

/// This is an implementation detail. You shouldn't conform to this yourself.
@dynamicMemberLookup
public protocol _CopyOnWriteValue {
  associatedtype _COWStorage: AnyObject, Copyable
  var _storage: _COWStorage { get set }
}

extension _CopyOnWriteValue {
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

public struct TestObj: _CopyOnWriteValue {
  
  public final class _COWStorage: Copyable {
    public var propOne: Int
    public var propTwo: String
    public func copy() -> Self {
      print("copying")
      return Self(propOne, propTwo)
    }
    
    init(_ p1: Int, _ p2: String) { self.propOne = p1; self.propTwo = p2 }
  }
  public var _storage = _COWStorage(0, "")
  
  public init() {}
}
