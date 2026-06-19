# iOS Bangumi Client Design

Date: 2026-06-20

## Goal

Build a native iOS 26 Bangumi client focused on anime browsing. The first release should feel like a modern iOS app that uses the latest system design language, including Liquid Glass where appropriate, while still proving the real Bangumi public API flow end to end.

The first implementation is a vertical slice: discovery, database browsing, search, and subject detail all use real API data. Login, collection management, watch progress, and community features are intentionally deferred.

## Product Scope

The app has four primary tabs. Display labels are Chinese; internal module names can remain English:

- 发现 / Discover: the default landing page and product showcase. It presents anime discovery modules such as high-ranked, recent, or popular subjects.
- 数据库 / Database: a structured anime browsing surface with list browsing, sorting, and simple filters.
- 我的 / My: an unauthenticated placeholder for future Bangumi login, collections, and progress tracking. It can also contain lightweight settings, data source information, cache controls, and app information.
- 搜索 / Search: a dedicated search page for anime keyword search.

Subject detail is reachable from Discover, Database, and Search through a pushed navigation flow.

## First Release Includes

- Native SwiftUI app targeting iOS 26.
- Bottom navigation with 发现, 数据库, 我的, and 搜索.
- Anime-first browsing and search.
- Bangumi public API integration for subject browsing, subject search, subject detail, and cover images.
- Liquid Glass-inspired design components for cards, panels, loading states, and prominent content sections.
- Clear loading, empty, error, and partial failure states.
- Unit tests for API request handling, mapping, and view model state transitions.
- A lightweight UI smoke test for launch and basic navigation.

## Xcode Project Settings

The project must use these Xcode settings:

- Product: App
- Interface: SwiftUI
- Language: Swift
- Testing System: Swift Testing
- Storage: None
- Minimum Deployment Target: iOS 26.0

Do not enable SwiftData for the first release. The app uses in-memory cache only, and persistent storage is deferred.

## First Release Excludes

- Bangumi login or OAuth.
- Online collections, watch progress, episode management, or user library sync.
- Timeline, comments, friends, or other community features.
- Full support for books, games, music, or real-life subjects.
- Offline database behavior, complex local persistence, or push notifications.
- Pixel-level reproduction of bangumi.tv web pages.

## API Boundary

The first release uses the public Bangumi API. The known useful endpoints are:

- `GET /v0/subjects` for browsing subjects with type, sort, year, month, limit, and offset parameters.
- `POST /v0/search/subjects` for keyword search, filtered to anime subjects.
- `GET /v0/subjects/{subject_id}` for subject detail.
- Subject image URLs or image endpoints for cover display.
- Deferred API endpoints: subject persons, characters, related subjects, and episodes.

The search endpoint is experimental, so search errors should be surfaced clearly rather than treated as empty results. Discover should prefer stable browsing endpoints where possible and allow individual modules to fail without blanking the whole page.

## Architecture

Use MVVM with feature modules and no third-party dependencies in the first release.

Main areas:

- `MyBangumi/Features/Discover`: Discover tab views, view models, and module state.
- `MyBangumi/Features/Database`: Database tab views, view models, sorting, and simple filter state.
- `MyBangumi/Features/Search`: Search tab views, debounced search state, result pagination, and empty/error states.
- `MyBangumi/Features/SubjectDetail`: Subject detail view and view model.
- `MyBangumi/Features/Profile`: My tab placeholder, settings, attribution, and diagnostics.
- `MyBangumi/Shared/API`: Bangumi API protocol, `URLSession` client, endpoint definitions, request construction, response models, mock API, and error mapping.
- `MyBangumi/Shared/Domain`: Stable app models such as `AnimeSubject`, `SubjectDetail`, and `RatingSummary`.
- `MyBangumi/Shared/DesignSystem`: reusable Liquid Glass-style components, poster cards, rating pills, loading skeletons, empty states, and error views.
- `MyBangumi/Shared/Cache`: first release uses lightweight in-memory caching only. Persistent response caching, custom image cache storage, SwiftData, and local history are deferred.

State management should use modern Swift observation patterns. Network APIs should use `async/await`. UI should depend on domain models rather than raw API response structs.

Views must not perform networking. All network requests go through `BangumiAPI`. View models own loading state and trigger API calls. Views only render state and send user intents to view models.

## API Layer

Use protocol-first API design:

```swift
protocol BangumiAPI {
    func browseSubjects(type: SubjectType, sort: SubjectSort, limit: Int, offset: Int) async throws -> PagedSubjects
    func searchSubjects(keyword: String, type: SubjectType, limit: Int, offset: Int) async throws -> PagedSubjects
    func subject(id: Int) async throws -> SubjectDetail
}
```

The production implementation is `BangumiAPIClient`. Tests and previews use `MockBangumiAPI`.

`BangumiAPIClient` must:

- Use `URLSession`.
- Set a clear `User-Agent`, including the app name and GitHub repository URL.
- Map non-2xx responses into typed API errors.
- Keep request models, response models, and domain models separate.

## Navigation

The root view uses a four-tab bottom navigation:

- 发现
- 数据库
- 我的
- 搜索

Each tab owns its own navigation stack where appropriate. Subject detail is pushed from Discover, Database, or Search. Search is a standalone tab, not just a field inside Discover.

## Page Behavior

Discover:

- Loads two or three anime discovery modules on entry.
- Uses real API data.
- Shows module-level loading and error states.
- Keeps working modules visible even if one module fails.

Database:

- Shows a browsable anime subject list.
- Supports simple sort options such as ranking or air date.
- Keeps filtering intentionally small for the vertical slice.

Search:

- Provides a dedicated keyword search page.
- Calls `POST /v0/search/subjects`.
- Filters results to anime.
- Debounces user input before calling the API. The debounce interval must be between 300ms and 500ms.
- Distinguishes empty results from API or network failures.
- Supports a first page of results and one explicit "load more" action using `limit` and `offset`.

Subject Detail:

- Uses already available list data for immediate context when possible.
- Fetches full detail with `GET /v0/subjects/{subject_id}`.
- Shows cover, original name, Chinese name, rating, rank, summary, metadata, and tags.
- Does not include characters, staff, relations, or episodes in the first release.
- Cover image failure should not fail the page.

Images:

- Use `AsyncImage` only.
- Do not add Kingfisher, Nuke, or any other image loading dependency.
- Show a deterministic placeholder when a cover is missing or fails to load.

My:

- Shows an unauthenticated placeholder.
- Explains that login, collections, and progress tracking are future work.
- Can include app information, API attribution, cache controls, and diagnostics.

## Error Handling

Errors should be clear to users and useful to developers:

- Offline or network failure: show a retry affordance with a short message.
- Non-2xx API response: show a service error and retain the status code for diagnostics.
- Decode failure: show that the returned data could not be recognized, and log the endpoint.
- Empty search result: show an empty state, not an error.
- Image failure: show a cover placeholder only.
- Discover module failure: fail that module locally, not the entire Discover page.

## Design System

Liquid Glass should use concrete iOS 26 system APIs where available:

- `.thinMaterial`
- `.regularMaterial`
- `glassEffect`
- `glassEffectContainer`

Use these APIs through shared design-system components instead of scattering visual effects across feature views.

## Implementation Constraints

The first implementation must compile and run after each milestone. Do not leave placeholder implementations, unimplemented stubs, or deliberate compilation errors. Prioritize working vertical slices over architectural completeness.

Each milestone must end with:

- The app compiling for the iOS 26 simulator.
- Relevant unit tests passing.
- No `TODO` code required for the milestone's behavior to work.
- A git commit for the completed milestone.

## Testing Strategy

Unit tests:

- API client request construction.
- Status code handling and error mapping.
- JSON decoding for representative subject browse, search, and detail responses.
- Domain mapping, including missing Chinese names, missing ratings, empty summaries, and absent images.
- View model state transitions for loading, loaded, empty, and failed states.

Previews:

- Main components in loading, loaded, empty, and error states.
- Discover modules and subject cards with representative anime data.

UI tests:

- App launch smoke test.
- Basic tab navigation.
- One simple path from a list item to detail when fixture or stable mocked data is available.

## Success Criteria

The first implementation is successful when:

- The app runs on an iOS 26 simulator.
- The bottom navigation contains 发现, 数据库, 我的, and 搜索.
- Discover, Database, and Search use real Bangumi API data.
- Subject detail displays a real anime subject.
- Main loading, empty, and error states are visible and understandable.
- The API and view model layers have focused unit tests.
- The codebase remains ready to add login and broader subject types later without rewriting the first release.
