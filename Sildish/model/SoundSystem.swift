//
//  SoundSystem.swift
//  sildish
//
//  Created by Todd L Smith on 7/30/20.
//  Copyright © 2020 Todd L Smith. All rights reserved.
//

import Foundation

/// The grapheme set for a phoneme.
enum GraphemeSet: Equatable
{
	/// The tagged phoneme is a simple vowel.
	///
	/// There are two variants.
	/// * `standard` has a full bar.
	/// * `withoutBar` has no bar, and is suitable for initial or final display.
	case vowel (standard: String, withoutBar: String)
	
	/// The tagged phoneme is a diphthong.
	///
	/// There are two variants.
	/// * `standard` has a full bar.
	/// * `withoutBar` has no bar, and is suitable for initial or final display.
	case diphthong (standard: String, withoutBar: String)
	
	/// The tagged phoneme is a nonreduplicable consonant.
	///
	/// There are three variants.
	/// * `standard` has a full bar.
	/// * `initial` has a bar to the right of the tether.
	/// * `final` has a bar to the left of the tether.
	case consonant (standard: String, initial: String, final: String)
	
	/// The tagged phoneme is a reduplicable consonant.
	///
	/// There are six variants.
	/// * `standard` has a full bar.
	/// * `initial` has a bar to the right of the tether.
	/// * `final` has a bar to the left of the tether.
	/// * `reduplicated` has a full bar.
	/// * `initialReduplicated` has a bar to the right of the tether.
	/// * `finalReduplicated` has a bar to the left of the tether.
	case reduplicableConsonant (
		standard: String,
		initial: String,
		final: String,
		reduplicated: String,
		initialReduplicated: String,
		finalReduplicated: String
	)
}

/// The schematic information pertainiing to a particular phoneme.
struct PhonemeData: Equatable
{
	/// The transliteration of the phoneme into the Roman alphabet.
	let roman: String
	
	/// The pronunciation of the phoneme, as an IPA string.
	let pronunciation: String
	
	/// All graphemes associated with the phoneme.
	let graphemeSet: GraphemeSet
	
	static func == (lhs: PhonemeData, rhs: PhonemeData) -> Bool {
		lhs.roman == rhs.roman
			&& lhs.pronunciation == rhs.pronunciation
			&& lhs.graphemeSet == rhs.graphemeSet
	}
}

/// A phonetic element.
protocol PhoneticElement: Identifiable
{
	/// Answer the appropriate phoneme data.
	var phonemeData: PhonemeData { get }
}

/// The phonemes of the Sildish language.
enum Phoneme: CaseIterable, PhoneticElement
{
	case y
	case i
	case e
	case a
	case o
	case u
	case ei
	case ae
	case oi
	case ui
	case eu
	case au
	case m
	case n
	case ng
	case p
	case b
	case t
	case d
	case c
	case g
	case f
	case v
	case th
	case dh
	case s
	case z
	case sh
	case zh
	case ch
	case h
	case hw
	case w
	case j
	case r
	case rh
	case l

	/// A phoneme is its own identifier.
	var id: Phoneme { self }
	
	/// The phoneme data for this phoneme.
	public var phonemeData: PhonemeData
	{
		get
		{
			switch self
			{
				case .y: return PhonemeData(
					roman: "y",
					pronunciation: "i",
					graphemeSet: GraphemeSet.vowel(
						standard: "\u{E000}",
						withoutBar: "\u{E040}"
					)
				)
				case .i: return PhonemeData(
					roman: "i",
					pronunciation: "ɪ",
					graphemeSet: GraphemeSet.vowel(
						standard: "\u{E001}",
						withoutBar: "\u{E041}"
					)
				)
				case .e: return PhonemeData(
					roman: "e",
					pronunciation: "ɛ",
					graphemeSet: GraphemeSet.vowel(
						standard: "\u{E002}",
						withoutBar: "\u{E042}"
					)
				)
				case .a: return PhonemeData(
					roman: "a",
					pronunciation: "a",
					graphemeSet: GraphemeSet.vowel(
						standard: "\u{E003}",
						withoutBar: "\u{E043}"
					)
				)
				case .o: return PhonemeData(
					roman: "o",
					pronunciation: "o",
					graphemeSet: GraphemeSet.vowel(
						standard: "\u{E004}",
						withoutBar: "\u{E044}"
					)
				)
				case .u: return PhonemeData(
					roman: "u",
					pronunciation: "u",
					graphemeSet: GraphemeSet.vowel(
						standard: "\u{E005}",
						withoutBar: "\u{E045}"
					)
				)
				case .ei: return PhonemeData(
					roman: "ei",
					pronunciation: "ɛi",
					graphemeSet: GraphemeSet.diphthong(
						standard: "\u{E008}",
						withoutBar: "\u{E048}"
					)
				)
				case .ae: return PhonemeData(
					roman: "ae",
					pronunciation: "ai",
					graphemeSet: GraphemeSet.diphthong(
						standard: "\u{E009}",
						withoutBar: "\u{E049}"
					)
				)
				case .oi: return PhonemeData(
					roman: "oi",
					pronunciation: "oi",
					graphemeSet: GraphemeSet.diphthong(
						standard: "\u{E00A}",
						withoutBar: "\u{E04A}"
					)
				)
				case .ui: return PhonemeData(
					roman: "ui",
					pronunciation: "ui",
					graphemeSet: GraphemeSet.diphthong(
						standard: "\u{E00B}",
						withoutBar: "\u{E04B}"
					)
				)
				case .eu: return PhonemeData(
					roman: "eu",
					pronunciation: "ɛu",
					graphemeSet: GraphemeSet.diphthong(
						standard: "\u{E026}",
						withoutBar: "\u{E066}"
					)
				)
				case .au: return PhonemeData(
					roman: "au",
					pronunciation: "au",
					graphemeSet: GraphemeSet.diphthong(
						standard: "\u{E027}",
						withoutBar: "\u{E067}"
					)
				)
				case .m: return PhonemeData(
					roman: "m",
					pronunciation: "m",
					graphemeSet: GraphemeSet.reduplicableConsonant(
						standard: "\u{E101}",
						initial: "\u{E201}",
						final: "\u{E301}",
						reduplicated: "\u{E401}",
						initialReduplicated: "\u{E501}",
						finalReduplicated: "\u{E601}"
					)
				)
				case .n: return PhonemeData(
					roman: "n",
					pronunciation: "n",
					graphemeSet: GraphemeSet.reduplicableConsonant(
						standard: "\u{E107}",
						initial: "\u{E207}",
						final: "\u{E307}",
						reduplicated: "\u{E407}",
						initialReduplicated: "\u{E507}",
						finalReduplicated: "\u{E607}"
					)
				)
				case .ng: return PhonemeData(
					roman: "ng",
					pronunciation: "ŋ",
					graphemeSet: GraphemeSet.consonant(
						standard: "\u{E10D}",
						initial: "\u{E20D}",
						final: "\u{E30D}"
					)
				)
				case .p: return PhonemeData(
					roman: "p",
					pronunciation: "p",
					graphemeSet: GraphemeSet.reduplicableConsonant(
						standard: "\u{E110}",
						initial: "\u{E210}",
						final: "\u{E310}",
						reduplicated: "\u{E410}",
						initialReduplicated: "\u{E510}",
						finalReduplicated: "\u{E610}"
					)
				)
				case .b: return PhonemeData(
					roman: "b",
					pronunciation: "b",
					graphemeSet: GraphemeSet.reduplicableConsonant(
						standard: "\u{E111}",
						initial: "\u{E211}",
						final: "\u{E311}",
						reduplicated: "\u{E411}",
						initialReduplicated: "\u{E511}",
						finalReduplicated: "\u{E611}"
					)
				)
				case .t: return PhonemeData(
					roman: "t",
					pronunciation: "t",
					graphemeSet: GraphemeSet.reduplicableConsonant(
						standard: "\u{E116}",
						initial: "\u{E216}",
						final: "\u{E316}",
						reduplicated: "\u{E416}",
						initialReduplicated: "\u{E516}",
						finalReduplicated: "\u{E616}"
					)
				)
				case .d: return PhonemeData(
					roman: "d",
					pronunciation: "d",
					graphemeSet: GraphemeSet.reduplicableConsonant(
						standard: "\u{E117}",
						initial: "\u{E217}",
						final: "\u{E317}",
						reduplicated: "\u{E417}",
						initialReduplicated: "\u{E517}",
						finalReduplicated: "\u{E617}"
					)
				)
				case .c: return PhonemeData(
					roman: "c",
					pronunciation: "k",
					graphemeSet: GraphemeSet.reduplicableConsonant(
						standard: "\u{E11C}",
						initial: "\u{E21C}",
						final: "\u{E31C}",
						reduplicated: "\u{E41C}",
						initialReduplicated: "\u{E51C}",
						finalReduplicated: "\u{E61C}"
					)
				)
				case .g: return PhonemeData(
					roman: "g",
					pronunciation: "g",
					graphemeSet: GraphemeSet.reduplicableConsonant(
						standard: "\u{E11D}",
						initial: "\u{E21D}",
						final: "\u{E31D}",
						reduplicated: "\u{E41D}",
						initialReduplicated: "\u{E51D}",
						finalReduplicated: "\u{E61D}"
					)
				)
				case .f: return PhonemeData(
					roman: "f",
					pronunciation: "f",
					graphemeSet: GraphemeSet.consonant(
						standard: "\u{E122}",
						initial: "\u{E222}",
						final: "\u{E322}"
					)
				)
				case .v: return PhonemeData(
					roman: "v",
					pronunciation: "v",
					graphemeSet: GraphemeSet.consonant(
						standard: "\u{E123}",
						initial: "\u{E223}",
						final: "\u{E323}"
					)
				)
				case .th: return PhonemeData(
					roman: "th",
					pronunciation: "θ",
					graphemeSet: GraphemeSet.consonant(
						standard: "\u{E124}",
						initial: "\u{E224}",
						final: "\u{E324}"
					)
				)
				case .dh: return PhonemeData(
					roman: "dh",
					pronunciation: "ð",
					graphemeSet: GraphemeSet.consonant(
						standard: "\u{E125}",
						initial: "\u{E225}",
						final: "\u{E325}"
					)
				)
				case .s: return PhonemeData(
					roman: "s",
					pronunciation: "s",
					graphemeSet: GraphemeSet.reduplicableConsonant(
						standard: "\u{E126}",
						initial: "\u{E226}",
						final: "\u{E326}",
						reduplicated: "\u{E426}",
						initialReduplicated: "\u{E526}",
						finalReduplicated: "\u{E626}"
					)
				)
				case .z: return PhonemeData(
					roman: "z",
					pronunciation: "z",
					graphemeSet: GraphemeSet.consonant(
						standard: "\u{E127}",
						initial: "\u{E227}",
						final: "\u{E327}"
					)
				)
				case .sh: return PhonemeData(
					roman: "sh",
					pronunciation: "ʃ",
					graphemeSet: GraphemeSet.consonant(
						standard: "\u{E128}",
						initial: "\u{E228}",
						final: "\u{E328}"
					)
				)
				case .zh: return PhonemeData(
					roman: "zh",
					pronunciation: "ʒ",
					graphemeSet: GraphemeSet.consonant(
						standard: "\u{E129}",
						initial: "\u{E229}",
						final: "\u{E329}"
					)
				)
				case .ch: return PhonemeData(
					roman: "ch",
					pronunciation: "x",
					graphemeSet: GraphemeSet.consonant(
						standard: "\u{E12C}",
						initial: "\u{E22C}",
						final: "\u{E32C}"
					)
				)
				case .h: return PhonemeData(
					roman: "h",
					pronunciation: "h",
					graphemeSet: GraphemeSet.consonant(
						standard: "\u{E12E}",
						initial: "\u{E22E}",
						final: "\u{E32E}"
					)
				)
				case .hw: return PhonemeData(
					roman: "hw",
					pronunciation: "ʍ",
					graphemeSet: GraphemeSet.consonant(
						standard: "\u{E130}",
						initial: "\u{E230}",
						final: "\u{E330}"
					)
				)
				case .w: return PhonemeData(
					roman: "w",
					pronunciation: "w",
					graphemeSet: GraphemeSet.consonant(
						standard: "\u{E131}",
						initial: "\u{E231}",
						final: "\u{E331}"
					)
				)
				case .j: return PhonemeData(
					roman: "j",
					pronunciation: "j",
					graphemeSet: GraphemeSet.consonant(
						standard: "\u{E13B}",
						initial: "\u{E23B}",
						final: "\u{E33B}"
					)
				)
				case .r: return PhonemeData(
					roman: "r",
					pronunciation: "ɾ",
					graphemeSet: GraphemeSet.consonant(
						standard: "\u{E147}",
						initial: "\u{E247}",
						final: "\u{E347}"
					)
				)
				case .rh: return PhonemeData(
					roman: "rh",
					pronunciation: "r",
					graphemeSet: GraphemeSet.consonant(
						standard: "\u{E157}",
						initial: "\u{E257}",
						final: "\u{E357}"
					)
				)
				case .l: return PhonemeData(
					roman: "l",
					pronunciation: "l",
					graphemeSet: GraphemeSet.reduplicableConsonant(
						standard: "\u{E167}",
						initial: "\u{E267}",
						final: "\u{E367}",
						reduplicated: "\u{E467}",
						initialReduplicated: "\u{E567}",
						finalReduplicated: "\u{E667}"
					)
				)
			}
		}
	}
	
	/// Answer all simple vowels.
	public static var allSimpleVowels: [Phoneme]
	{
		Phoneme.allCases.filter { x in
			switch x.phonemeData.graphemeSet
			{
				case .vowel:
					return true
				default:
					return false
			}
		}
	}
	
	/// Answer all diphthongs.
	public static var allDiphthongs: [Phoneme]
	{
		Phoneme.allCases.filter { x in
			switch x.phonemeData.graphemeSet
			{
				case .diphthong:
					return true
				default:
					return false
			}
		}
	}
	
	/// Answer all vowels and diphthongs.
	public static var allVowels: [Phoneme]
	{
		Phoneme.allCases.filter { x in
			switch x.phonemeData.graphemeSet
			{
				case .vowel, .diphthong:
					return true
				default:
					return false
			}
		}
	}

	/// Answer all nonreduplicable consonants.
	public static var allNonreduplicableConsonants: [Phoneme]
	{
		Phoneme.allCases.filter { x in
			switch x.phonemeData.graphemeSet
			{
				case .consonant:
					return true
				default:
					return false
			}
		}
	}

	/// Answer all reduplicable consonants.
	public static var allReduplicableConsonants: [Phoneme]
	{
		Phoneme.allCases.filter { x in
			switch x.phonemeData.graphemeSet
			{
				case .reduplicableConsonant:
					return true
				default:
					return false
			}
		}
	}

	/// Answer all consonants.
	public static var allConsonants: [Phoneme]
	{
		Phoneme.allCases.filter { x in
			switch x.phonemeData.graphemeSet
			{
				case .consonant, .reduplicableConsonant:
					return true
				default:
					return false
			}
		}
	}
}

/// The phoneme clusters of the Sildish language.
enum PhonemeCluster: CaseIterable, PhoneticElement
{
	case q
	case x
	
	/// A phoneme cluster is its own identifier.
	var id: PhonemeCluster { self }

	/// The phoneme data for this phoneme.
	public var phonemeData: PhonemeData
	{
		get
		{
			switch self
			{
				case .q: return PhonemeData(
					roman: "q",
					pronunciation: "kw",
					graphemeSet: GraphemeSet.consonant(
						standard: "\u{E11C}\u{E131}",
						initial: "\u{E21C}\u{E131}",
						final: "\u{E11C}\u{E331}"
					)
				)
				case .x: return PhonemeData(
					roman: "x",
					pronunciation: "ks",
					graphemeSet: GraphemeSet.consonant(
						standard: "\u{E11C}\u{E126}",
						initial: "\u{E21C}\u{E126}",
						final: "\u{E11C}\u{E326}"
					)
				)
			}
		}
	}
}

/// The Sildish capital mark. It initiates a bar at the start of a word.
let sildishCapitalMark = "\u{EA00}"

/// The Roman transliterations of Sildish vowels.
let romanSildishVowels: Set<Character> =
	Set(
		Phoneme.allCases
			.filter { x in
				switch x.phonemeData.graphemeSet
				{
					case .vowel, .diphthong:
						return true
					default:
						return false
				}
			}
			.flatMap { x in x.phonemeData.roman }
	).union(
		PhonemeCluster.allCases
			.filter { x in
				switch x.phonemeData.graphemeSet
				{
					case .vowel, .diphthong:
						return true
					default:
						return false
				}
			}
			.flatMap { x in x.phonemeData.roman }
	)

/// The Roman transliterations of Sildish consonants.
let romanSildishConsonants: Set<Character> =
	Set(
		Phoneme.allCases
			.filter { x in
				switch x.phonemeData.graphemeSet
				{
					case .consonant, .reduplicableConsonant:
						return true
					default:
						return false
				}
			}
			.flatMap { x in x.phonemeData.roman }
	).union(
		PhonemeCluster.allCases
			.filter { x in
				switch x.phonemeData.graphemeSet
				{
					case .consonant, .reduplicableConsonant:
						return true
					default:
						return false
				}
			}
			.flatMap { x in x.phonemeData.roman }
	)

extension Character
{
	/// Is the receiver a Roman transliteration of a Sildish character?
	///
	/// - Returns: `true` iff the receiver is a Sildish character.
	var isSildish: Bool
	{
		isSildishVowel || isSildishConsonant
	}
	
	/// Is the receiver a Roman tranliteration of a Sildish vowel?
	///
	/// - Returns: `true` iff the receiver is a Sildish vowel.
	var isSildishVowel: Bool
	{
		romanSildishVowels.contains(self.lowercased().first!)
	}

	/// Is the receiver a Roman tranliteration of a Sildish consonant?
	///
	/// - Returns: `true` iff the receiver is a Sildish consonant.
	var isSildishConsonant: Bool
	{
		romanSildishConsonants.contains(self.lowercased().first!)
	}
}
