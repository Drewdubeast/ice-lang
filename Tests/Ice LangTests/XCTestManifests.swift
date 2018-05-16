import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(Ice_LangTests.allTests),
    ]
}
#endif