# RIBs 가이드

`MusicSearch`의 현재 구조를 기준으로 `RIBs` 설계와 사용 방식을 정리한 문서.

## 기준 프로젝트

- App: `MusicSearch`
- UI Stack: `UIKit`
- Architecture: `RIBs` 스타일 구조
- Async Stack: `Swift Concurrency`, 일부 입력 제어는 `Combine`

---

## 1. RIBs 철학

RIBs의 초점은 화면 분할보다 기능 트리와 생명주기 관리.  
관심사의 중심은 상태 저장 위치보다 조립 주체, 플로우 소유자, 자식 정리 책임.

`MusicSearch` 기준 RIB 트리 구조는 아래 형태.

```text
App Launch
└── Root RIB
    ├── Builder: RootBuilder
    ├── Interactor: RootInteractor
    ├── Router: RootRouter
    ├── View: RootViewController
    ├── Child: Home RIB
    │   ├── Builder: HomeBuilder
    │   ├── Interactor: HomeInteractor
    │   ├── Router: HomeRouter
    │   └── View: WeatherRecommendationViewController
    ├── Child: TrackSearch RIB
    │   ├── Builder: TrackSearchBuilder
    │   ├── Interactor: TrackSearchInteractor
    │   ├── Router: TrackSearchRouter
    │   ├── View: TrackSearchViewController
    │   └── Child: MusicDigging RIB
    │       ├── Builder: MusicDiggingBuilder
    │       ├── Interactor: MusicDiggingInteractor
    │       ├── Router: MusicDiggingRouter
    │       └── View: MusicDiggingViewController
    └── Child: Trend RIB
        ├── Builder: TrendBuilder
        ├── Interactor: TrendInteractor
        ├── Router: TrendRouter
        └── View: ChartViewController
```

파일 기준으로 보면 아래 대응 관계.

```text
MusicSearch/App/Sources
├── SceneDelegate.swift
└── Root
    ├── RootBuilder.swift
    ├── RootInteractor.swift
    ├── RootRouter.swift
    └── RootViewController.swift

MusicSearch/Features/Home
├── HomeBuilder.swift
├── HomeInteractor.swift
├── HomeRouter.swift
└── Views/WeatherRecommendationViewController.swift

MusicSearch/Features/Digging/Search
├── TrackSearchBuilder.swift
├── TrackSearchInteractor.swift
├── TrackSearchRouter.swift
└── Views/TrackSearchViewController.swift

MusicSearch/Features/Digging/MusicDigging
├── MusicDiggingBuilder.swift
├── MusicDiggingInteractor.swift
├── MusicDiggingRouter.swift
└── Views/MusicDiggingViewController.swift

MusicSearch/Features/Trend
├── TrendBuilder.swift
├── TrendInteractor.swift
├── TrendRouter.swift
└── Views/ChartViewController.swift
```

이 구조의 의미는 다음과 같음.

- 탭 하나 = 독립적인 feature subtree
- 부모 RIB = 자식 feature의 생성과 소멸 책임
- Interactor = 비즈니스 흐름과 상태 소유
- Router = 화면 전환과 attach/detach 소유

`Root`에서 탭 구조를 조립하는 코드.

```swift
final class RootRouter: LaunchRouter<RootInteractable, RootViewControllable>, RootRouting {
	private let homeBuilder: HomeBuildable
	private let trackSearchBuilder: TrackSearchBuildable
	private let trendBuilder: TrendBuildable

	override func didLoad() {
		super.didLoad()

		let homeRouter = self.homeBuilder.build(withListener: self.interactor)
		self.attachChild(homeRouter)

		let homeNavigationController = UINavigationController(
			rootViewController: homeRouter.viewControllable.uiViewController
		)

		let trackSearchNavigationController = UINavigationController()
		let trackSearchRouter = self.trackSearchBuilder.build(
			withListener: self.interactor,
			navigationController: trackSearchNavigationController
		)
		self.attachChild(trackSearchRouter)

		let trendRouter = self.trendBuilder.build(withListener: self.interactor)
		self.attachChild(trendRouter)

		let trendNavigationController = UINavigationController(
			rootViewController: trendRouter.viewControllable.uiViewController
		)

		self.viewController.setTabs([
			homeNavigationController,
			trackSearchNavigationController,
			trendNavigationController
		])
	}
}
```

---

## 2. RIBs 각 객체의 역할

### Builder

객체 생성과 의존성 조립 담당.  
`ViewController`, `Interactor`, `Router`, 하위 `Builder` 연결 지점.

```swift
final class RootBuilder: Builder<RootDependency>, RootBuildable {
	func build() -> LaunchRouting {
		MainActor.assumeIsolated {
			let component = RootComponent(dependency: self.dependency)
			let viewController = RootViewController()
			let interactor = RootInteractor(presenter: viewController)

			return RootRouter(
				interactor: interactor,
				viewController: viewController,
				homeBuilder: component.homeBuilder,
				trackSearchBuilder: component.trackSearchBuilder,
				trendBuilder: component.trendBuilder
			)
		}
	}
}
```

### Dependency / Component

`Dependency`는 상위에서 제공받아야 하는 계약.  
`Component`는 실제 구현체 노출과 하위 feature 전달 창구.

```swift
protocol RootDependency: Dependency, HomeDependency, DiggingDependency, TrendDependency {}

final class RootComponent: Component<RootDependency>, HomeDependency, DiggingDependency, TrendDependency {
	var fetchMusicForWeatherUseCase: any FetchMusicForWeatherUseCase {
		self.dependency.fetchMusicForWeatherUseCase
	}

	var trackSearchBuilder: TrackSearchBuildable {
		TrackSearchBuilder(dependency: self)
	}
}
```

### Interactor

비즈니스 로직, 사용자 의도, feature 상태 담당.  
화면 전환을 직접 수행하지 않고 Router에 요청 전달.

```swift
final class TrackSearchInteractor:
	PresentableInteractor<TrackSearchPresentable>,
	TrackSearchInteractable,
	TrackSearchPresentableListener
{
	weak var router: TrackSearchRouting?

	func didSelectTrack(_ track: Track) {
		self.router?.attachMusicDigging(seedTrack: track)
	}
}
```

### Router

플로우 제어, 자식 RIB attach/detach, 화면 전환 담당.  
RIBs에서 `push`보다 더 중요한 지점은 attach/detach 정합성.

```swift
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
```

### Presentable / ViewController

View는 가능한 한 수동적인 인터페이스 계층.  
입력 전달은 `listener`, 화면 반영은 `presentable` 메서드.

```swift
@MainActor
protocol TrackSearchPresentableListener: AnyObject {
	func didUpdateSearchText(_ keyword: String)
	func didTapRetry()
	func didSelectTrack(_ track: Track)
	func didReachListBottom()
}

@MainActor
protocol TrackSearchPresentable: Presentable {
	var listener: TrackSearchPresentableListener? { get set }
	func updateTracks(_ tracks: [Track])
	func showLoading(_ isShow: Bool)
	func showError(_ message: String?)
}
```

### Listener

부모-자식 간 이벤트 통로.  
자식이 부모 concrete type을 모른 채 상위 플로우에 신호 전달하는 용도.

```swift
protocol RootInteractable: Interactable, HomeListener, TrackSearchListener, TrendListener {
	var router: RootRouting? { get set }
	var listener: RootListener? { get set }
}
```

---

## 3. 사용법: 각 RIB 소통 방식

### 3-1. View -> Interactor

사용자 입력 전달 경로는 `PresentableListener`.

```swift
func didUpdateSearchText(_ keyword: String) {
	self.searchSubject.send(keyword)
}
```

### 3-2. Interactor -> View

Interactor는 presenter 프로토콜만 의존.  
UIKit 구체 타입 직접 의존 회피.

```swift
self.presenter.updateTracks(self.currentTracks)
self.presenter.showLoading(false)
self.presenter.showError(nil)
```

### 3-3. Parent -> Child

부모가 child builder 호출.  
초기 진입 데이터는 `build(...)` 인자로 전달.

```swift
let musicDiggingRouter = self.musicDiggingBuilder.build(
	withListener: self.interactor,
	seedTrack: seedTrack
)
```

### 3-4. Child -> Parent

부모와의 이벤트 연결 방식은 `Listener`.  
현재 `MusicSearch`에서는 marker protocol 비중이 크지만, 구조적으로는 아래 형태 확장 가능.

```swift
protocol MusicDiggingListener: AnyObject {
	func musicDiggingDidFinish()
	func musicDiggingDidRequestPlay(_ track: Track)
}
```

### 3-5. Interactor -> Router

화면 이동 결정은 Interactor가 트리거하고, 실제 전환은 Router가 수행.

```swift
func didSelectTrack(_ track: Track) {
	self.router?.attachMusicDigging(seedTrack: track)
}
```

### 3-6. Router -> Navigation / Window

실제 `push`, `tab`, `launch` 수행 주체는 Router.

```swift
override func didLoad() {
	super.didLoad()

	let trackSearchNavigationController = UINavigationController()
	let trackSearchRouter = self.trackSearchBuilder.build(
		withListener: self.interactor,
		navigationController: trackSearchNavigationController
	)
	self.attachChild(trackSearchRouter)
}
```

소통 구조 요약.

```text
View -> Interactor -> Router
View <- Interactor
Parent Builder -> Child Builder
Child Interactor -> Parent Listener
```

---

## 4. 구현 방식

### 1. 앱 시작과 Root RIB 조립

앱 시작 시점의 책임 분리는 다음 기준.

- `SceneDelegate`: window 준비
- `AppComponent`: 전역 의존성 준비
- `RootBuilder`: Root RIB 조립
- `LaunchRouter`: 최초 화면 연결

```swift
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	var window: UIWindow?
	private var launchRouter: LaunchRouting?

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let windowScene = (scene as? UIWindowScene) else { return }

		let window = UIWindow(windowScene: windowScene)
		let appComponent = AppComponent()
		let rootBuilder = RootBuilder(dependency: appComponent)
		let launchRouter = rootBuilder.build()
		launchRouter.launch(from: window)

		self.launchRouter = launchRouter
		self.window = window
	}
}
```

### 2. 리스트 셀 탭 후 상세 화면 이동

처리 순서는 다음 구조.

1. View에서 선택 이벤트 발생
2. Interactor에서 선택 의미 해석
3. Router에 child attach 요청
4. Router에서 push 수행

```swift
func didSelectTrack(_ track: Track) {
	self.router?.attachMusicDigging(seedTrack: track)
}
```

```swift
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
```

### 3. 다음 화면에 데이터 전달

초기 진입 필수 데이터는 Builder 단계 전달 방식.  
`MusicDigging`의 seed track이 대표 예시.

```swift
init(
	seedTrack: Track,
	presenter: MusicDiggingPresentable,
	fetchSimilarTracksUseCase: FetchSimilarTracksUseCase,
	fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase
) {
	self.currentSeedTrack = seedTrack
	self.fetchSimilarTracksUseCase = fetchSimilarTracksUseCase
	self.fetchMusicAppDeepLinkUseCase = fetchMusicAppDeepLinkUseCase
	super.init(presenter: presenter)
	presenter.listener = self
}
```

적용 기준.

- 화면 진입 전 반드시 필요한 값: `build(...)` 또는 `init(...)`
- 진입 후 바뀌는 상태: `Interactor` 내부 상태

### 4. iOS 기본 백 버튼으로 pop된 뒤 자식 정리

RIBs에서 핵심 관리 포인트 중 하나.  
화면 pop 이후 child router detach 누락 시 subtree 생명주기 불일치 가능성.

`TrackSearchRouter`는 `UINavigationControllerDelegate`를 통해 pop 이후 child 정리 수행.

```swift
private final class NavigationDelegateProxy: NSObject, UINavigationControllerDelegate {
	weak var router: TrackSearchRouter?

	func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
		self.router?.detachPoppedChildrenIfNeeded()
	}
}
```

```swift
private func detachPoppedChildrenIfNeeded() {
	let visibleViewControllerIDs = Set(self.navigationController.viewControllers.map { ObjectIdentifier($0) })
	let poppedIDs = self.childRoutersByViewControllerID.keys.filter { !visibleViewControllerIDs.contains($0) }

	for poppedID in poppedIDs {
		guard let childRouter = self.childRoutersByViewControllerID[poppedID] else { continue }
		self.detachChild(childRouter)
		self.childRoutersByViewControllerID[poppedID] = nil
	}
}
```

정리 기준.

- push 시 `attachChild`
- pop 확인 시 `detachChild`
- 화면 stack과 router tree의 동기화 유지

### 5. 외부 앱 딥링크 오픈

앱 내부 화면 이동과 외부 앱 호출의 책임 분리 필요.

- 앱 내부 이동: Router
- 외부 앱 오픈 전 비즈니스 판단: Interactor

`HomeInteractor`의 Spotify 딥링크 오픈 예시.

```swift
func didSelectTrack(at index: Int) {
	guard index < self.currentTracks.count else { return }
	self.openMusicApp(for: self.currentTracks[index])
}

private func openMusicApp(for track: Track) {
	Task {
		guard let url = await self.fetchMusicAppDeepLinkUseCase.execute(track: track) else { return }
		await MainActor.run {
			UIApplication.shared.open(url)
		}
	}
}
```

`MusicDiggingInteractor`도 동일 패턴 사용.

```swift
func didTapSeedTrack() {
	self.openMusicApp(for: self.currentSeedTrack)
}
```

### 6. 검색, debounce, retry, pagination

입력 제어와 요청 상태 관리는 Interactor 책임 영역.  
`TrackSearchInteractor`가 대표 사례.

```swift
private func bindSearchInput() {
	self.searchSubject
		.removeDuplicates()
		.debounce(for: .seconds(self.debounceSeconds), scheduler: DispatchQueue.main)
		.sink { [weak self] keyword in
			self?.performSearch(keyword: keyword)
		}
		.store(in: &self.cancellables)
}
```

```swift
private func performSearch(keyword: String) {
	self.searchTask?.cancel()
	self.loadMoreTask?.cancel()
	self.isLoading = true

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
		} catch is CancellationError {
			return
		} catch {
			self.presenter.updateTracks([])
			self.presenter.showError("검색 중 오류가 발생했습니다.")
		}
	}
}
```

---

## 5. 테스트 코드 작성

### 5-1. Interactor 테스트

검증 대상.

- 입력 이벤트 수신 후 use case 호출 여부
- 성공/실패 시 presenter 호출 형태
- 라우팅 이벤트 발생 여부
- 내부 상태 변경 여부

`TrackSearchInteractor` 테스트 예시 형태.

```swift
@MainActor
@Test("트랙 선택 시 MusicDigging attach 요청")
func didSelectTrack_routesToMusicDigging() async {
	let presenter = TrackSearchPresentableSpy()
	let router = TrackSearchRoutingSpy()
	let useCase = SearchTracksUseCaseStub()

	let interactor = TrackSearchInteractor(
		presenter: presenter,
		searchTracksUseCase: useCase
	)
	interactor.router = router

	let track = Track(title: "Song", artist: "Artist", imageURL: nil)
	interactor.didSelectTrack(track)

	#expect(router.attachedSeedTrack?.title == "Song")
}
```

필수 대역.

- `Presenter Spy`
- `Router Spy`
- `UseCase Stub`

### 5-2. Router 테스트

검증 대상.

- child attach 이후 `children` 반영 여부
- attach 시 child interactor activate 여부
- detach 시 child 제거 여부
- navigation pop 후 subtree 정리 여부

예시 형태.

```swift
@MainActor
@Test("attachChild 후 자식 활성화와 children 반영")
func attachChild_activatesChild() {
	let parentInteractor = MockInteractable()
	let parentRouter = TestRouter(interactor: parentInteractor)

	let childInteractor = MockInteractable()
	let childRouter = TestRouter(interactor: childInteractor)

	parentRouter.attachChild(childRouter)

	#expect(parentRouter.children.count == 1)
	#expect(childInteractor.activateCallCount == 1)
}
```

### 5-3. Builder 테스트

Builder 테스트의 초점은 조립 누락 방지.

- listener 연결 누락 여부
- dependency 주입 누락 여부
- 반환 router 타입 적합성

### 5-4. 테스트 작성 체크리스트

- 도메인 규칙은 가장 먼저 고정
- Interactor는 행동 계약 중심 테스트
- Router는 생명주기와 트리 정합성 중심 테스트
- Builder는 조립 검증 정도로 제한
- ViewController 테스트는 복잡한 UI 상호작용이 있을 때만 추가

---

## 6. 요약

`MusicSearch`에서 RIBs의 역할은 feature를 트리로 조립하고, 화면 이동과 생명주기를 Router 중심으로 관리하는 구조 제공.

정리 포인트는 아래 네 가지.

- Root에서 feature subtree 조립
- Builder / Dependency / Component 기반 의존성 주입
- Interactor 중심 비즈니스 로직 관리
- Router 중심 attach / detach 및 화면 전환 관리
