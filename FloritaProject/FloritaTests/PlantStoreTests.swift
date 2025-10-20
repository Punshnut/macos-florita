import XCTest
@testable import Florita

/// Unit tests covering growth stage logic and calendar utilities.
final class FloritaGrowthStoreTests: XCTestCase {
    /// Ensures the growth stage thresholds match product expectations.
    func testStageThresholds() throws {
        XCTAssertEqual(FloritaGrowthStage.stage(forCareDayCount: 0), .sprout)
        XCTAssertEqual(FloritaGrowthStage.stage(forCareDayCount: 2), .sprout)
        XCTAssertEqual(FloritaGrowthStage.stage(forCareDayCount: 3), .leaves)
        XCTAssertEqual(FloritaGrowthStage.stage(forCareDayCount: 6), .leaves)
        XCTAssertEqual(FloritaGrowthStage.stage(forCareDayCount: 7), .blooms)
        XCTAssertEqual(FloritaGrowthStage.stage(forCareDayCount: 42), .blooms)
    }

    /// Verifies the calendar utility correctly identifies matching days.
    func testIsSameCalendarDay() {
        let calendar = Calendar(identifier: .gregorian)
        let morning = DateComponents(calendar: calendar, year: 2024, month: 5, day: 12, hour: 9, minute: 0).date!
        let evening = DateComponents(calendar: calendar, year: 2024, month: 5, day: 12, hour: 22, minute: 30).date!
        let nextDay = DateComponents(calendar: calendar, year: 2024, month: 5, day: 13, hour: 1, minute: 15).date!

        XCTAssertTrue(FloritaGrowthStore.occursOnSameCalendarDay(morning, evening, calendar: calendar))
        XCTAssertFalse(FloritaGrowthStore.occursOnSameCalendarDay(morning, nextDay, calendar: calendar))
    }
}
