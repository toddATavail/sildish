//
//  Transliteration.swift
//  sildish
//
//  Created by Todd L Smith on 8/9/20.
//  Copyright © 2020 Todd L Smith. All rights reserved.
//

import Foundation

/// The Roman-to-Sildish transliterator. The tree is constructed in such a way
/// that two entries are created for each reduplicable consonant — a
/// nonreduplicated entry with a .consonant payload and a reduplicated entry with
/// a .reduplicatedConsonant payload. This keeps the transliteration algorithm
/// for medials simple and uniform.
internal let romanToSildish =
	try! PrefixTree<Character, PhonemeData>.build(allPaths:
		Dictionary(uniqueKeysWithValues:
			Phoneme.allVowels
				.map { x in (x.phonemeData.roman, x.phonemeData) }
		)
	).merge(
		PrefixTree<Character, PhonemeData>.build(allPaths:
			Dictionary(uniqueKeysWithValues:
				Phoneme.allConsonants
					.map { (x: Phoneme) -> (String, PhonemeData) in
						let data: PhonemeData = x.phonemeData
						let graphemeSet = data.graphemeSet
						switch graphemeSet
						{
							case let .consonant(
									standard,
									initial,
									final),
								 let .reduplicableConsonant(
									standard,
									initial,
									final,
									_, _, _):
								return (
									data.roman,
									PhonemeData(
										roman: data.roman,
										pronunciation: data.pronunciation,
										graphemeSet: .consonant(
											standard: standard,
											initial: initial,
											final: final)
									)
								)
							default:
								assert(false)
						}
					}
			)
		)
	).merge(
		PrefixTree<Character, PhonemeData>.build(allPaths:
			Dictionary(uniqueKeysWithValues:
				Phoneme.allReduplicableConsonants
					.map { x in (
						String(repeating: x.phonemeData.roman, count: 2),
						x.phonemeData
					) }
			)
		)
	).merge(
		PrefixTree<Character, PhonemeData>.build(allPaths:
			Dictionary(uniqueKeysWithValues:
				PhonemeCluster.allCases
					.map { x in (x.phonemeData.roman, x.phonemeData) }
			)
		)
	)

/// The longest Roman transliteration of a Sildish vowel.
private let longestRomanVowel =
	Phoneme.allVowels
		.max { $0.phonemeData.roman.count < $1.phonemeData.roman.count }!
		.phonemeData.roman.count

/// The longest Roman transliteration of a Sildish consonant.
private let longestRomanConsonant =
	Phoneme.allConsonants
		.max { $0.phonemeData.roman.count > $1.phonemeData.roman.count }!
		.phonemeData.roman.count

/// Transliterate the specified region of a Romanized Sildish word to Sildish.
///
/// - Parameters:
///   - region: The region to transliterate to Sildish.
///   - longestRomanization: The longest path through the transliteration tree
///     to support this transliteration.
///   - selector: The function to apply to the `GraphemeSet` (obtained by
///     tranliteration) to select an appropriate variant of the Sildish character.
///     The first `Bool` is `true` iff `selector` is being called for the first
///     time; the second `Bool` is `true` iff `selector` is being called for the
///     last time.
/// - Returns: The transliteration.
private func transliterateToSildish <T: Sequence> (
	region: T,
	longestRomanization: Int,
	selector: (GraphemeSet, Bool, Bool) -> String
) -> String
	where T.Element == Character
{
	var sildish = ""
	var first = true
	var iter = region.makeIterator()
	// The buffer holds untransliterated characters. It should try to keep as
	// many characters buffered as the longest path through the transliteration
	// tree, in order to process diphthongs and clusters correctly. Toward the
	// end of the loop, untransliterated characters may not be plentiful enough
	// to keep the buffer full; this is fine, as it just means that there can't
	// be any untransliterated diphthongs or clusters remaining to be
	// discovered.
	var buffer = (0 ..< longestRomanization).compactMap { _ in iter.next() }
	while !buffer.isEmpty
	{
		// Obtain all payloads along the path specified by the buffer. Grab the
		// rightmost payload, and use its position to decide 1) how many
		// characters to eject from the buffer's prefix and therefore 2) how
		// many characters to append to the buffer.
		let payload = romanToSildish.allPayloads(along: buffer).last!
		buffer = Array(buffer[payload.position ..< buffer.count])
		buffer += (0 ..< payload.position).compactMap { _ in iter.next() }
		sildish += selector(payload.payload.graphemeSet, first, buffer.isEmpty)
		first = false
	}
	return sildish
}

/// Transliterate the specified nonmedial vowels to Sildish. They will be
/// rendered without an overbar.
///
/// - Parameters:
///   - vowels: The nonmedial vowels to transliterate to Sildish.
/// - Returns: The transliteration.
internal func transliterateToSildish <T: Sequence> (
	nonmedialVowels vowels: T
) -> String
	where T.Element == Character
{
	assert(vowels.allSatisfy { $0.isSildishVowel})
	return transliterateToSildish(
		region: vowels,
		longestRomanization: longestRomanVowel
	) { graphemeSet, _, _ in
		switch graphemeSet
		{
			case .vowel(_, let withoutBar), .diphthong(_, let withoutBar):
				return withoutBar
			default:
				assert(false, "should be unreachable")
		}
	}
}

/// Transliterate the specified medials Sildish. They will be rendered with an
/// overbar, and reduplicated as appropriate.
///
/// - Parameters:
///   - medials: The medials to transliterate to Sildish.
///   - isCapitalized: Whether the enclosing word is capitalized. Capitalization
///     suppresses bar attachment initiation of an initial medial consonant.
/// - Returns: The transliteration.
internal func transliterateToSildish <T: Sequence> (
	medials: T,
	isCapitalized: Bool = false
) -> String
	where T.Element == Character
{
	return transliterateToSildish(
		region: medials,
		longestRomanization: max(longestRomanVowel, longestRomanConsonant)
	) { graphemeSet, isFirst, isLast in
		switch graphemeSet
		{
			case .vowel(let standard, _), .diphthong(let standard, _):
				return standard
			case .consonant(_, let start, _)
					where isFirst && !isCapitalized,
				 .reduplicableConsonant(_, _, _, _, let start, _)
					where isFirst && !isCapitalized:
				return start
			case .consonant(_, _, let end) where isLast,
				 .reduplicableConsonant(_, _, _, _, _, let end) where isLast:
				return end
			case .consonant(let standard, _, _),
				 .reduplicableConsonant(_, _, _, let standard, _, _):
				return standard
		}
	}
}

/// Transliterate the argument into Sildish.
///
/// - Parameters:
///   - seq: The sequence to transliterate.
/// - Returns: The result of transliteration.
func transliterateToSildish <T: Sequence> (_ seq: T) -> String
	where T.Element == Character
{
	// Accumulators.
	var sildish = ""
	
	// The iterator, current character, and advancer. The advancer answers true
	// if the iterator produces a value, and false if it is exhausted.
	var iter = seq.makeIterator()
	var cOrNil = iter.next()
	var c: Character = "\0"
	let advance = { () -> Bool in
		cOrNil = iter.next()
		if let x = cOrNil
		{
			c = x.lowercased().first!
			return true
		}
		return false
	}

	// Loop through all words, transliterating them to Sildish;
	// untransliteratable characters will be copied to the output verbatim.
	while cOrNil != nil
	{
		var capital = ""
		var leadingVowels = ""
		var unclassified = ""
		var medials = ""
		var trailingVowels = ""
		var consonantCount = 0

		// This is the only position in the loop where `c` is not normalized to
		// lowercase.
		c = cOrNil!

		if c.isUppercase
		{
			// The first character is uppercase, so insert a capital mark.
			// The capital mark establishes the overbar, so begin processing
			// medial characters. Do not advance the iterator; we still need to
			// capture the (lowercased) version of the initial character.
			capital = sildishCapitalMark
		}

		// Lowercase the character, as all forward paths need lowercased
		// characters.
		c = c.lowercased().first!

		if (capital.isEmpty)
		{
			// The initial character was not capitalized, so start accumulating
			// leading vowels.
			while true
			{
				if c.isSildishVowel
				{
					// Found a vowel, so accumulate it. Advance the iterator.
					leadingVowels += [c]
					if advance()
					{
						continue
					}
				}
				// The character is not a vowel, so abort the loop and start
				// looking for medials.
				break
			}
		}
		
		// Process medials. First accumulate them into `unclassified`, then flip
		// them to `medials` whenever we discover a consonant. That consonant
		// must remain unclassified until we discover 1) another consonant or
		// 2) an untransliteratable character.
		while cOrNil != nil
		{
			switch c
			{
				case let x where c.isSildishConsonant:
					// Found a consonant, so flip `unclassifieds` to `medials`.
					// Advance the iterator. Check whether the next character is
					// also a consonant, and whether they are a digraph
					// representing a phoneme; if so, keep them together in
					// `unclassifieds`. The resultant consonant may be the final
					// consonant of the word, which we won't discover until
					// later.
					medials += unclassified
					unclassified = String(c)
					consonantCount += 1
					if advance()
					{
						if
							c.isSildishConsonant,
							case .consonant =
								romanToSildish[String([x, c])]?.graphemeSet
						{
							// The digraph is a nonredublicable consonant. We
							// deal with reduplicable consonants in the next
							// iteration of the loop, and each occurrence
							// contributes toward the consonant count.
							unclassified += [c]
							if !advance()
							{
								break
							}
						}
						continue
					}
				case _ where c.isSildishVowel:
					// Found a vowel, so add it to unclassified. Advance the
					// iterator.
					unclassified += [c]
					if advance()
					{
						continue
					}
				default:
					break
			}
			// Found an untransliteratable character.
			if let first = unclassified.first
			{
				if first.isSildishConsonant
				{
					// The first unclassified character is a consonant,
					// so it should terminate the overbar; flip the leading
					// consonant to `medials`, taking special care with
					// digraphs. All remaining unclassified are vowels. If this
					// is the only consonant, then flip the vowels to
					// `medials`; otherwise, flip them to `trailingVowels`.
					let leadingConsonants =
						String(unclassified.prefix { $0.isSildishConsonant })
					medials += leadingConsonants
					unclassified = String(
						unclassified.suffix(
							unclassified.count - leadingConsonants.count
						)
					)
					if consonantCount == 1
					{
						medials += unclassified
					}
					else
					{
						trailingVowels = unclassified
					}
					unclassified = ""
				}
				else
				{
					// The first unclassified character is a vowel. This
					// is only possible if 1) the word is capitalized
					// and 2) the word comprises vowels exclusively.
					// Flip `unclassifieds` to `medials`.
					medials += unclassified
					unclassified = ""
				}
			}
			else
			{
				// There are no unclassified, so the word is entirely
				// vocalic and uncapitalized. Do nothing — no special
				// handling is required.
				assert(unclassified.isEmpty)
				assert(medials.isEmpty)
				assert(leadingVowels.allSatisfy { v in
					v.isSildishVowel
				})
			}
			// Found an untransliteratable character, so we have finished
			// processing the word. Break the loop.
			break
		}
		
		// All characters have been classified, and the word has been regioned
		// into leading vowels, medials, and trailing vowels.
		assert(unclassified.isEmpty)
		
		// Transliteration is straightforward at this point.
		sildish += capital
		sildish += transliterateToSildish(nonmedialVowels: leadingVowels)
		sildish += transliterateToSildish(
			medials: medials,
			isCapitalized: !capital.isEmpty
		)
		sildish += transliterateToSildish(nonmedialVowels: trailingVowels)
		
		// Copy over untransliteratable characters verbatim.
		while !c.isSildish
		{
			sildish += String(c)
			cOrNil = iter.next()
			if let x = cOrNil
			{
				c = x
				continue
			}
			// We have exhausted all input.
			break
		}
		
		// We are finished processing a word, and possibly finished processing
		// all input. Let the loop predicate decide.
	}
	
	// We are finished processing all input; everything has been transliterated
	// or copied verbatim to `sildish`.
	return sildish
}

/// Implementors should be capable of transliterating themselves into Sildish.
protocol TransliteratableToSildish
{
	/// Transliterate the receiver into Sildish.
	///
	/// - Returns: The result of transliteration.
	var sildish: String { get }
}

extension Sequence
	where Self: TransliteratableToSildish, Element == Character
{
	/// Transliterate the receiver into Sildish.
	///
	/// - Returns: The result of transliteration.
	var sildish: String
	{
		transliterateToSildish(self)
	}
}

extension String: TransliteratableToSildish
{
	// No implementation required.
}
