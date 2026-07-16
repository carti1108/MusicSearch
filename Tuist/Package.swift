// swift-tools-version: 5.9
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        productTypes: [
            "ComposableArchitecture": .framework,
            "Kingfisher": .framework,
            "MicroRIBs": .framework,
            "NetworkLayer": .framework
        ]
    )
#endif

let package = Package(
    name: "MusicSearchDependencies",
    dependencies: [
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.0.0"),
        .package(url: "https://github.com/carti1108/MicroRIBs", branch: "main"),
        .package(url: "https://github.com/carti1108/NetworkLayer.git", branch: "main"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.10.0")
    ]
)
