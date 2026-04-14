# RIBs 가이드

## 1. RIBs 설명

Uber가 큰 모바일 앱을 여러 명이 동시에 개발할 때 생기는 구조적 문제를 해결하기 위해 만든 아키텍처.

- 테스트하기 쉽고 서로 고립된 단위로 기능을 쪼갤 것
- 화면 트리보다 비즈니스 로직 트리를 중심으로 앱을 설계할 것
- 전역 상태를 줄이고, 각 기능이 자기 상태를 자기 스코프 안에서 관리할 것
- 부모와 자식 사이의 요구사항을 명시적인 계약으로 드러낼 것
- Builder, Interactor, Router처럼 책임이 분리된 객체들로 기능을 조립할 것
- 큰 팀에서도 유지 가능한 구조와 tooling을 전제로 설계할 것

RIBs는 화면 전환 패턴이 아니라, 기능을 트리로 나누고 각 노드의 책임과 생명주기를 명확하게 통제하기 위한 아키텍처.

## 2. 코어 메커니즘 상세 및 코드 분석

RIBs의 핵심 구성 요소는 `Router`, `Interactor`, `Builder`.

### Builder

RIB을 조립하는 객체. View, Interactor, Router를 만들고, 필요한 경우 자식 Builder도 연결. DI를 가장 직접적으로 아는 객체.

`RootBuilder`는 Root RIB를 조립하면서 자식 feature builder도 같이 주입.

<details>
<summary><code>RootBuilder</code> 예시</summary>

```swift
@MainActor
final class RootBuilder: Builder<RootDependency>, RootBuildable {
	override init(dependency: RootDependency) {
		super.init(dependency: dependency)
	}

	func build() -> LaunchRouting {
		MainActor.assumeIsolated {
			let component = RootComponent(dependency: self.dependency)
			let viewController = RootViewController()
			let interactor = RootInteractor(presenter: viewController)

			return RootRouter(
				interactor: interactor,
				viewController: viewController,
				weatherRecommendationBuilder: component.weatherRecommendationBuilder,
				trackSearchBuilder: component.trackSearchBuilder,
				chartBuilder: component.chartBuilder
			)
		}
	}
}
```

</details>

- RIB 조립 책임이 Builder에만 모여 있음.
- Interactor는 child builder를 모르고, 조립 세부사항에 관여하지 않음.
- Router는 이미 조립된 builder를 받아 attach 책임에만 집중.

### Interactor

Interactor는 비즈니스 로직과 상태를 담당, 사용자 입력을 받고, 필요하면 Router에 화면 흐름을 요청.

`TrackSearchInteractor`는 검색 입력, debounce, 검색 상태, pagination, 선택 이벤트를 관리.

<details>
<summary><code>TrackSearchInteractor</code> 예시</summary>

```swift
@MainActor
final class TrackSearchInteractor:
	PresentableInteractor<TrackSearchPresentable>,
	TrackSearchInteractable,
	TrackSearchPresentableListener
{
	weak var router: TrackSearchRouting?
	weak var listener: TrackSearchListener?

	private let searchSubject: PassthroughSubject<String, Never> = .init()
	private var cancellables: Set<AnyCancellable> = .init()

	private var currentTracks: [Track] = []
	private var currentPage: Int = 1
	private var totalResults: Int = 0
	private var isLoading: Bool = false

	func didUpdateSearchText(_ keyword: String) {
		self.searchSubject.send(keyword)
	}

	func didSelectTrack(_ track: Track) {
		self.router?.attachMusicDigging(seedTrack: track)
	}
}
```

</details>

- View는 입력만 전달.
- 검색 상태는 Interactor가 소유.
- 자식 화면 이동은 Interactor가 직접 push 하지 않고 Router에 위임.

### Router

Router는 attach / detach 와 화면 전환을 담당. 복잡한 비즈니스 판단은 Interactor에 두고, Router는 자식 RIB의 생명주기와 네비게이션 반영에 집중.

`TrackSearchRouter`는 `MusicDigging` child를 attach 하고, 네비게이션 pop 이후 detach 까지 책임.

<details>
<summary><code>TrackSearchRouter</code> 예시</summary>

```swift
@MainActor
final class TrackSearchRouter: ViewableRouter<TrackSearchInteractable, TrackSearchViewControllable>, TrackSearchRouting {
	private let navigationController: UINavigationController
	private let musicDiggingBuilder: MusicDiggingBuildable
	private var childRoutersByViewControllerID: [ObjectIdentifier: Routing] = [:]

	func attachMusicDigging(seedTrack: Track) {
		let musicDiggingRouter = self.musicDiggingBuilder.build(
			withListener: self.interactor,
			seedTrack: seedTrack
		)
		self.attachChild(musicDiggingRouter)

		let viewController = musicDiggingRouter.viewControllable.uiViewController
		self.childRoutersByViewControllerID[ObjectIdentifier(viewController)] = musicDiggingRouter
		self.navigationController.pushViewController(viewController, animated: true)
	}

	private func detachPoppedChildrenIfNeeded() {
		let visibleViewControllerIDs = Set(self.navigationController.viewControllers.map { ObjectIdentifier($0) })
		let poppedIDs = self.childRoutersByViewControllerID.keys.filter { !visibleViewControllerIDs.contains($0) }

		for poppedID in poppedIDs {
			guard let childRouter = self.childRoutersByViewControllerID[poppedID] else { continue }
			self.detachChild(childRouter)
			self.childRoutersByViewControllerID[poppedID] = nil
		}
	}
}
```

</details>

- 화면 전환과 child lifecycle을 같이 관리.
- 화면 stack과 router tree의 정합성을 유지.

## 3. 의존성 관리

RIBs의 의존성 관리는 `Dependency`와 `Component`를 활용.

### Dependency

`Dependency`는 어떤 RIB가 부모에게 요구하는 최소 계약. "무엇이 필요한가"를 드러내는 인터페이스.

예를 들어 `TrackSearch`는 검색, 태그 기반 조회, 유사곡 조회, 딥링크 생성 기능이 필요하다는 것을 `TrackSearchDependency`로 선언.

<details>
<summary><code>TrackSearchDependency</code> 예시</summary>

```swift
@MainActor
protocol TrackSearchDependency: Dependency {
	var searchTracksUseCase: SearchTracksUseCase { get }
	var fetchTracksByTagUseCase: FetchTracksByTagUseCase { get }
	var fetchSimilarTrackUseCase: FetchSimilarTracksUseCase { get }
	var fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase { get }
}
```

</details>

child는 필요한 계약만 선언하고, 실제 구현은 부모 스코프가 채움.

### Component

`Component`는 부모 dependency를 받아 현재 스코프에서 필요한 객체를 노출하고, 자식에게 필요한 dependency를 이어주는 객체.

`TrackSearchComponent`는 `TrackSearchDependency`를 그대로 노출하면서 동시에 `MusicDiggingDependency`도 만족시켜야 함. 즉 `TrackSearch` 스코프 안에서 child인 `MusicDigging`이 필요한 의존성을 전달하는 역할.

<details>
<summary><code>TrackSearchComponent</code> 예시</summary>

```swift
@MainActor
final class TrackSearchComponent: Component<TrackSearchDependency>, TrackSearchDependency, MusicDiggingDependency {
	var searchTracksUseCase: SearchTracksUseCase {
		self.dependency.searchTracksUseCase
	}

	var fetchTracksByTagUseCase: FetchTracksByTagUseCase {
		self.dependency.fetchTracksByTagUseCase
	}

	var fetchSimilarTrackUseCase: FetchSimilarTracksUseCase {
		self.dependency.fetchSimilarTrackUseCase
	}

	var fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase {
		self.dependency.fetchMusicAppDeepLinkUseCase
	}
}
```

</details>

### AppComponent와 RootComponent의 역할

이 프로젝트에서 의존성 주입의 시작점은 `AppComponent`. 이 객체는 앱 전역에서 공유될 수 있는 객체 생성을 담당하는 composition root 역할.

<details>
<summary><code>AppComponent</code> 예시</summary>

```swift
final class AppComponent {
	let networkManager: NetworkRequesting
	let locationManager: LocationManaging
	let weatherAPIConfiguration: WeatherAPIConfiguration

	var trackRepository: TrackRepository {
		TrackRepositoryImpl(networkManager: self.networkManager)
	}

	var fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase {
		self.fetchMusicAppDeepLinkUseCaseInstance
	}
}

extension AppComponent: TrackSearchDependency {
	var searchTracksUseCase: any SearchTracksUseCase {
		SearchTracksUseCaseImpl(trackRepository: self.trackRepository)
	}
}
```

</details>

`RootComponent`는 `AppComponent`가 제공하는 dependency를 받아 실제 feature builder를 만들고 child RIB로 넘김.

<details>
<summary><code>RootComponent</code> 예시</summary>

```swift
@MainActor
final class RootComponent: Component<RootDependency>, WeatherRecommendationDependency, TrackSearchDependency, ChartDependency {
	var weatherRecommendationBuilder: WeatherRecommendationBuildable {
		WeatherRecommendationBuilder(dependency: self)
	}

	var trackSearchBuilder: TrackSearchBuildable {
		TrackSearchBuilder(dependency: self)
	}

	var chartBuilder: ChartBuildable {
		ChartBuilder(dependency: self)
	}
}
```

</details>

- `Dependency`는 각 RIB가 필요한 요구사항을 드러냄.
- `Component`는 parent scope에서 child scope로 의존성을 전달하는 역할을 수행.

## 4. 데이터 흐름 및 상태 관리

기본 흐름은 `View -> Interactor -> Router`.

### View -> Interactor

View는 사용자 이벤트를 listener를 통해 Interactor로 전달.

`TrackSearchViewController`는 유저 이벤트를 직접 처리하지 않고 `listener`에게 넘김.

<details>
<summary><code>TrackSearchViewController</code> 이벤트 전달 예시</summary>

```swift
func updateSearchResults(for searchController: UISearchController) {
	guard let text = searchController.searchBar.text else { return }
	self.listener?.didUpdateSearchText(text)
}

func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
	collectionView.deselectItem(at: indexPath, animated: true)
	guard let track = self.dataSource.itemIdentifier(for: indexPath) else { return }
	self.listener?.didSelectTrack(track)
}
```

</details>

### Interactor -> View

Interactor는 presenter 프로토콜을 통해 View 상태를 갱신. 검색 결과, 로딩, 에러 모두 Interactor가 결정하고 View는 반영만 함.

<details>
<summary><code>TrackSearchInteractor</code> 상태 반영 예시</summary>

```swift
private func performSearch(keyword: String) {
	self.presenter.showLoading(true)
	self.presenter.showError(nil)

	self.searchTask = Task { [weak self] in
		guard let self else { return }

		do {
			let result = try await self.searchTracksUseCase.execute(
				query: keyword,
				limit: self.limit,
				page: 1
			)
			guard !Task.isCancelled else { return }

			self.currentTracks = result.tracks
			self.totalResults = result.totalResults
			self.currentPage = 1
			self.presenter.updateTracks(self.currentTracks)
		} catch {
			self.presenter.updateTracks([])
			self.presenter.showError("검색 중 오류가 발생했습니다.")
		}
	}
}
```

</details>

### Interactor -> Router

Interactor는 화면 전환 시 Router에 요청. 실제 attach / detach / push 는 Router가 담당.

<details>
<summary><code>TrackSearchInteractor -> TrackSearchRouter</code> 예시</summary>

```swift
func didSelectTrack(_ track: Track) {
	self.router?.attachMusicDigging(seedTrack: track)
}
```

</details>

### RIB 간 통신 방법

RIB 간 통신은 크게 두 단계.

- 부모가 child를 만들 때 `withListener:`로 상위 Interactor를 넘김.
- child는 listener 프로토콜에만 의존하고, 부모 concrete type은 모름.

`RootInteractor`는 각 feature listener를 채택하고 있고, `RootRouter`는 child builder에 `self.interactor`를 넘김.

<details>
<summary><code>RootInteractor</code> 와 listener 연결 예시</summary>

```swift
@MainActor
final class RootInteractor: PresentableInteractor<RootPresentable>, RootInteractable, RootPresentableListener {
	weak var router: RootRouting?
	weak var listener: RootListener?
}

extension RootInteractor: WeatherRecommendationListener {}
extension RootInteractor: TrackSearchListener {}
extension RootInteractor: ChartListener {}
```

</details>

<details>
<summary><code>RootRouter</code> 에서 child listener 연결 예시</summary>

```swift
override func didLoad() {
	super.didLoad()

	let weatherRecommendationRouter = self.weatherRecommendationBuilder.build(withListener: self.interactor)
	self.attachChild(weatherRecommendationRouter)

	let trackSearchNavigationController = UINavigationController()
	let trackSearchRouter = self.trackSearchBuilder.build(
		withListener: self.interactor,
		navigationController: trackSearchNavigationController
	)
	self.attachChild(trackSearchRouter)

	let chartRouter = self.chartBuilder.build(withListener: self.interactor)
	self.attachChild(chartRouter)
}
```

</details>

## 5. 테스트 전략

- `Core`: UseCase, Repository, DTO, TestHelpers
- `Features`: RIB 단위 테스트

### Interactor 테스트

Interactor 테스트는 비즈니스 규칙과 상태 반응을 검증.

`TrackSearchInteractorTests`는 검색 입력 후 presenter 반영과 트랙 선택 시 라우팅 요청을 검증한다.

<details>
<summary><code>TrackSearchInteractorTests</code> 예시</summary>

```swift
@MainActor
struct TrackSearchInteractorTests {
	@Test("검색어 입력 후 검색 결과를 presenter에 반영하는가")
	func didUpdateSearchTextUpdatesPresenter() async throws {
		let expectedTracks = [
			Track(title: "Hysteria", artist: "Muse", imageURL: nil),
			Track(title: "Plug In Baby", artist: "Muse", imageURL: nil)
		]
		self.mockUseCase.result = (expectedTracks, 2)

		let interactor = TrackSearchInteractor(
			presenter: self.presenter,
			debounceSeconds: 0.01,
			searchTracksUseCase: self.mockUseCase
		)

		interactor.didUpdateSearchText("Muse")
		try? await Task.sleep(for: .milliseconds(100))

		#expect(self.mockUseCase.executeCallCount == 1)
		#expect(self.presenter.updatedTracksHistory.last?.map(\.title) == ["Hysteria", "Plug In Baby"])
	}
}
```

</details>

- ViewController나 실제 네트워크 없이 Interactor의 행동만 확인.
- 검색 입력이 어떤 effect를 만드는지만 검증.
- child RIB 구현을 몰라도 됨.

### Router 테스트

Router 테스트는 attach / detach 와 child lifecycle 정합성을 검증.

`TrackSearchRouterTests`는 `MusicDigging` child attach 와 pop 이후 detach 를 검증.

<details>
<summary><code>TrackSearchRouterTests</code> 예시</summary>

```swift
@MainActor
struct TrackSearchRouterTests {
	@Test("attachMusicDigging 호출 시 child router를 붙이고 화면을 push하는가")
	func attachMusicDiggingPushesChildViewController() {
		let interactor = TrackSearchInteractor(
			presenter: presenter,
			searchTracksUseCase: useCase
		)
		let router = TrackSearchRouter(
			interactor: interactor,
			viewController: rootViewController,
			navigationController: navigationController,
			musicDiggingBuilder: musicDiggingBuilder
		)
		router.load()

		router.attachMusicDigging(seedTrack: seedTrack)

		#expect(router.children.count == 1)
		#expect(navigationController.topViewController === musicDiggingBuilder.router.viewControllable.uiViewController)
	}
}
```

</details>

### Builder 테스트

Builder 테스트는 조립이 빠지지 않았는지 확인하는 용도.

- 올바른 Router 타입을 만드는가
- Interactor와 ViewController를 제대로 연결하는가
- listener wiring 이 빠지지 않았는가

<details>
<summary><code>WeatherRecommendationBuilderTests</code> 예시</summary>

```swift
@MainActor
struct WeatherRecommendationBuilderTests {
	@Test("build 시 listener와 presenter가 정상 연결되고 의존성이 주입되는가")
	func buildWiresListenerPresenterAndDependencies() async {
		let dependency = MockWeatherRecommendationDependency(
			fetchMusicForWeatherUseCase: fetchMusicForWeatherUseCase,
			fetchMusicAppDeepLinkUseCase: fetchMusicAppDeepLinkUseCase
		)
		let builder = WeatherRecommendationBuilder(dependency: dependency)
		let listener = MockWeatherRecommendationListener()

		let routing = builder.build(withListener: listener)

		guard let router = routing as? WeatherRecommendationRouter else { return }
		guard let interactor = router.interactor as? WeatherRecommendationInteractor else { return }
		guard let viewController = router.viewControllable as? WeatherRecommendationViewController else { return }

		#expect(interactor.listener === listener)
		#expect(viewController.listener === interactor)
	}
}
```

</details>

## 출처

- [Uber RIBs Wiki](https://github.com/uber/RIBs/wiki)
- [Uber RIBs README](https://github.com/uber/RIBs)
