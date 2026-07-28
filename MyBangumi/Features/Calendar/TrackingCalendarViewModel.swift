import Foundation
import Observation

@Observable
@MainActor
final class TrackingCalendarViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    let api: any BangumiAPI

    var days: [AiringCalendarDay] = []
    var state: State = .idle
    var selectedDayID: Int?

    var selectedDay: AiringCalendarDay? {
        guard let selectedDayID else {
            return days.first
        }
        return days.first { $0.id == selectedDayID } ?? days.first
    }

    init(api: any BangumiAPI) {
        self.api = api
    }

    func load() async {
        state = .loading
        do {
            days = try await api.airingCalendar().sorted { $0.id < $1.id }
            if selectedDayID == nil || days.contains(where: { $0.id == selectedDayID }) == false {
                selectedDayID = days.first?.id
            }
            state = .loaded
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func select(dayID: Int) {
        selectedDayID = dayID
    }
}
