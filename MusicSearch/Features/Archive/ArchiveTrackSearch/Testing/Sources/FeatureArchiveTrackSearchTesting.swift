//
//  FeatureArchiveTrackSearchTesting.swift
//  MusicSearch
//
//  Created by Kiseok on 6/30/26.
//

import Foundation
import UIKit
import Combine
import MicroRIBs
@testable import FeatureArchiveTrackSearchInterface

@MainActor
public final class ArchiveTrackSearchBuildableMock: ArchiveTrackSearchBuildable {
	public init() {}
	public var buildCallCount = 0
	public func build(withListener listener: ArchiveTrackSearchListener) -> ArchiveTrackSearchRouting {
		buildCallCount += 1
		return ArchiveTrackSearchRoutingMock()
	}
}

@MainActor
public final class ArchiveTrackSearchRoutingMock: ViewableRouter<Interactable, ViewControllable>, ArchiveTrackSearchRouting {
	public init() {
		super.init(interactor: InteractableMock(), viewController: ViewControllableMock())
	}
}

@MainActor
public final class InteractableMock: Interactor {
    public override init() { super.init() }
}

@MainActor
public final class ViewControllableMock: UIViewController, ViewControllable {
    public init() { super.init(nibName: nil, bundle: nil) }
    public required init?(coder: NSCoder) { fatalError() }
}
