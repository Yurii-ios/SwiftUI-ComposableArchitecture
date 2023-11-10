public struct PrimeAlert: Equatable, Identifiable {
    public var n: Int
    public var prime: Int
    public var id: Int { self.prime }
    
    public init(n: Int, prime: Int) {
        self.n = n
        self.prime = prime
    }
}

extension PrimeAlert {
  public var title: String {
    return "The \(ordinal(self.n)) prime is \(self.prime)"
  }
}

public func ordinal(_ n: Int) -> String {
  let formatter = NumberFormatter()
  formatter.numberStyle = .ordinal
  return formatter.string(for: n) ?? ""
}
