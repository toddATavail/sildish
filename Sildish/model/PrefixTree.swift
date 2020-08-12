//
//  PrefixTree.swift
//  sildish
//
//  Created by Todd L Smith on 8/8/20.
//  Copyright © 2020 Todd L Smith. All rights reserved.
//

import Foundation

/// A prefix tree to support transliteration, where `T` is the traversal type
/// and `P` is the payload type.
enum PrefixTree<T: Hashable, P>
{
	/// An empty prefix tree.
	case empty
	
	/// An interior node comprises a traversal map and an optional payload.
	case interior (branches: [T : PrefixTree<T, P>], payload: P?)
	
	/// A leaf node contains only a payload.
	case leaf (payload: P)

	subscript <I> (path: I) -> P? where I: Sequence, I.Element == T
	{
		get
		{
			var tree: PrefixTree<T, P>? = self
			for component in path
			{
				switch tree
				{
					case .interior(let branches, _):
						tree = branches[component]
					default:
						return nil
				}
			}
			switch tree
			{
				case .interior(_, let payload):
					return payload
				case .leaf(let payload):
					return payload
				default:
					return nil
			}
		}
		
		set (replacementOrNil)
		{
			precondition(replacementOrNil != nil)
			let replacement = replacementOrNil!
			self = self.merge(
				.build(path: path, payload: replacement)
			) { (_: P, _: P) in
				replacement
			}
		}
	}
	
	/// A payload positioned within some prefix tree, discovered by
	/// `allPayloads`.
	struct PositionedPayload<P>
	{
		/// The payload.
		let payload: P
		
		/// The position at which the payload was discovered.
		let position: Int
		
		internal init (_ payload: P, _ position: Int)
		{
			self.payload = payload
			self.position = position
		}
	}
	
	/// Answer all payloads present in the prefix tree along the specified path.
	///
	/// - Parameters:
	///   - path: The path to traverse.
	/// - Returns: An array of `PositionedPayload`s.
	func allPayloads <I> (along path: I) -> [PositionedPayload<P>]
		where I: Sequence, I.Element == T
	{
		var payloads: [PositionedPayload<P>] = []
		var tree: PrefixTree<T, P>? = self
		var position = 0
		for component in path
		{
			switch tree
			{
				case .interior(let branches, let payload) where payload != nil:
					tree = branches[component]
					payloads += [PositionedPayload(payload!, position)]
				case .interior(let branches, _):
					tree = branches[component]
				case .leaf(let payload):
					tree = .empty
					payloads += [PositionedPayload(payload, position)]
					fallthrough
				default:
					return payloads
			}
			position += 1
		}
		switch tree
		{
			case .interior(_, let payload) where payload != nil:
				payloads += [PositionedPayload(payload!, position)]
			case .leaf(let payload):
				payloads += [PositionedPayload(payload, position)]
			default:
				break
		}
		return payloads
	}
	
	/// Merge the receiver and the specified tree.
	///
	/// - Parameters:
	///   - other: Another prefix tree.
	///   - onConflict: How to resolve a conflict between two payloads. Accepts
	///     the conflicting payloads, as `old` and then `new`. May throw an
	///     exception to abort. Defaults to a function that answers `new`.
	/// - Returns: The merged prefix tree.
	func merge (
		_ other: Self,
		onConflict: (_ old: P, _ new: P) throws -> P = {_, new in new}
	) rethrows -> Self
	{
		switch (self, other)
		{
			case (.empty, let t), (let t, .empty):
				// Return whatever we haven't detected was empty — even if it's
				// also empty.
				return t
			case (.leaf(let p1), .leaf(let p2)):
				// The leaves are potentially in conflict, so resolve the
				// conflict.
				return try .leaf(payload: onConflict(p1, p2))
			case let (
					.leaf(leftPayloadOrNil),
					.interior(branches: branches, payload: rightPayloadOrNil)):
				// A leaf node needs to be converted to an interior node.
				if rightPayloadOrNil == nil
				{
					// The right tree has no payload, so use the left tree's
					// payload (which is possibly nil).
					return .interior(
						branches: branches,
						payload: leftPayloadOrNil
					)
				}
				else
				{
					// Both trees had payloads, so resolve the conflict during
					// the promotion.
					return try .interior(
						branches: branches,
						payload: onConflict(
							leftPayloadOrNil,
							rightPayloadOrNil!
						)
					)
				}
			case let (
				   .interior(branches: branches, payload: leftPayloadOrNil),
				   .leaf(rightPayloadOrNil)):
				// A leaf node needs to be converted to an interior node.
				if leftPayloadOrNil == nil
				{
					// The right tree has no payload, so use the left tree's
					// payload (which is possibly nil).
					return .interior(
						branches: branches,
						payload: rightPayloadOrNil
					)
				}
				else
				{
					// Both trees had payloads, so resolve the conflict during
					// the promotion.
					return try .interior(
						branches: branches,
						payload: onConflict(
							leftPayloadOrNil!,
							rightPayloadOrNil
						)
					)
				}
			case let (
					.interior(branches: b1, payload: leftPayloadOrNil),
					.interior(branches: b2, payload: rightPayloadOrNil)):
				// Two interior nodes must be recursively merged.
				if leftPayloadOrNil == nil
				{
					// The left tree has no payload, so use the right tree's
					// payload (which is possibly nil).
					var merged = b1
					try merged.merge(b2) { s1, s2 in
						try s1.merge(s2, onConflict: onConflict)
					}
					return .interior(
						branches: merged,
						payload: rightPayloadOrNil
					)
				}
				else if rightPayloadOrNil == nil
				{
					// The right tree has no payload, so use the left tree's
					// payload (which is possibly nil).
					var merged = b1
					try merged.merge(b2) { s1, s2 in
						try s1.merge(s2, onConflict: onConflict)
					}
					return .interior(
						branches: merged,
						payload: leftPayloadOrNil
					)
				}
				else
				{
					// Both trees had payloads, so resolve the conflict during
					// the merge.
					let payload = try onConflict(
						leftPayloadOrNil!,
						rightPayloadOrNil!
					)
					var merged = b1
					try merged.merge(b2) { s1, s2 in
						try s1.merge(s2, onConflict: onConflict)
					}
					return .interior(branches: merged, payload: payload)
				}
		}
	}

	/// Build a prefix tree corresponding to the specified iterator that
	/// culminates in the supplied payload.
	///
	/// - Parameters:
	///   - iterator: The iterator that culminates in the specified payload.
	///   - payload: The payload to install.
	/// - Returns: The requested prefix tree.
	static func build<T, I, P> (
		iterator: inout I,
		payload: P
	) -> PrefixTree<T, P>
		where I: IteratorProtocol, I.Element == T
	{
		if let componentOrNil = iterator.next()
		{
			return .interior(
				branches: [
					componentOrNil : .build(
						iterator: &iterator,
						payload: payload
				)],
				payload: nil
			)
		}
		else
		{
			return .leaf(payload: payload)
		}
	}
	
	/// Build a prefix tree corresponding to the specified path that culminates in
	/// the
	/// supplied payload.
	///
	/// - Parameters:
	///   - path: The path that culminates in the specified payload.
	///   - payload: The payload to install.
	/// - Returns: The requested prefix tree.
	static func build<T, I, S, P> (path: S, payload: P) -> PrefixTree<T, P>
		where I.Element == T, S: Sequence, S.Iterator == I
	{
		var iterator: I = path.makeIterator()
		return PrefixTree<T, P>.build(
			iterator: &iterator,
			payload: payload
		)
	}

	/// Build a complete prefix tree given the specified map from keys to values.
	///
	/// - Parameters:
	///   - paths: A `Dictionary` that is semantically equivalent to the
	///     desired prefix tree.
	static func build<T, I, P> (allPaths paths: [I : P]) -> PrefixTree<T, P>
		where I: Sequence, I.Element == T
	{
		paths.reduce(PrefixTree<T, P>.empty) { tree, entry in
			tree.merge(.build(path: entry.key, payload: entry.value))
			{ (_old: P, new: P) in
				// This is actually unreachable, as the incoming map cannot
				// have duplicate keys, by definition.
				new
			}
		}
	}
}

extension PrefixTree.PositionedPayload: Equatable where P: Equatable
{
	static func == (
		lhs: PrefixTree.PositionedPayload<P>,
		rhs: PrefixTree.PositionedPayload<P>
	) -> Bool
	{
		lhs.payload == rhs.payload && lhs.position == rhs.position
	}
}

extension PrefixTree: Equatable
where T: Hashable, P: Equatable
{
	static func == (lhs: PrefixTree<T, P>, rhs: PrefixTree<T, P>) -> Bool
	{
		switch (lhs, rhs)
		{
			case (.empty, .empty):
				return true
			case let (.interior(b1, p1), .interior(b2, p2)):
				return b1 == b2 && p1 == p2
			case let (.leaf(p1), .leaf(p2)):
				return p1 == p2
			default:
				return false
		}
	}
}

extension PrefixTree: CustomStringConvertible
where T: CustomStringConvertible & Comparable, P: CustomStringConvertible
{
	/// Stringify the receiver.
	///
	/// - Parameters:
	///   - out: The accumulator.
	///   - level: The level of indentation. Defaults to 0.
	///   - indent: The indentation. Defaults to "\t".
	func stringifyOn (
		_ out: inout TextOutputStream,
		level: Int = 0,
		indent: String = "\t"
	)
	{
		out.write(String(repeating: indent, count: level))
		switch self
		{
			case .empty:
				out.write("- «empty tree»\n")
			case let .interior(branches: branches, payload: payload):
				out.write("* \(payload?.description ?? "«nil»")\n")
				branches.sorted { $0.key < $1.key }.forEach { (key, tree) in
					out.write(String(repeating: indent, count: level))
					out.write("- \(key):\n")
					tree.stringifyOn(&out, level: level + 1, indent: indent)
				}
			case let .leaf(payload: payload):
				out.write("* \(payload.description)\n")
		}
	}
	
	internal var description: String
	{
		get
		{
			var desc: TextOutputStream = ""
			self.stringifyOn(&desc)
			return desc as! String
		}
	}
}
