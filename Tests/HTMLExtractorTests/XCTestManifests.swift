import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(HTMLExtractorTests.allTests),
    ]
}
#endif
