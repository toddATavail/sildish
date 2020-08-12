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
	/// Verify the single path variant of `.build()`.
    func testBuildPath ()
	{
		let emptyTree = PrefixTree<Character, String>.build(
			path: "",
			payload: "nothing")
		XCTAssertEqual(
			emptyTree,
			PrefixTree<Character, String>.leaf(payload: "nothing")
		)
		
		let sumTree = PrefixTree<Int, Int>.build(
			path: [1, 9],
			payload: 10)
		XCTAssertEqual(
			sumTree,
			PrefixTree<Int, Int>.interior(
				branches: [1 : .interior(
					branches: [9: .leaf(payload: 10)],
					payload: nil
				)],
				payload: nil
			)
		)
		
		let greetingTree = PrefixTree<Character, String>.build(
			path: "hello",
			payload: "world")
		XCTAssertEqual(
			greetingTree,
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
				payload: nil
			)
		)
    }
	
	/// Verify the lookup operation.
	func testLookup ()
	{
		let emptyTree = PrefixTree<Character, String>.build(
			path: "",
			payload: "nothing")
		XCTAssertEqual(emptyTree[""], "nothing")
		
		let sumTree = PrefixTree<Int, Int>.build(
			path: [1, 9],
			payload: 10)
		XCTAssertEqual(sumTree[[1]], nil)
		XCTAssertEqual(sumTree[[1, 9]], 10)
		
		let greetingTree = PrefixTree<Character, String>.build(
			path: "hello",
			payload: "world")
		XCTAssertEqual(greetingTree["h"], nil)
		XCTAssertEqual(greetingTree["he"], nil)
		XCTAssertEqual(greetingTree["hel"], nil)
		XCTAssertEqual(greetingTree["hell"], nil)
		XCTAssertEqual(greetingTree["hello"], "world")
	}
	
	/// Verify merge of empty trees.
	func testMergeEmpty ()
	{
		typealias PT = PrefixTree<Character, String>
		let emptyTree = PT.empty
		let defaultTree = PT.build(path: "", payload: "default")
		let indefiniteArticleTree = PT.build(
			path: "an",
			payload: "indefinite"
		)

		// Test merge of empties.
		XCTAssertEqual(try? emptyTree.merge(emptyTree), emptyTree)
		
		// Test merge of empty and leaf.
		XCTAssertEqual(
			try? emptyTree.merge(defaultTree),
			defaultTree
		)
		XCTAssertEqual(
			try? defaultTree.merge(emptyTree),
			defaultTree
		)

		// Test merge of empty and interior.
		XCTAssertEqual(
			try? emptyTree.merge(indefiniteArticleTree),
			indefiniteArticleTree
		)
		XCTAssertEqual(
			try? indefiniteArticleTree.merge(emptyTree),
			indefiniteArticleTree
		)
	}
	
	/// Verify merge of leaves.
	func testMergeLeaves ()
	{
		typealias PT = PrefixTree<Character, String>
		let indefiniteArticleTree = PT.build(
			path: "an",
			payload: "indefinite"
		)
		let abbreviatedIndefiniteArticleTree = PT.build(
			path: "an",
			payload: "indef. a."
		)
		
		// Test merge of equivalent leaves.
		XCTAssertEqual(
			try? indefiniteArticleTree.merge(indefiniteArticleTree),
			indefiniteArticleTree
		)
		
		// Test merge of conflicting leaves.
		XCTAssertEqual(
			try? indefiniteArticleTree.merge(abbreviatedIndefiniteArticleTree),
			abbreviatedIndefiniteArticleTree
		)
		XCTAssertEqual(
			try? abbreviatedIndefiniteArticleTree.merge(indefiniteArticleTree),
			indefiniteArticleTree
		)
	}
	
	/// Verify merge of overlapping sequences.
	func testMergeOverlaps ()
	{
		typealias PT = PrefixTree<Character, String>
		let shortTree = PT.build(path: "an", payload: "indefinite article")
		let mediumTree = PT.build(path: "ant", payload: "insect")
		let longTree = PT.build(path: "anteater", payload: "mammal")
		
		let mergedShortMediumTree = try! shortTree.merge(mediumTree)
		let mergedMediumShortTree = try! mediumTree.merge(shortTree)
		
		XCTAssertEqual(mergedShortMediumTree, mergedMediumShortTree)
		XCTAssertEqual(mergedShortMediumTree["an"], "indefinite article")
		XCTAssertEqual(mergedShortMediumTree["ant"], "insect")
		XCTAssertEqual(mergedMediumShortTree["an"], "indefinite article")
		XCTAssertEqual(mergedMediumShortTree["ant"], "insect")
		
		let mergedLongShortMediumTree =
			try! longTree.merge(mergedShortMediumTree)
		let mergedLongMediumShortTree =
			try! longTree.merge(mergedMediumShortTree)

		XCTAssertEqual(mergedLongShortMediumTree, mergedLongMediumShortTree)
		XCTAssertEqual(mergedLongShortMediumTree["an"], "indefinite article")
		XCTAssertEqual(mergedLongShortMediumTree["ant"], "insect")
		XCTAssertEqual(mergedLongShortMediumTree["anteater"], "mammal")
		XCTAssertEqual(mergedLongMediumShortTree["an"], "indefinite article")
		XCTAssertEqual(mergedLongMediumShortTree["ant"], "insect")
		XCTAssertEqual(mergedLongMediumShortTree["anteater"], "mammal")
	}
	
	/// Verify merge of interiors.
	func testMergeInteriors ()
	{
		typealias PT = PrefixTree<Character, String>
		let aTree = PT.build(path: "a", payload: "a")
		let anTree = PT.build(path: "an", payload: "an")
		let theTree = PT.build(path: "the", payload: "the")
		let articleTree = try? aTree.merge(anTree).merge(theTree)
		
		XCTAssertNotNil(articleTree)
		
		// Verify equivalence among all permutations of composition by testing
		// each against an exemplar.
		[
			(aTree, anTree, theTree),
			(anTree, theTree, aTree),
			(theTree, aTree, anTree),
			(aTree, theTree, anTree),
			(anTree, theTree, aTree),
			(theTree, anTree, aTree)
		]
		.forEach { (t1, t2, t3) in
			let combinedTree = try? t1.merge(t2).merge(t3)
			XCTAssertNotNil(combinedTree)
			XCTAssertEqual(combinedTree, articleTree)
		}
	}
	
	/// Verify the update operation.
	func testUpdate ()
	{
		typealias PT = PrefixTree<Character, String>
		let aTree = PT.build(path: "a", payload: "a")
		let anTree = try! aTree.merge(PT.build(path: "an", payload: "an"))
		let theTree = try! anTree.merge(PT.build(path: "the", payload: "the"))

		var tree = PT.empty
		tree["a"] = "a"
		XCTAssertEqual(tree, aTree)
		
		tree["an"] = "an"
		XCTAssertEqual(tree, anTree)
		XCTAssertNotEqual(tree, PT.build(path: "an", payload: "an"))
		
		tree["the"] = "the"
		XCTAssertEqual(tree, theTree)
		XCTAssertNotEqual(tree, PT.build(path: "the", payload: "the"))
	}
	
	/// Verify composition from a `Dictionary`.
	func testBuild ()
	{
		typealias PT = PrefixTree<Character, String>
		let map = [
			"a" : "indefinite article",
			"an" : "indefinite article",
			"the" : "definite article"
		]
		let tree = PT.build(allPaths: map)
		
		XCTAssertEqual(tree["a"], "indefinite article")
		XCTAssertEqual(tree["an"], "indefinite article")
		XCTAssertEqual(tree["the"], "definite article")
	}
	
	/// Verify multiple payload collection.
	func testAllPayloads ()
	{
		typealias PT = PrefixTree<Character, String>
		typealias PP = PT.PositionedPayload
		let tree = PT.build(allPaths: [
			"" : "nothing",
			"a" : "article",
			"an" : "article",
			"ant" : "noun",
			"ante" : "noun",
			"anteater" : "noun"
		])
		
		XCTAssertEqual(tree.allPayloads(along: ""), [PP("nothing", 0)])
		XCTAssertEqual(
			tree.allPayloads(along: "a"),
			[PP("nothing", 0), PP("article", 1)]
		)
		XCTAssertEqual(
			tree.allPayloads(along: "an"),
			[PP("nothing", 0), PP("article", 1), PP("article", 2)]
		)
		XCTAssertEqual(
			tree.allPayloads(along: "ant"),
			[
				PP("nothing", 0),
				PP("article", 1),
				PP("article", 2),
				PP("noun", 3)
			]
		)
		XCTAssertEqual(
			tree.allPayloads(along: "ante"),
			[
				PP("nothing", 0),
				PP("article", 1),
				PP("article", 2),
				PP("noun", 3),
				PP("noun", 4)]
		)
		XCTAssertEqual(
			tree.allPayloads(along: "antea"),
			[
				PP("nothing", 0),
				PP("article", 1),
				PP("article", 2),
				PP("noun", 3),
				PP("noun", 4)
			]
		)
		XCTAssertEqual(
			tree.allPayloads(along: "anteat"),
			[
				PP("nothing", 0),
				PP("article", 1),
				PP("article", 2),
				PP("noun", 3),
				PP("noun", 4)
			]
		)
		XCTAssertEqual(
			tree.allPayloads(along: "anteate"),
			[
				PP("nothing", 0),
				PP("article", 1),
				PP("article", 2),
				PP("noun", 3),
				PP("noun", 4)
			]
		)
		XCTAssertEqual(
			tree.allPayloads(along: "anteater"),
			[
				PP("nothing", 0),
				PP("article", 1),
				PP("article", 2),
				PP("noun", 3),
				PP("noun", 4),
				PP("noun", 8)
			]
		)
		XCTAssertEqual(
			tree.allPayloads(along: "anteaters"),
			[
				PP("nothing", 0),
				PP("article", 1),
				PP("article", 2),
				PP("noun", 3),
				PP("noun", 4),
				PP("noun", 8)
			]
		)
	}
	
	/// Verify stringification.
	func testStringification ()
	{
		typealias PT = PrefixTree<Character, String>
		let emptyTree = PT.empty
		let defaultTree = PT.build(path: "", payload: "nothing")
		let articleTree = PT.build(allPaths: [
			"a" : "indefinite article",
			"an" : "indefinite article",
			"the" : "definite article"
		])
		
		XCTAssertEqual(
			emptyTree.description,
			"""
- «empty tree»

"""
		)
		XCTAssertEqual(
			defaultTree.description,
			"""
* nothing

"""
		)
		XCTAssertEqual(
			articleTree.description,
			"""
* «nil»
- a:
	* indefinite article
	- n:
		* indefinite article
- t:
	* «nil»
	- h:
		* «nil»
		- e:
			* definite article

"""
		)
	}
}
