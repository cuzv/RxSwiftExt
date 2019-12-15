// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Traits",
    platforms: [
        .iOS(.v8),
    ],
    products: [
        .library(name: "RxTraits", targets: ["RxTraits"]),
        .library(name: "DifferentiatorTraits", targets: ["DifferentiatorTraits"]),
        .library(name: "SwiftyJSONTraits", targets: ["SwiftyJSONTraits"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/RxSwiftCommunity/RxGesture", .upToNextMajor(from: "3.0.0")),
        .package(url: "https://github.com/RxSwiftCommunity/RxDataSources", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", .upToNextMajor(from: "5.0.0")),
    ],
    targets: [
        .target(name: "RxTraits", dependencies: ["RxSwift", "RxCocoa", "RxGesture"], path: "Sources/Rx"),
        .target(name: "DifferentiatorTraits", dependencies: ["Differentiator"], path: "Sources/Differentiator"),
        .target(name: "SwiftyJSONTraits", dependencies: ["SwiftyJSON"], path: "Sources/SwiftyJSON"),

        .testTarget(name: "RxTraitsTests",
                    dependencies: ["RxTraits"],
                    path: "Tests/RxTests",
                    swiftSettings: [.unsafeFlags(["-enable-testing"])])
    ]
)
