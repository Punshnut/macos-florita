import XCTest
@testable import Florita

final class PlantStoreTests: XCTestCase {
    func testStageThresholds() throws {
        XCTAssertEqual(PlantStage.stage(forDaysOfCare: 0), .sprout)
        XCTAssertEqual(PlantStage.stage(forDaysOfCare: 2), .sprout)
        XCTAssertEqual(PlantStage.stage(forDaysOfCare: 3), .leaves)
        XCTAssertEqual(PlantStage.stage(forDaysOfCare: 6), .leaves)
        XCTAssertEqual(PlantStage.stage(forDaysOfCare: 7), .blooms)
        XCTAssertEqual(PlantStage.stage(forDaysOfCare: 42), .blooms)
    }

    func testIsSameCalendarDay() {
        let calendar = Calendar(identifier: .gregorian)
        let morning = DateComponents(calendar: calendar, year: 2024, month: 5, day: 12, hour: 9, minute: 0).date!
        let evening = DateComponents(calendar: calendar, year: 2024, month: 5, day: 12, hour: 22, minute: 30).date!
        let nextDay = DateComponents(calendar: calendar, year: 2024, month: 5, day: 13, hour: 1, minute: 15).date!

        XCTAssertTrue(PlantStore.isSameCalendarDay(morning, evening, calendar: calendar))
        XCTAssertFalse(PlantStore.isSameCalendarDay(morning, nextDay, calendar: calendar))
    }
}
