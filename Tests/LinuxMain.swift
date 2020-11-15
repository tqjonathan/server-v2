import XCTest

import server_v2Tests

var tests = [XCTestCaseEntry]()
tests += server_v2Tests.allTests()
XCTMain(tests)
