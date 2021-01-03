import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [ XCTestCaseEntry ] {
  return [
    testCase(SwiftBlocksUITests.allTests),
    testCase(BlockIDTests      .allTests),
    testCase(PickerTests       .allTests)
  ]
}
#endif
