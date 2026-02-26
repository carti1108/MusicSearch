# MusicSearch Architecture Rules

이 문서는 `MusicSearch` 프로젝트의 아키텍처 경계와 구현 규칙을 고정하기 위한 기준 문서입니다.

## 1. Core Layers & Roles (핵심 계층 및 역할)

### 1.1 ViewController
- 화면 구성, 사용자 입력 수집, UI 렌더링만 담당하는 수동적 뷰(Passive View) 역할을 한다.
- **Listener 선언:** `ViewController` 파일 내부에 뷰가 호출하여 수행할 수 있는 프로퍼티와 메서드를 선언한 `Listener` 프로토콜을 정의한다.
- **Viewable 채택:** `ViewModel` 파일에 정의된 `Viewable` 프로토콜을 채택하여, `ViewModel`의 데이터 표시 명령을 수행한다.
- 비즈니스 로직, 네트워크 호출, 데이터 가공 로직을 두지 않는다.

### 1.2 ViewModel
- 도메인 결과를 화면 모델로 가공하고 비즈니스 로직 처리를 담당한다.
- **Viewable 선언:** `ViewModel` 파일 내부에 `ViewModel`이 데이터를 표시하기 위해 `ViewController`를 호출할 수 있는 메서드를 선언한 `Viewable` 프로토콜을 정의한다.
- **Listener 채택:** `ViewController` 파일에 정의된 `Listener` 프로토콜을 채택하여 뷰의 액션을 처리하고 필요한 데이터를 제공한다.
- `weak var view: XxxViewable?` 참조를 통해 뷰에 명시적으로 UI 업데이트를 명령한다.
- 내비게이션은 직접 수행하지 않고 `CoordinatorAction` 호출로 위임한다.
- `Repository` 직접 의존을 금지하고 `UseCase`에만 의존한다.

### 1.3 Coordinator
- 화면 이동, 딥링크 오픈, 플로우 전환만 담당한다.
- 상태 가공, API 호출, 캐시 판단 로직을 두지 않는다.

### 1.4 UseCase
- 사용자 시나리오 단위의 오케스트레이션을 담당한다.
- 여러 Repository 조합, 정책 적용, 흐름 제어를 수행한다.
- UIKit/화면 상태에 의존하지 않는다.
- 외부에 노출하는 메서드는 `execute` 계열만 허용한다.
  - 허용 예: `execute()`, `execute(input:)`, `execute(request:)`
  - 금지 예: `fetchSomething()`, `loadSomething()`, `doWork()`

### 1.5 Repository
- 데이터 소스 추상화(네트워크/캐시/로컬 저장소)를 담당한다.
- 캐시 정책(TTL, force refresh, invalidate)을 소유한다.
- 상위 레이어에는 Domain Entity만 노출한다.

### 1.6 DTO / Entity
- DTO는 외부 API 계약 모델이다.
- Entity는 앱 도메인 모델이다.
- DTO -> Entity 매핑은 Data 레이어에서만 수행한다.


## 2. Communication & Data Flow (통신 및 데이터 흐름)

### 2.1 Communication Rules (View ↔ ViewModel)
- 뷰와 뷰모델은 서로의 구체 타입(Concrete Type)을 알지 못하며, 오직 `Listener`와 `Viewable` 프로토콜을 통해서만 소통한다.
- **Listener 규칙:** 뷰가 뷰모델에게 동작을 요청하거나 필요한 값을 읽어올 때 사용한다.
- **Viewable 규칙:** 뷰모델이 뷰에게 화면에 특정 데이터를 그리거나 UI 상태를 변경하라고 지시할 때 사용한다.
- 뷰모델에서 `Viewable`을 통해 뷰에 명령을 내릴 때는 반드시 Main Thread에서 호출되도록 보장한다. (예: `@MainActor` 활용)
- **Stale Response 방지:** 비동기 네트워크 통신 후 늦은 응답이 화면을 덮어쓰는 것을 방지하기 위해 프로젝트 공통 방식을 사용한다.
  - 기본 권장: `Task cancel + Task.isCancelled` 검증을 거친 후, 작업이 취소되지 않은 안전한 상태에서만 `view?.update()` 등을 호출한다.

### 2.2 Caching Rules
- 화면 간 공유가 필요한 캐시는 ViewModel에 두지 않는다.
- 공유 캐시는 Repository 레이어로 올린다.
- `force = true`: 캐시 우회하고 원본 소스 조회
- `force = false`: 캐시 우선 사용
- 캐시 hit 경로에서도 뷰 업데이트 규칙(`Viewable` 호출)을 동일하게 적용한다.


## 3. Dependency Injection & Assembly (의존성 주입 및 조립)

### 3.1 Dependency & Component
- **Dependency:** 외부에서 주입받아야 하는 기능 계약만 선언한다. 구체 구현체(`Impl`)가 아닌 프로토콜 타입만 노출하며, UIKit 타입 노출을 금지한다.
- **Component:** 객체 조립(assembly)만 담당한다. 비즈니스 로직을 갖지 않으며, 노출 API는 생성 메서드(`makeXxxViewModel()`, `makeXxxViewController()`, `makeXxxCoordinator()`) 중심으로 제한한다.

### 3.2 Scope (Lifecycle) & Project-specific Notes
- **AppComponent:** 앱 전역 공유 인스턴스 소유 및 전역 조립의 루트다.
  - 예: `NetworkManager`, 공유 `Repository`, 캐시 객체
  - 화면 간 공유가 필요한 객체(특히 캐시 Repository, 토큰/세션 관련 객체)는 `AppComponent`에서 재사용 인스턴스로 관리한다.
- **FeatureComponent:** 상위 `Dependency`를 받아 피처 객체를 조립하는 역할에 집중한다. 보통 화면/탭 단위 객체 생성을 담당한다.
- **ViewModel:** 기본 `Transient` (필요 시마다 생성)
- **UseCase:** 기본 `Transient`, 상태/세션/캐시 포함 시 `Singleton`로 승격
- **Scope 금지 규칙:** 공유가 필요한 객체를 computed property로 매번 재생성하지 않는다. 공유 상태는 반드시 저장 프로퍼티(`lazy var` 등)로 유지한다.


## 4. Cross-Cutting Policies (공통 처리 정책)

### 4.1 Error / Logging Rules
- Repository/UseCase는 가능한 typed error를 유지한다.
- 사용자 메시지 매핑은 ViewModel에서 최종 처리하여 `Viewable`을 통해 에러 화면/얼럿 표출을 지시한다.
- `print` 남발을 금지하고, 필요한 로깅 지점만 남긴다.


## 5. Quality Assurance & Governance (품질 보증 및 아키텍처 강제)

### 5.1 Architecture Enforcement (강제 장치)
- **Protocol / Generic Contracts:**
  - `UseCase`는 공통 프로토콜로 묶고, 외부 계약은 `execute`만 노출한다.
  - `ViewModel`은 뷰의 `Listener` 프로토콜을 채택하고, 뷰를 제어할 `Viewable` 프로토콜을 약한 참조(`weak`)로 소유하는 계약을 준수한다.
  - `Coordinator`는 최소 `start()` 계약을 강제한다.
  - `Component`는 `associatedtype DependencyType: Dependency`를 강제해 잘못된 조립을 컴파일 타임에 차단한다.
- **Access Control:**
  - UseCase 내부 보조 메서드는 `private`로 감추고, 외부 공개 API는 `execute`만 유지한다.
  - Repository 구현체(`Impl`)는 가능한 `internal`/`fileprivate`로 제한하고 프로토콜만 노출한다.
- **Lint / Static Checks:**
  - ViewModel 폴더에서 `Repository` 직접 참조 금지
  - UseCase에서 UIKit import 금지
  - UseCase 내 `execute` 이외 public 함수 금지
- **Folder & Naming Conventions:**
  - UseCase 파일명/타입명은 `*UseCase`/`*UseCaseImpl` 패턴으로 고정한다.
  - 외부 노출 함수명은 `execute`로 통일한다.
  - 통신 프로토콜 명칭은 `*Viewable`, `*Listener` 패턴으로 고정한다.

### 5.2 Test Rules
- ViewModel 테스트: `Listener` 액션 호출 시 예상되는 `Viewable` Mock의 메서드가 올바르게 호출되는지 검증
- UseCase 테스트: Repository mock 기반 시나리오 검증
- Repository 테스트: 성공/실패/캐시 정책 검증
- Coordinator 테스트: 이벤트 -> 라우팅 호출 검증

### 5.3 Definition of Done (Architecture)
- 레이어 경계 위반이 없다. (예: ViewModel -> Repository 직접 의존 금지)
- View와 ViewModel 간의 통신이 `Listener`/`Viewable` 프로토콜만을 통해 이루어졌다.
- 에러 노출 정책이 피처 간 일관된다.
