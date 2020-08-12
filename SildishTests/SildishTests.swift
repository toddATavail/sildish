//
//  SildishTests.swift
//  SildishTests
//
//  Created by Todd L Smith on 7/30/20.
//  Copyright © 2020 Todd L Smith. All rights reserved.
//

import XCTest
@testable import Sildish

class PrefixTreeTests: XCTestCase
{
    override func setUpWithError () throws
	{
        // Put setup code here. This method is called before the invocation of
		// each test method in the class.
    }

    override func tearDownWithError () throws
	{
        // Put teardown code here. This method is called after the invocation
		// of each test method in the class.
    }

	/// Verify the single path variant of `.build()`.
    func testPrefixTreeBuildPath () throws
	{
		let emptyTree = PrefixTree<Character, String>.build(
			path: "",
			payload: "nothing")
		XCTAssertEqual(
			emptyTree,
			PrefixTree<Character, String>.leaf(payload: "nothing"))
		let prefixTree = PrefixTree<Character, String>.build(
			path: "hello",
			payload: "world")
		XCTAssertEqual(
			prefixTree,
			PrefixTree<Character, String>.interior(
				branches: ["h" : .interior(
					branches: ["e" : .interior(
						branches: ["l" : .interior(
							branches: ["l" : .interior(
								branches: ["o" : .leaf(payload: "world")],
								payload: nil
							)],
							payload: nil
						)],
						payload: nil
					)],
					payload: nil
				)],
				payload: nil))
    }
}
