// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LoadingImageView",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(name: "LoadingImageView", targets: ["LoadingImageView"]),
    ],
    targets: [
        .target(name: "LoadingImageView", path: "Sources/LoadingImageView", resources: [Resource.process("Media.xcassets")])
    ]
    

)
