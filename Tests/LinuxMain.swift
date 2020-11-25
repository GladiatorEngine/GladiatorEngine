import XCTest

import EngineTests

var tests = [XCTestCaseEntry]()
tests += EngineTests.allTests()
tests += AssetManagerTests.allTests()
XCTMain(tests)
