
/// A namespace for graphs which may be drawn from this sequence.
public struct SequencePlots<Base> where Base: Sequence {
  var base: Base
}

extension Sequence {
  /// Graphs which may be drawn from this sequence.
  public var plots: SequencePlots<Self> {
    return SequencePlots(base: self)
  }
}
