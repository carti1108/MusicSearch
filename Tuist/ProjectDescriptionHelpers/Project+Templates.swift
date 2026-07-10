import ProjectDescription

public extension Target {
    
    static func domainTargets(
        name: String,
        bundlePrefix: String = ProjectEnvironment.bundlePrefix,
        deploymentTarget: DeploymentTargets = ProjectEnvironment.deploymentTarget,
        settings: Settings = ProjectEnvironment.projectSettings,
        dependencies: [TargetDependency] = [],
        basePath: String? = nil,
        folderName: String? = nil
    ) -> Target {
        let path = basePath ?? ""
        let folder = folderName ?? "Domain"
        
        let resolvedPath = path.isEmpty ? folder : "\(path)/\(folder)"
        
        return Target.target(
            name: "\(name)Domain",
            destinations: [.iPhone],
            product: .staticFramework,
            bundleId: "\(bundlePrefix).\(name)Domain",
            deploymentTargets: deploymentTarget,
            infoPlist: .default,
            sources: ["\(resolvedPath)/Sources/**"],
            dependencies: dependencies,
            settings: settings
        )
    }

    static func dataTargets(
        name: String,
        bundlePrefix: String = ProjectEnvironment.bundlePrefix,
        deploymentTarget: DeploymentTargets = ProjectEnvironment.deploymentTarget,
        settings: Settings = ProjectEnvironment.projectSettings,
        dependencies: [TargetDependency] = [],
        basePath: String? = nil,
        folderName: String? = nil
    ) -> Target {
        let path = basePath ?? ""
        let folder = folderName ?? "Data"
        
        let resolvedPath = path.isEmpty ? folder : "\(path)/\(folder)"
        
        return Target.target(
            name: "\(name)Data",
            destinations: [.iPhone],
            product: .staticFramework,
            bundleId: "\(bundlePrefix).\(name)Data",
            deploymentTargets: deploymentTarget,
            infoPlist: .default,
            sources: ["\(resolvedPath)/Sources/**"],
            dependencies: dependencies,
            settings: settings
        )
    }

    static func microFeatureTargets(
        name: String,
        bundlePrefix: String = ProjectEnvironment.bundlePrefix,
        deploymentTarget: DeploymentTargets = ProjectEnvironment.deploymentTarget,
        settings: Settings = ProjectEnvironment.projectSettings,
        interfaceDependencies: [TargetDependency] = [],
        implementationDependencies: [TargetDependency] = [],
        testingDependencies: [TargetDependency] = [],
        testsDependencies: [TargetDependency] = [],
        exampleDependencies: [TargetDependency] = [],
        basePath: String? = nil,
        folderName: String? = nil
    ) -> [Target] {
        let path = basePath ?? ""
        let folder = folderName ?? ""
        let resolvedPath: String
        if path.isEmpty && folder.isEmpty {
            resolvedPath = ""
        } else if path.isEmpty {
            resolvedPath = folder
        } else if folder.isEmpty {
            resolvedPath = path
        } else {
            resolvedPath = "\(path)/\(folder)"
        }
        
        let sourcePrefix = resolvedPath.isEmpty ? "" : "\(resolvedPath)/"
        
        let interfaceTarget = Target.target(
            name: "Feature\(name)Interface",
            destinations: [.iPhone],
            product: .staticFramework,
            bundleId: "\(bundlePrefix).Feature\(name)Interface",
            deploymentTargets: deploymentTarget,
            infoPlist: .default,
            sources: ["\(sourcePrefix)Interface/Sources/**"],
            dependencies: interfaceDependencies,
            settings: settings
        )
        
        let implementationTarget = Target.target(
            name: "Feature\(name)",
            destinations: [.iPhone],
            product: .staticFramework,
            bundleId: "\(bundlePrefix).Feature\(name)",
            deploymentTargets: deploymentTarget,
            infoPlist: .default,
            sources: ["\(sourcePrefix)Sources/**"],
            dependencies: implementationDependencies + [.target(name: "Feature\(name)Interface")],
            settings: settings
        )
        
        let testingTarget = Target.target(
            name: "Feature\(name)Testing",
            destinations: [.iPhone],
            product: .staticFramework,
            bundleId: "\(bundlePrefix).Feature\(name)Testing",
            deploymentTargets: deploymentTarget,
            infoPlist: .default,
            sources: ["\(sourcePrefix)Testing/Sources/**"],
            dependencies: testingDependencies + [.target(name: "Feature\(name)Interface")],
            settings: settings
        )
        
        let testsTarget = Target.target(
            name: "Feature\(name)Tests",
            destinations: [.iPhone],
            product: .unitTests,
            bundleId: "\(bundlePrefix).Feature\(name)Tests",
            deploymentTargets: deploymentTarget,
            infoPlist: .default,
            sources: ["\(sourcePrefix)Tests/**"],
            dependencies: testsDependencies + [.target(name: "Feature\(name)"), .target(name: "Feature\(name)Testing")],
            settings: settings
        )
        
        let exampleTarget = Target.target(
            name: "Feature\(name)Example",
            destinations: [.iPhone],
            product: .app,
            bundleId: "\(bundlePrefix).Feature\(name)Example",
            deploymentTargets: deploymentTarget,
            infoPlist: .extendingDefault(with: [
                "UILaunchStoryboardName": "LaunchScreen",
                "UIApplicationSceneManifest": [
                    "UIApplicationSupportsMultipleScenes": false,
                    "UISceneConfigurations": [
                        "UIWindowSceneSessionRoleApplication": [
                            [
                                "UISceneConfigurationName": "Default Configuration",
                                "UISceneDelegateClassName": "$(PRODUCT_MODULE_NAME).SceneDelegate"
                            ]
                        ]
                    ]
                ]
            ]),
            sources: ["\(sourcePrefix)Example/Sources/**"],
            dependencies: exampleDependencies + [
                .target(name: "Feature\(name)"),
                .target(name: "Feature\(name)Interface"),
                .target(name: "Feature\(name)Testing")
            ],
            settings: settings
        )
        
        return [
            interfaceTarget,
            implementationTarget,
            testingTarget,
            testsTarget,
            exampleTarget
        ]
    }
}
