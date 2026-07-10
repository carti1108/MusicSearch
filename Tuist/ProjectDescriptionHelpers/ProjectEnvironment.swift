import ProjectDescription

public struct ProjectEnvironment {
    public static let deploymentTarget: DeploymentTargets = .iOS("17.0")
    public static let bundlePrefix = "com.carti"
    
    public static let packages: [Package] = [
        .remote(url: "https://github.com/onevcat/Kingfisher.git", requirement: .upToNextMajor(from: "8.0.0")),
        .remote(url: "https://github.com/carti1108/MicroRIBs", requirement: .branch("main")),
        .remote(url: "https://github.com/carti1108/NetworkLayer.git", requirement: .branch("main")),
        .remote(url: "https://github.com/pointfreeco/swift-composable-architecture.git", requirement: .upToNextMajor(from: "1.10.0"))
    ]
    
    public static let projectSettings: Settings = .settings(
        base: [
            "CODE_SIGN_IDENTITY": "",
            "CODE_SIGNING_REQUIRED": "NO",
            "CODE_SIGNING_ALLOWED": "NO",
            "ENABLE_USER_SCRIPT_SANDBOXING": "YES",
            "CLANG_ENABLE_MODULE_VERIFIER": "YES"
        ],
        configurations: [
            .debug(name: "Debug", xcconfig: .relativeToRoot("Config.xcconfig")),
            .release(name: "Release", xcconfig: .relativeToRoot("Config.xcconfig"))
        ]
    )
    
    public static let appSettings: Settings = .settings(
        base: [
            "CODE_SIGN_STYLE": "Automatic",
            "CODE_SIGN_IDENTITY": "Apple Development",
            "CODE_SIGNING_REQUIRED": "YES",
            "CODE_SIGNING_ALLOWED": "YES",
            "ENABLE_USER_SCRIPT_SANDBOXING": "YES",
            "CLANG_ENABLE_MODULE_VERIFIER": "YES"
        ],
        configurations: [
            .debug(name: "Debug", xcconfig: .relativeToRoot("Config.xcconfig")),
            .release(name: "Release", xcconfig: .relativeToRoot("Config.xcconfig"))
        ]
    )
}
