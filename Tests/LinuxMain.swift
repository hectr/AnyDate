import XCTest

import dateparseTests

var tests = [XCTestCaseEntry]()
tests += AnyDateTests.allTests()
tests += DateParseTests.allTests()
XCTMain(tests)
