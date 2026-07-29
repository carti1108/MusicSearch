import ProjectDescription

public struct ProjectEnvironment {
    public static let deploymentTarget: DeploymentTargets = .iOS("18.0")
    public static let bundlePrefix = "com.carti"
    
        
    public static let projectSettings: Settings = .settings(
        base: [
            "CODE_SIGN_IDENTITY": "",
            "CODE_SIGNING_REQUIRED": "NO",
            "CODE_SIGNING_ALLOWED": "NO",
            "ENABLE_USER_SCRIPT_SANDBOXING": "YES",
            "CLANG_ENABLE_MODULE_VERIFIER": "YES",
            "SWIFT_UPCOMING_FEATURE_INFER_SENDABLE_FROM_CAPTURES": "YES",
            "SWIFT_STRICT_CONCURRENCY": "complete"
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
            "CLANG_ENABLE_MODULE_VERIFIER": "YES",
            "SWIFT_UPCOMING_FEATURE_INFER_SENDABLE_FROM_CAPTURES": "YES",
            "SWIFT_STRICT_CONCURRENCY": "complete"
        ],
        configurations: [
            .debug(name: "Debug", xcconfig: .relativeToRoot("Config.xcconfig")),
            .release(name: "Release", xcconfig: .relativeToRoot("Config.xcconfig"))
        ]
    )
}
