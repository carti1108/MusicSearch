import Foundation
import MicroRIBs
@testable import FeatureArchiveTrackSearchInterface

public final class ArchiveTrackSearchBuildableMock: ArchiveTrackSearchBuildable {
	public init() {}
	public var buildCallCount = 0
	public func build(withListener listener: ArchiveTrackSearchListener) -> ArchiveTrackSearchRouting {
		buildCallCount += 1
		return ArchiveTrackSearchRoutingMock()
	}
}

public final class ArchiveTrackSearchRoutingMock: ViewableRouting {
	public var interactable: Interactable { InteractableMock() }
	public var children: [Routing] = []
	public var viewControllable: ViewControllable { ViewControllableMock() }
	public init() {}
	public func load() {}
	public func attachChild(_ child: Routing) {}
	public func detachChild(_ child: Routing) {}
	public var lifecycle: Observable<RouterLifecycle> { .empty() }
}
