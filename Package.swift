// swift-tools-version:5.9

import PackageDescription

let package = Package(
  name: "RxSwiftExt",
  platforms: [
    .iOS(.v12),
    .macOS(.v10_13),
    .watchOS(.v4),
    .tvOS(.v12),
  ],
  products: [
    .library(name: "RxSwiftExt", targets: ["RxSwiftExt"]),
  ],
  dependencies: [
    .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "6.2.0")),
    .package(url: "https://github.com/cuzv/ResultConvertible", branch: "master"),
  ],
  targets: [
    .target(
      name: "RxSwiftExt",
      dependencies: [
        .product(name: "RxSwift", package: "RxSwift"),
        .product(name: "RxCocoa", package: "RxSwift"),
        .product(name: "ResultConvertible", package: "ResultConvertible"),
      ],
      path: "Sources"
    ),
    .testTarget(
      name: "RxTests",
      dependencies: ["RxSwiftExt"],
      path: "Tests/RxTests",
      swiftSettings: [.unsafeFlags(["-enable-testing"])]
    ),
  ]
)
