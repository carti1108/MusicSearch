import ProjectDescription

let nameAttribute: Template.Attribute = .required("name")

let template = Template(
    description: "A template for a new MicroFeature module",
    attributes: [
        nameAttribute,
    ],
    items: [
        .file(
            path: "MusicSearch/Features/\(nameAttribute)/Interface/Sources/Feature\(nameAttribute)Interface.swift",
            templatePath: "Interface.stencil"
        ),
        .file(
            path: "MusicSearch/Features/\(nameAttribute)/Sources/Feature\(nameAttribute).swift",
            templatePath: "Implementation.stencil"
        ),
        .file(
            path: "MusicSearch/Features/\(nameAttribute)/Testing/Sources/Feature\(nameAttribute)Testing.swift",
            templatePath: "Testing.stencil"
        ),
        .file(
            path: "MusicSearch/Features/\(nameAttribute)/Tests/Sources/Feature\(nameAttribute)Tests.swift",
            templatePath: "Tests.stencil"
        ),
        .file(
            path: "MusicSearch/Features/\(nameAttribute)/Example/Sources/AppDelegate.swift",
            templatePath: "AppDelegate.stencil"
        ),
        .file(
            path: "MusicSearch/Features/\(nameAttribute)/Example/Sources/SceneDelegate.swift",
            templatePath: "SceneDelegate.stencil"
        )
    ]
)
