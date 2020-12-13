//
//  EdgeTests.swift
//  VergeTests
//
//  Created by Muukii on 2020/12/14.
//  Copyright © 2020 muukii. All rights reserved.
//

import Foundation
import XCTest

import Verge

final class EdgeTests: XCTestCase {

  struct Mock: Equatable {

    static func == (lhs: Self, rhs: Self) -> Bool {
      lhs.onCallEquatable()
      rhs.onCallEquatable()
      return lhs.id == rhs.id
    }

    var onCallEquatable: () -> Void = {}
    let id = UUID()
  }

  func testComparion() {

    let exp = expectation(description: "onCall")
    exp.assertForOverFulfill = false

    var mock = Mock()
    mock.onCallEquatable = {
      exp.fulfill()
    }

    let edge = Edge<Mock>.init(wrappedValue: mock)
    var edge2 = edge

    XCTAssertEqual(edge.version, edge2.version)

    edge2.wrappedValue = mock

    XCTAssertNotEqual(edge.version, edge2.version)

    XCTAssertTrue(edge == edge2)
    wait(for: [exp], timeout: 1)
  }
}
