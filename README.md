# MusicSearch

음악 검색, 차트, 날씨 기반 추천 기능이 포함된 iOS 애플리케이션.

---

## 🧾 목차

- [📱 실행 화면](#-실행-화면)
- [✨ 주요 기능](#-주요-기능)
- [📂 아키텍처 및 폴더 구조](#-아키텍처-및-폴더-구조)
- [🛠 기술 스택](#-기술-스택)
- [🚀 주요 구현](#-주요-구현)

---

## 📱 실행 화면

| Weather | Search | Chart |
| :---: | :---: |:---: |
| <img src="https://github.com/user-attachments/assets/72dc3c6c-7321-427a-88e1-de0bd4669aa3" width="150" alt="Home" /> | <img src="https://github.com/user-attachments/assets/03e122f6-c892-4715-9211-b5bb99b70559" width="150" alt="Search" /> | <img src="https://github.com/user-attachments/assets/71496392-0bd3-443c-98e3-8d227843b7b6" width="150" alt="Chart" /> |
| [아카이브 GIF 삽입] | [데모 앱 시나리오 갤러리 GIF URL 삽입] | |

---

## ✨ 주요 기능

| 구분 | 기능 |
| --- | --- |
| **음악 검색** | Spotify API 연동 트랙 검색. 무한 스크롤, 디바운스 적용 |
| **보관함 (Archive)** | 트랙 폴더화 저장 (SwiftData). 저장 트랙 Spotify 플레이리스트 내보내기 지원 |
| **음악 디깅** | 선택 트랙과 유사한 곡을 Child RIB으로 연속 탐색 |
| **날씨 추천** | 현재 위치 날씨 데이터 기반 추천 음악 태그 추출 및 트랙 표시 |
| **차트** | 트랙 및 아티스트 차트 제공 |
| **데모 앱** | 11개 피처 모듈별 독립 Example 앱 탑재. Mock 기반 상태 검증(DemoListViewController) |

---

## 📂 아키텍처 및 폴더 구조

Tuist Workspace 기반 3계층(App, Core, Features) 분리 구조.

```text
MusicSearch.xcworkspace
├── MusicSearch/App                           # 진입점(Root RIB) 및 리소스
├── MusicSearch/Core                          # 공통 Data, Domain, DesignSystem
└── MusicSearch/Features                      # 비즈니스 로직 단위 피처 모듈
    ├── Archive (TCA)
    ├── Chart (RIBs)
    ├── MusicDigging (RIBs)
    ├── Settings (RIBs)
    ├── TrackSearch (RIBs)
    └── WeatherRecommendation (RIBs)
```

### Micro-Feature 분할
각 피처 모듈은 5개 타겟으로 분리.
- `Interface`: 프로토콜(Dependency) 정의
- `Implementation`: 로직 및 UI 구현체
- `Testing`: Mock 객체 모음
- `Tests`: 단위 테스트
- `Example`: 독립 데모 앱

---

## 🛠 기술 스택

| Category | Stack |
| --- | --- |
| **Language** | Swift |
| **Architecture** | TMA(Tuist Micro-Feature Architecture), MicroRIBs, TCA |
| **Build System** | Tuist |
| **Concurrency** | Swift Concurrency (`async`/`await`) |
| **Local DB** | SwiftData |
| **UI Design** | SwiftUI, UIKit |
| **Networking** | URLSession 기반 커스텀 NetworkLayer |
| **Testing/Demo** | Swift Testing, TCA TestStore, Mock 주입 Demo 앱 |
| **Open API** | Spotify API, OpenWeatherMap |

---

## 🚀 주요 구현

### 1. 피처 모듈화 및 증분 빌드 (Tuist + Micro-Feature)
- **구현 기술:** Tuist를 사용하여 프로젝트를 3계층(App, Core, Features)으로 나누고, 각 피처를 5개(Interface, Implementation, Testing, Tests, Example) 타겟으로 세분화.
- **도입 이유:** 비즈니스 로직과 의존성을 분리하여 타겟 간 결합도를 낮추고 빌드 시간을 단축하기 위해 도입.
- **결과:** 의존성 관리가 명확해졌으며, 개별 피처 타겟만 독립적으로 빌드 및 테스트가 가능해져 개발 생산성 향상.

### 2. 아키텍처 혼용 (RIBs + TCA)
- **구현 기술:** 화면 라우팅과 생명주기 관리는 RIBs를 사용하고, 전역 상태 공유가 필요한 피처(Archive) 내부 뷰 계층은 TCA를 적용.
- **도입 이유:** 계층적 라우팅에는 RIBs의 트리 구조가 유리하고, 복잡한 상태를 가진 뷰에서는 단방향 데이터 플로우(TCA)가 유리하므로 각각의 장점을 취합함.
- **결과:** 라우팅 로직과 뷰 상태 관리 로직이 분리되어 유지보수가 용이해짐.

### 3. 고립 UI 테스트 환경 (Example 앱 및 Mock 시나리오)
- **구현 기술:** 11개 피처의 Example 앱에 `DemoScenario`(성공, 빈 화면, 에러, 지연)를 적용하고, Mock 의존성 객체가 해당 시나리오별로 동작하도록 분기 처리. (메모리 릭 방지 로직 포함)
- **도입 이유:** 실제 서버나 전체 앱 실행 없이 시뮬레이터 환경에서 빈 화면(Empty), 에러, 로딩 스켈레톤 등의 UI 엣지 케이스를 즉각적으로 확인하기 위함.
- **결과:** 개발 과정에서 네트워크 환경 조작 없이 모든 뷰 상태를 독립적이고 안정적으로 검증 가능.

### 4. 비동기 처리 (Swift Concurrency)
- **구현 기술:** Combine, GCD 대신 `async/await` 및 `AsyncStream`을 적용. OAuth 토큰 만료 시 재요청 큐잉(Queueing) 처리 구현.
- **도입 이유:** 콜백 지옥을 해결하고, 서드파티 의존성 없이 컴파일러 차원에서 안전한 데이터 레이스(Data Race) 방지를 위해 적용.
- **결과:** 비동기 코드의 가독성이 향상되고 스레드 안전성이 보장됨.

### 5. 단위 테스트 및 UI 최신화 (Swift Testing & SwiftUI)
- **구현 기술:** 레거시 `XCTest`를 최신 `Swift Testing`(`@Test`)으로 마이그레이션. SwiftUI의 Deprecated API(`NavigationView`, `.foregroundColor`)를 `NavigationStack` 및 `.foregroundStyle`로 교체.
- **도입 이유:** Apple의 최신 프레임워크 표준을 준수하고, 매크로 기반의 직관적인 테스트 작성과 최적화된 화면 전환을 적용하기 위함.
- **결과:** 값 타입(Struct) 기반 테스트로 테스트 독립성이 강화되었으며, 최신 SwiftUI API 적용으로 렌더링 호환성 확보.
