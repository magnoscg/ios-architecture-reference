import ArchitectureDomain

extension ArchitectureCategory {
  var displayTitle: String {
    switch self {
    case .boundaries:
      "Boundaries"
    case .state:
      "State"
    case .navigation:
      "Navigation"
    case .delivery:
      "Delivery"
    }
  }

  var symbolName: String {
    switch self {
    case .boundaries:
      "square.3.layers.3d"
    case .state:
      "arrow.triangle.2.circlepath"
    case .navigation:
      "point.topleft.down.to.point.bottomright.curvepath"
    case .delivery:
      "shippingbox"
    }
  }
}
