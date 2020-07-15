import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [ XCTestCaseEntry ] {
  return [
    testCase(SwiftBlocksUI.allTests),
    testCase(BlockIDTests .allTests),
    testCase(PickerTests  .allTests)
  ]
}
#endif
