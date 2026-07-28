import Foundation
import Observation

@Observable
final class DiscoverViewModel {
    enum ModuleState: Equatable {
        case loading
        case loaded([AnimeSubject])
        case failed(String)
    }

    let api: any BangumiAPI
    var ranked: ModuleState = .loading
    var recent: ModuleState = .loading

    init(api: any BangumiAPI) {
        self.api = api
    }

    @MainActor
    func load() async {
        await load(force: false)
    }

    @MainActor
    func reload() async {
        await load(force: true)
    }

    @MainActor
    private func load(force: Bool) async {
        if force {
            ranked = .loading
            recent = .loading
        }
        guard ranked.isLoaded == false || recent.isLoaded == false else { return }
        async let rankedLoad: Void = loadRanked()
        async let recentLoad: Void = loadRecent()
        _ = await (rankedLoad, recentLoad)
    }

    @MainActor
    private func loadRanked() async {
        ranked = .loading
        do {
            let page = try await api.browseSubjects(type: .anime, sort: .rank, limit: 10, offset: 0)
            ranked = .loaded(page.items)
        } catch {
            ranked = .failed(error.localizedDescription)
        }
    }

    @MainActor
    private func loadRecent() async {
        recent = .loading
        do {
            let page = try await api.browseSubjects(type: .anime, sort: .date, limit: 10, offset: 0)
            recent = .loaded(page.items)
        } catch {
            recent = .failed(error.localizedDescription)
        }
    }
}

private extension DiscoverViewModel.ModuleState {
    var isLoaded: Bool {
        if case .loaded = self {
            return true
        }
        return false
    }
}
