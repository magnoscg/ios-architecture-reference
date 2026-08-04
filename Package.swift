// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "IOSArchitectureReference",
  platforms: [
    .iOS(.v18),
    .macOS(.v15),
  ],
  products: [
    .library(name: "ArchitectureDomain", targets: ["ArchitectureDomain"]),
    .library(name: "ArchitectureData", targets: ["ArchitectureData"]),
    .library(name: "ArchitectureFeature", targets: ["ArchitectureFeature"]),
    .library(name: "ArchitectureComposition", targets: ["ArchitectureComposition"]),
  ],
  targets: [
    .target(name: "ArchitectureDomain"),
    .target(
      name: "ArchitectureData",
      dependencies: ["ArchitectureDomain"]
    ),
    .target(
      name: "ArchitectureFeature",
      dependencies: ["ArchitectureDomain"]
    ),
    .target(
      name: "ArchitectureComposition",
      dependencies: [
        "ArchitectureDomain",
        "ArchitectureData",
        "ArchitectureFeature",
      ]
    ),
    .testTarget(
      name: "ArchitectureDomainTests",
      dependencies: ["ArchitectureDomain"]
    ),
    .testTarget(
      name: "ArchitectureDataTests",
      dependencies: ["ArchitectureDomain", "ArchitectureData"]
    ),
    .testTarget(
      name: "ArchitectureFeatureTests",
      dependencies: ["ArchitectureDomain", "ArchitectureFeature"]
    ),
  ]
)
