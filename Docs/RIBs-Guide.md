# RIBs 가이드

## 1. 문서 목적

MusicSearch 프로젝트를 RIBs 구조로 마이그레이션하면서 정리한 학습 기록.

RIBs의 일반 개념을 길게 설명하기보다는, 실제 프로젝트에서 ViewController가 갖고 있던 책임을 어떻게 `Builder`, `Interactor`, `Router`, `Component`로 나눴는지 정리.

대표 예시는 `TrackSearch`와 그 child RIB인 `MusicDigging` 흐름을 기준으로 함.

## 2. 마이그레이션하면서 바뀐 핵심

기존 화면 중심 구조에서는 사용자 입력 처리, 상태 변경, 화면 이동, 의존성 생성 책임이 ViewController 근처에 섞이기 쉬웠음.

RIBs로 옮기면서 책임을 다음처럼 나눔.

- ViewController는 사용자 입력을 listener로 전달하고 화면 상태만 반영.
- Interactor는 검색어, 로딩, 에러, pagination 같은 상태와 비즈니스 흐름을 관리.
- Router는 child RIB attach / detach 와 navigation push / pop 을 관리.
- Builder는 RIB 조립과 의존성 연결을 담당.
- Component는 부모 scope의 dependency를 현재 RIB와 child RIB에 전달.

이 구조 덕분에 `TrackSearch`는 검색 기능 자체에 집중하고, `MusicDigging`으로 넘어가는 흐름은 명시적인 child RIB 관계로 표현할 수 있게 됨.

## 3. RIBs 설명

Uber가 큰 모바일 앱을 여러 명이 동시에 개발할 때 생기는 구조적 문제를 해결하기 위해 만든 아키텍처.

- 테스트하기 쉽고 서로 고립된 단위로 기능을 쪼갤 것.
- 화면 트리보다 비즈니스 로직 트리를 중심으로 앱을 설계할 것.
- 전역 상태를 줄이고, 각 기능이 자기 상태를 자기 스코프 안에서 관리할 것.
- 부모와 자식 사이의 요구사항을 명시적인 계약으로 드러낼 것.
- Builder, Interactor, Router처럼 책임이 분리된 객체들로 기능을 조립할 것.

RIBs는 화면 전환 패턴이 아니라, 기능을 트리로 나누고 각 노드의 책임과 생명주기를 명확하게 통제하기 위한 아키텍처.

## 4. TrackSearch를 기준으로 본 RIBs 구조

RIBs의 핵심 구성 요소는 `Builder`, `Interactor`, `Router`.

`TrackSearch`는 검색 화면이지만, 단순히 화면 하나만 의미하지 않음. 검색 입력, 검색 상태, pagination, 트랙 선택, `MusicDigging` child RIB로 이동하는 흐름까지 포함하는 하나의 기능 단위.

### Builder

`Builder`는 RIB을 조립하는 객체. View, Interactor, Router를 만들고 필요한 dependency를 연결함.

`TrackSearchBuilder`는 `TrackSearchViewController`, `TrackSearchInteractor`, `TrackSearchRouter`를 조립한다. 여기서 중요한 점은 Interactor가 ViewController나 Router를 직접 만들지 않는다는 것.

조립 책임은 Builder에 두고, Interactor는 이미 주입된 presenter와 use case만 사용한다.

<details>
<summary><code>TrackSearchBuilder</code> 예시</summary>

```swift
@MainActor
final class TrackSearchBuilder: Builder<TrackSearchDependency>, TrackSearchBuildable {
	func build(
		withListener listener: TrackSearchListener,
		navigationController: UINavigationController
	) -> TrackSearchRouting {
		MainActor.assumeIsolated {
			let component = TrackSearchComponent(dependency: self.dependency)
			let viewController = TrackSearchViewController()
			let interactor = TrackSearchInteractor(
				presenter: viewController,
				searchTracksUseCase: component.searchTracksUseCase
			)
			interactor.listener = listener

			let musicDiggingBuilder = MusicDiggingBuilder(dependency: component)
			return TrackSearchRouter(
				interactor: interactor,
				viewController: viewController,
				navigationController: navigationController,
				musicDiggingBuilder: musicDiggingBuilder
			)
		}
	}
}
```

</details>

- RIB 조립 책임이 Builder에 모여 있음.
- Interactor는 child builder를 모르고, 조립 세부사항에 관여하지 않음.
- `MusicDiggingBuilder`는 Builder에서 만들어지고 Router에 전달됨.

### Interactor

`Interactor`는 비즈니스 로직과 상태를 담당.

`TrackSearchInteractor`는 검색어 입력을 받고, debounce를 적용하고, 로딩 상태와 검색 결과를 관리한다. ViewController는 검색어가 바뀌었다는 사실만 전달하고, 검색을 언제 실행할지와 결과를 어떻게 반영할지는 Interactor가 결정한다.

트랙을 선택했을 때도 ViewController가 직접 화면을 push하지 않음. Interactor가 “MusicDigging으로 이동해야 한다”는 의도를 Router에 전달한다.

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

	private var lastKeyword: String?
	private var currentTracks: [Track] = []
	private var currentPage: Int = 1
	private var totalResults: Int = 0
	private var isLoading: Bool = false
	private var isLoadingMore: Bool = false

	func didUpdateSearchText(_ keyword: String) {
		self.searchSubject.send(keyword)
	}

	func didSelectTrack(_ track: Track) {
		self.router?.attachMusicDigging(seedTrack: track)
	}

	func didReachListBottom() {
		self.loadMore()
	}
}
```

</details>

- View는 입력만 전달.
- 검색 상태는 Interactor가 소유.
- pagination 판단도 Interactor가 담당.
- 자식 화면 이동은 Interactor가 직접 push 하지 않고 Router에 요청.

### Router

`Router`는 attach / detach 와 화면 전환을 담당.

`TrackSearchRouter`는 `MusicDigging` child RIB를 attach하고 navigation stack에 화면을 push한다. 여기서 핵심은 화면 전환과 RIB lifecycle을 같이 맞추는 것.

push만 하고 child router를 attach하지 않으면 RIB tree가 깨지고, pop 이후 detach하지 않으면 child lifecycle이 남는다.

<details>
<summary><code>TrackSearchRouter</code> 예시</summary>

```swift
@MainActor
final class TrackSearchRouter:
	ViewableRouter<TrackSearchInteractable, TrackSearchViewControllable>,
	TrackSearchRouting
{
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
- navigation stack과 router tree의 정합성을 유지.
- pop 이후 화면에서 사라진 child RIB는 detach.

## 5. 의존성 관리

RIBs의 의존성 관리는 `Dependency`와 `Component`를 활용.

### Dependency

`Dependency`는 어떤 RIB가 부모에게 요구하는 최소 계약. "무엇이 필요한가"를 드러내는 인터페이스.

`TrackSearch`는 검색 기능에 필요한 use case와 child인 `MusicDigging`에 전달해야 하는 dependency를 함께 요구한다.

<details>
<summary><code>TrackSearchDependency</code> 예시</summary>

```swift
@MainActor
protocol TrackSearchDependency: Dependency {
	var searchTracksUseCase: SearchTracksUseCase { get }
	var fetchTracksByTagUseCase: FetchTracksByTagUseCase { get }
	var fetchSimilarTracksUseCase: FetchSimilarTracksUseCase { get }
	var fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase { get }
	var urlOpener: URLOpening { get }
}
```

</details>

child는 필요한 계약만 선언하고, 실제 구현은 부모 스코프가 채움.

### Component

`Component`는 부모 dependency를 받아 현재 스코프에서 필요한 객체를 노출하고, child scope로 dependency를 이어주는 객체.

`TrackSearchComponent`는 `TrackSearchDependency`를 그대로 노출하면서 동시에 `MusicDiggingDependency`도 만족시킨다. 즉 `TrackSearch` 스코프 안에서 child인 `MusicDigging`이 필요한 의존성을 전달하는 연결 지점.

처음에는 이 부분이 헷갈릴 수 있음. Component는 단순히 현재 RIB만을 위한 객체가 아니라, 현재 scope에서 child scope로 dependency를 넘기는 역할도 함.

<details>
<summary><code>TrackSearchComponent</code> 예시</summary>

```swift
@MainActor
final class TrackSearchComponent:
	Component<TrackSearchDependency>,
	TrackSearchDependency,
	MusicDiggingDependency
{
	var searchTracksUseCase: SearchTracksUseCase {
		self.dependency.searchTracksUseCase
	}

	var fetchTracksByTagUseCase: FetchTracksByTagUseCase {
		self.dependency.fetchTracksByTagUseCase
	}

	var fetchSimilarTracksUseCase: FetchSimilarTracksUseCase {
		self.dependency.fetchSimilarTracksUseCase
	}

	var fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase {
		self.dependency.fetchMusicAppDeepLinkUseCase
	}

	var urlOpener: URLOpening {
		self.dependency.urlOpener
	}
}
```

</details>

## 6. 데이터 흐름 및 상태 관리

`TrackSearch`의 기본 흐름은 다음과 같음.

```text
ViewController -> Interactor -> Router -> Child RIB
```

### ViewController -> Interactor

ViewController는 사용자 이벤트를 listener를 통해 Interactor로 전달.

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

### Interactor -> ViewController

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

### Parent RIB -> Child RIB

부모가 child를 만들 때 `withListener:`로 상위 Interactor를 넘김.

`TrackSearchRouter`는 `MusicDiggingBuilder`를 통해 child RIB를 만들고, listener로 `self.interactor`를 넘긴다. child는 listener 프로토콜에만 의존하고, 부모 concrete type은 모름.

```swift
let musicDiggingRouter = self.musicDiggingBuilder.build(
	withListener: self.interactor,
	seedTrack: seedTrack
)
```

## 7. 테스트 전략

RIBs로 나누면서 테스트 대상도 더 명확해짐.

- Interactor 테스트는 비즈니스 규칙과 상태 반응을 검증.
- Router 테스트는 attach / detach 와 child lifecycle 정합성을 검증.
- Builder 테스트는 listener, presenter, dependency wiring이 빠지지 않았는지 검증.

### Interactor 테스트

`TrackSearchInteractorTests`는 검색어 입력 후 presenter 반영과 트랙 선택 시 라우팅 요청을 검증한다.

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
		await waitUntil("검색 결과가 presenter에 반영되지 않았습니다.") {
			self.mockUseCase.executeCallCount == 1 &&
			self.presenter.loadingStates == [true, false] &&
			self.presenter.updatedTracksHistory.last?.count == 2
		}

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

`TrackSearchRouterTests`는 `MusicDigging` child attach 와 pop 이후 detach 를 검증.

<details>
<summary><code>TrackSearchRouterTests</code> 예시</summary>

```swift
@MainActor
struct TrackSearchRouterTests {
	@Test("attachMusicDigging 호출 시 child router를 붙이고 화면을 push하는가")
	func attachMusicDiggingPushesChildViewController() {
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

- 올바른 Router 타입을 만드는가.
- Interactor와 ViewController를 제대로 연결하는가.
- listener wiring 이 빠지지 않았는가.

<details>
<summary><code>TrackSearchBuilderTests</code>에서 확인할 내용</summary>

```swift
let routing = builder.build(
	withListener: listener,
	navigationController: navigationController
)

guard let router = routing as? TrackSearchRouter else { return }
guard let interactor = router.interactor as? TrackSearchInteractor else { return }
guard let viewController = router.viewControllable as? TrackSearchViewController else { return }

#expect(interactor.listener === listener)
#expect(viewController.listener === interactor)
```

</details>

## 출처

- [Uber RIBs Wiki](https://github.com/uber/RIBs/wiki)
- [Uber RIBs README](https://github.com/uber/RIBs)
