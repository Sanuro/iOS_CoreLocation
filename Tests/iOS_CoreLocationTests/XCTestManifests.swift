import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(iOS_CoreLocationTests.allTests),
    ]
}
#endif