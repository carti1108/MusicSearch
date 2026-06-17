import Foundation
import MicroRIBs
import FeatureAddArchive

@MainActor
public final class MockAddArchiveRouting: AddArchiveRouting {
	public var interactable: Interactable {
		get { fatalError() }
		set { fatalError() }
	}
	public var children: [Routing] = []
	public var lifecycle: MicroRIBs.Observable<RouterLifecycle> {
		get { fatalError() }
	}

	public init() {}

	public func load() {}
	public func attachChild(_ child: Routing) {}
	public func detachChild(_ child: Routing) {}
}
