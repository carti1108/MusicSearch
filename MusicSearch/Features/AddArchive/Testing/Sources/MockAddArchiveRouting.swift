import Foundation
import MicroRIBs
import FeatureAddArchiveInterface
import MSDomain
import TrackSearchDomain

@MainActor
public final class MockAddArchiveRouting: AddArchiveRouting {
	public var viewControllable: ViewControllable {
		get { fatalError() }
	}
	public var interactable: Interactable {
		get { fatalError() }
		set { fatalError() }
	}
	public var children: [Routing] = []
	public var lifecycle: AsyncStream<RouterLifecycle> {
		AsyncStream { _ in }
	}

	public init() {}

	public func load() {}
	public func attachChild(_ child: Routing) {}
	public func detachChild(_ child: Routing) {}
	
	public var routeToSearchCallCount = 0
	public var routeToSearchSearchTracksUseCase: SearchTracksUseCase?
	public var routeToSearchOnSelect: ((Track) -> Void)?
	public func routeToSearch(searchTracksUseCase: SearchTracksUseCase, onSelect: @escaping (Track) -> Void) {
		routeToSearchCallCount += 1
		routeToSearchSearchTracksUseCase = searchTracksUseCase
		routeToSearchOnSelect = onSelect
	}
}
