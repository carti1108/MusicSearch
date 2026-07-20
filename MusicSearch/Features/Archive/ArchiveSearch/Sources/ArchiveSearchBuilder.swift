//
//  ArchiveSearchBuilder.swift
//  MusicSearch
//
//  Created by Kiseok on 6/30/26.
//

import Foundation
import UIKit
import SwiftUI
import ComposableArchitecture
import MicroRIBs
import FeatureArchiveSearchInterface
import ArchiveDomain

@MainActor
public protocol ArchiveSearchDependency: MicroRIBs.Dependency {
    var archiveRepository: ArchiveRepository { get }
}

final class ArchiveSearchComponent: Component<ArchiveSearchDependency> {
}

public protocol ArchiveSearchInteractable: Interactable {
    var router: ArchiveSearchRouting? { get set }
    var listener: ArchiveSearchListener? { get set }
}

public final class ArchiveSearchWrapperInteractor: Interactor, ArchiveSearchInteractable {
    public weak var router: ArchiveSearchRouting?
    public weak var listener: ArchiveSearchListener?
}

public final class ArchiveSearchHostingController: UIHostingController<ArchiveSearchView>, ViewControllable {
    public var uiviewController: UIViewController { self }
    private weak var interactor: ArchiveSearchWrapperInteractor?

    init(rootView: ArchiveSearchView, interactor: ArchiveSearchWrapperInteractor) {
        self.interactor = interactor
        super.init(rootView: rootView)
        self.view.backgroundColor = .clear
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            interactor?.listener?.archiveSearchDidTapClose()
        }
    }
}

public final class ArchiveSearchWrapperRouter: ViewableRouter<ArchiveSearchInteractable, ViewControllable>, ArchiveSearchRouting {
}

public final class ArchiveSearchBuilder: Builder<ArchiveSearchDependency>, ArchiveSearchBuildable {

    public override init(dependency: ArchiveSearchDependency) {
        super.init(dependency: dependency)
    }

    public func build(withListener listener: ArchiveSearchListener) -> ArchiveSearchRouting {
        let component = ArchiveSearchComponent(dependency: dependency)

        let interactor = ArchiveSearchWrapperInteractor()
        interactor.listener = listener

        let store = Store(initialState: ArchiveSearchFeature.State()) {
            ArchiveSearchFeature(archiveRepository: component.dependency.archiveRepository)
        }

        let view = ArchiveSearchView(store: store)
        let viewController = ArchiveSearchHostingController(rootView: view, interactor: interactor)

        let router = ArchiveSearchWrapperRouter(
            interactor: interactor,
            viewController: viewController
        )
        interactor.router = router

        return router
    }
}
