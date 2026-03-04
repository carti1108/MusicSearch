# MusicSearch 🎵

## Architecture

### Overview
이 프로젝트는 **Clean Architecture + MVVM-C** 기반으로 구성되어 있습니다.

- 역할 분리: `Presentation / Domain / Data`
- 의존성 역전: 상위 계층은 인터페이스(Protocol)에 의존
- 테스트 용이성: UseCase/Repository 중심 단위 테스트 가능 구조

### Layered Structure

- Presentation: `ViewController`, `ViewModel`, `Coordinator`
- Domain: `Entity`, `UseCase(Protocol)`, `Repository(Protocol)`
- Data: `RepositoryImpl`, `DTO`, `API(Requestable)`, `Mapper`

```swift
// Domain
public protocol SearchTracksUseCase {
	func execute(
		query: String,
		limit: Int,
		page: Int
	) async throws -> (tracks: [Track], totalResults: Int)
}

protocol TrackRepository {
	func searchTracks(
		query: String,
		limit: Int,
		page: Int
	) async throws -> (tracks: [Track], totalResults: Int)
}

// Domain Impl
final class SearchTrackUseCaseImpl: SearchTracksUseCase {
	private let trackRepository: TrackRepository

	init(trackRepository: TrackRepository) {
		self.trackRepository = trackRepository
	}

	func execute(
		query: String,
		limit: Int,
		page: Int
	) async throws -> (tracks: [Track], totalResults: Int) {
		try await self.trackRepository.searchTracks(
			query: query,
			limit: limit,
			page: page
		)
	}
}
```

### MVVM-C Communication (`Viewable` / `Listener`)

View와 ViewModel은 서로의 concrete type을 모르고, 프로토콜로만 통신합니다.

```swift
@MainActor
protocol TrackSearchViewableListener: AnyObject {
	func didUpdateSearchText(_ keyword: String)
	func didTapRetry()
	func didSelectTrack(_ track: Track)
}

@MainActor
protocol TrackSearchViewable: AnyObject {
	var listener: TrackSearchViewableListener? { get set }
	func updateTracks(_ tracks: [Track])
	func showLoading(_ isShow: Bool)
	func showError(_ message: String?)
}
```

```swift
final class TrackSearchViewModel: TrackSearchViewableListener {
	var view: TrackSearchViewable?
	weak var coordinator: TrackSearchViewCoordinatorAction?
	private let searchTracksUseCase: SearchTracksUseCase

	init(
		view: TrackSearchViewable,
		searchTracksUseCase: SearchTracksUseCase
	) {
		self.view = view
		self.searchTracksUseCase = searchTracksUseCase
		self.view?.listener = self
	}
}
```

### Coordinator Abstraction

화면 전환 공통 책임은 `Coordinating` 프로토콜과 `Coordinator` 베이스 클래스로 관리합니다.

```swift
@MainActor
protocol Coordinating: AnyObject {
	var navigationController: UINavigationController { get set }
	var childCoordinators: [Coordinating] { get set }
	func start()
}

@MainActor
class Coordinator: Coordinating {
	var navigationController: UINavigationController
	var childCoordinators: [Coordinating] = []

	init(navigationController: UINavigationController) {
		self.navigationController = navigationController
	}

	func start() {
		fatalError("start() must be overridden by subclasses")
	}
}
```

### Coordinator Responsibility

ViewModel은 화면 전환을 직접 수행하지 않고 Coordinator에 위임합니다.

```swift
@MainActor
protocol TrackSearchViewCoordinatorAction: AnyObject {
	func didSelect(_ track: Track)
}

final class TrackSearchViewModel: TrackSearchViewableListener {
	weak var coordinator: TrackSearchViewCoordinatorAction?

	func didSelectTrack(_ track: Track) {
		self.coordinator?.didSelect(track)
	}
}
```

### Dependency Injection (Component / Dependency)

객체 생성과 조립 책임은 Component가 담당합니다.

```swift
protocol HomeDependency: Dependency {
	var fetchMusicForWeatherUseCase: FetchMusicForWeatherUseCase { get }
}

final class HomeComponent<T: HomeDependency>: Component {
	typealias DependencyType = T
	private let dependency: T

	init(dependency: T) {
		self.dependency = dependency
	}

	@MainActor
	func makeWeatherRecommendationViewModel(
		view: WeatherRecommendationViewable
	) -> WeatherRecommendationViewModel {
		WeatherRecommendationViewModel(
			view: view,
			fetchMusicForWeatherUseCase: self.dependency.fetchMusicForWeatherUseCase
		)
	}
}
```
