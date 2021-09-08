// swift-tools-version:5.0

import PackageDescription

let package = Package(
  name: "RxSwiftExt",
  products: [
    .library(name: "RxSwiftExt", targets: ["RxSwiftExt"]),
  ],
  dependencies: [
    .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "6.2.0")),
    .package(url: "https://github.com/cuzv/ResultConvertible", .branch("master")),
  ],
  targets: [
    .target(
      name: "RxSwiftExt",
      dependencies: ["RxSwift", "RxCocoa", "ResultConvertible"],
      path: "Sources"
    ),
    .testTarget(
      name: "RxTests",
      dependencies: ["RxSwiftExt"],
      path: "Tests/RxTests",
      swiftSettings: [.unsafeFlags(["-enable-testing"])]
    )
  ]
)
