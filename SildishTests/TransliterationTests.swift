//
//  TransliterationTests.swift
//  sildish
//
//  Created by Todd L Smith on 8/10/20.
//  Copyright © 2020 Todd L Smith. All rights reserved.
//

import XCTest
@testable import Sildish

class TransliterationTests: XCTestCase
{
	/// Verify the construction of the transliteration tree.
	func testTransliterationTree ()
	{
		// Check all paths exhaustively.
		Phoneme.allVowels.forEach {
			XCTAssertEqual(romanToSildish[$0.phonemeData.roman], $0.phonemeData)
		}
		Phoneme.allNonreduplicableConsonants.forEach {
			XCTAssertEqual(romanToSildish[$0.phonemeData.roman], $0.phonemeData)
		}
		Phoneme.allReduplicableConsonants.forEach {
			XCTAssertEqual(
				romanToSildish[
					String(repeating: $0.phonemeData.roman, count: 2)
				],
				$0.phonemeData)
		}
		PhonemeCluster.allCases.forEach {
			XCTAssertEqual(romanToSildish[$0.phonemeData.roman], $0.phonemeData)
		}
	}
	
	/// Verify transliteration of nonmedial vowels to Sildish.
	func testTransliterateNonmedialVowelsToSildish ()
	{
		// Test the empty case.
		XCTAssertEqual(transliterateToSildish(nonmedialVowels: ""), "")
		
		// Check all of the vowels individually.
		Phoneme.allVowels.forEach {
			let phonemeData = $0.phonemeData
			var withoutBar: String = ""
			switch phonemeData.graphemeSet
			{
				case .vowel(_, let noBar), .diphthong(_, let noBar):
					withoutBar = noBar
				default:
					XCTFail()
			}
			XCTAssertEqual(
				transliterateToSildish(nonmedialVowels: $0.phonemeData.roman),
				withoutBar
			)
		}
		
		// Check a few multi-character cases manually.
		XCTAssertEqual(
			transliterateToSildish(nonmedialVowels: "yieaou"),
			"\u{E040}\u{E041}\u{E042}\u{E043}\u{E044}\u{E045}"
		)
		XCTAssertEqual(
			transliterateToSildish(nonmedialVowels: "uoaeiy"),
			"\u{E045}\u{E044}\u{E049}\u{E041}\u{E040}"
		)
		XCTAssertEqual(
			transliterateToSildish(nonmedialVowels: "aeei"),
			"\u{E049}\u{E048}"
		)
		XCTAssertEqual(
			transliterateToSildish(nonmedialVowels: "aeiei"),
			"\u{E049}\u{E041}\u{E048}"
		)
		XCTAssertEqual(
			transliterateToSildish(nonmedialVowels: "eioa"),
			"\u{E048}\u{E044}\u{E043}"
		)
		XCTAssertEqual(
			transliterateToSildish(nonmedialVowels: "eoia"),
			"\u{E042}\u{E04A}\u{E043}"
		)
		XCTAssertEqual(
			transliterateToSildish(nonmedialVowels: "ieiu"),
			"\u{E041}\u{E048}\u{E045}"
		)
		XCTAssertEqual(
			transliterateToSildish(nonmedialVowels: "eiui"),
			"\u{E048}\u{E04B}"
		)
	}
	
	/// Verify transliteration of medials to Sildish.
	func testTransliterateMedialsToSildish ()
	{
		// Test the empty case.
		XCTAssertEqual(transliterateToSildish(medials: ""), "")

		// Check all of the medials individually.
		Phoneme.allCases.forEach {
			let phonemeData = $0.phonemeData
			var output: String = ""
			switch phonemeData.graphemeSet
			{
				case .vowel(let out, _),
					 .diphthong(let out, _),
					 .consonant(_, let out, _),
					 .reduplicableConsonant(_, let out, _, _, _, _):
					output = out
			}
			XCTAssertEqual(
				transliterateToSildish(medials: $0.phonemeData.roman),
				output
			)
		}
		Phoneme.allCases.forEach {
			let phonemeData = $0.phonemeData
			var output: String = ""
			switch phonemeData.graphemeSet
			{
				case .vowel(let out, _),
					 .diphthong(let out, _),
					 .consonant(_, _, let out),
					 .reduplicableConsonant(_, _, let out, _, _, _):
					output = out
			}
			XCTAssertEqual(
				transliterateToSildish(
					medials: $0.phonemeData.roman,
					isCapitalized: true
				),
				output
			)
		}

		// Check all of the reduplications individually.
		Phoneme.allReduplicableConsonants.forEach {
			let phonemeData = $0.phonemeData
			var output: String = ""
			switch phonemeData.graphemeSet
			{
				case .reduplicableConsonant(_, _, _, _, let out, _):
					output = out
				default:
					XCTFail()
			}
			XCTAssertEqual(
				transliterateToSildish(
					medials: String(repeating: $0.phonemeData.roman, count: 2)
				),
				output
			)
		}
		Phoneme.allReduplicableConsonants.forEach {
			let phonemeData = $0.phonemeData
			var output: String = ""
			switch phonemeData.graphemeSet
			{
				case .reduplicableConsonant(_, _, _, _, _, let out):
					output = out
				default:
					XCTFail()
			}
			XCTAssertEqual(
				transliterateToSildish(
					medials: String(repeating: $0.phonemeData.roman, count: 2),
					isCapitalized: true
				),
				output
			)
		}

		// Check a few multicharacter cases manually.
		XCTAssertEqual(
			transliterateToSildish(medials: "shae"),
			"\u{E228}\u{E009}"
		)
		XCTAssertEqual(
			transliterateToSildish(medials: "shaen"),
			"\u{E228}\u{E009}\u{E307}"
		)
		XCTAssertEqual(
			transliterateToSildish(medials: "paperh"),
			"\u{E210}\u{E003}\u{E110}\u{E002}\u{E357}"
		)
		XCTAssertEqual(
			transliterateToSildish(medials: "paper"),
			"\u{E210}\u{E003}\u{E110}\u{E002}\u{E347}"
		)
	}
	
	/// Verify tranliteration of phonemes and phoneme clusters.
	func testTransliteratePhonemesAndClusters ()
	{
		// Test the empty case.
		XCTAssertEqual("".sildish, "")

		// Check all of the phonemes individually.
		Phoneme.allCases.forEach {
			let phonemeData = $0.phonemeData
			var output: String = ""
			switch phonemeData.graphemeSet
			{
				case .vowel(_, let out),
					 .diphthong(_, let out),
					 .consonant(_, let out, _),
					 .reduplicableConsonant(_, let out, _, _, _, _):
					output = out
			}
			XCTAssertEqual(phonemeData.roman.sildish, output, phonemeData.roman)
		}
		
		// Check all of the phoneme clusters individually.
		PhonemeCluster.allCases.forEach {
			let phonemeData = $0.phonemeData
			var output: String = ""
			switch phonemeData.graphemeSet
			{
				case .consonant(_, let out, _):
					output = out
				default:
				XCTFail()
			}
			XCTAssertEqual(phonemeData.roman.sildish, output, phonemeData.roman)
		}
	}

	/// Verify numerous examplars to Sildish.
	func testTransliterateExemplars ()
	{
		let exemplars =
		[
			// Uncapitalized, purely vocalic.
			"eioie" : "\u{E048}\u{E04A}\u{E042}",
			
			// Uncapitalized, leading single consonant.
			"feie" : "\u{E222}\u{E008}\u{E002}",
			"feio" : "\u{E222}\u{E008}\u{E004}",
			"za" : "\u{E227}\u{E003}",
			"zo" : "\u{E227}\u{E004}",
			"shae" : "\u{E228}\u{E009}",
			"zha" : "\u{E229}\u{E003}",
			"zho" : "\u{E229}\u{E004}",
			"zhu" : "\u{E229}\u{E005}",
			"hwa" : "\u{E230}\u{E003}",
			
			// Uncapitalized, leading vowel, single consonant.
			"ama" : "\u{E043}\u{E201}\u{E003}",
			"aga" : "\u{E043}\u{E21D}\u{E003}",
			"agae" : "\u{E043}\u{E21D}\u{E009}",
			
			// Uncapitalized, final consonant.
			"yrhax" : "\u{E040}\u{E257}\u{E003}\u{E11C}\u{E326}",
			"ibril" : "\u{E041}\u{E211}\u{E147}\u{E001}\u{E367}",
			"enhwen" : "\u{E042}\u{E207}\u{E130}\u{E002}\u{E307}",
			"eten" : "\u{E042}\u{E216}\u{E002}\u{E307}",
			"elumanjar" :
				"\u{E042}\u{E267}\u{E005}\u{E101}\u{E003}"
					+ "\u{E107}\u{E13B}\u{E003}\u{E347}",
			"atan" : "\u{E043}\u{E216}\u{E003}\u{E307}",
			"arcat" : "\u{E043}\u{E247}\u{E11C}\u{E003}\u{E316}",
			"onsumeisil" :
				"\u{E044}\u{E207}\u{E126}\u{E005}\u{E101}"
					+ "\u{E008}\u{E126}\u{E001}\u{E367}",
			"oros" : "\u{E044}\u{E247}\u{E004}\u{E326}",
			"numirh" : "\u{E207}\u{E005}\u{E101}\u{E001}\u{E357}",
			"naen" : "\u{E207}\u{E009}\u{E307}",
			"noin" : "\u{E207}\u{E00A}\u{E307}",
			"peloshizh" :
				"\u{E210}\u{E002}\u{E167}\u{E004}\u{E128}\u{E001}\u{E329}",
			"pelos" : "\u{E210}\u{E002}\u{E167}\u{E004}\u{E326}",
			"pan" : "\u{E210}\u{E003}\u{E307}",
			"bobos" : "\u{E211}\u{E004}\u{E111}\u{E004}\u{E326}",
			"gehach" : "\u{E21D}\u{E002}\u{E12E}\u{E003}\u{E32C}",
			"geushancen" :
				"\u{E21D}\u{E026}\u{E128}\u{E003}\u{E107}"
					+ "\u{E11C}\u{E002}\u{E307}",
			"fovos" : "\u{E222}\u{E004}\u{E123}\u{E004}\u{E326}",
			"feistyl" : "\u{E222}\u{E008}\u{E126}\u{E116}\u{E000}\u{E367}",
			"vel" : "\u{E223}\u{E002}\u{E367}",
			"dhon" : "\u{E225}\u{E004}\u{E307}",
			"sil" : "\u{E226}\u{E001}\u{E367}",
			"sar" : "\u{E226}\u{E003}\u{E347}",
			"sodos" : "\u{E226}\u{E004}\u{E117}\u{E004}\u{E326}",
			"chodhizh" : "\u{E22C}\u{E004}\u{E125}\u{E001}\u{E329}",
			"chodhos" : "\u{E22C}\u{E004}\u{E125}\u{E004}\u{E326}",
			"harex" : "\u{E22E}\u{E003}\u{E147}\u{E002}\u{E11C}\u{E326}",
			"hodos" : "\u{E22E}\u{E004}\u{E117}\u{E004}\u{E326}",
			"joshin" : "\u{E23B}\u{E004}\u{E128}\u{E001}\u{E307}",

			// Uncapitalized, final vowel.
			"mana" : "\u{E201}\u{E003}\u{E307}\u{E043}",
			"mimna" : "\u{E201}\u{E001}\u{E101}\u{E307}\u{E043}",
			"mimwa" : "\u{E201}\u{E001}\u{E101}\u{E331}\u{E043}",
			"mehanny" : "\u{E201}\u{E002}\u{E12E}\u{E003}\u{E607}\u{E040}",
			"mehanno" : "\u{E201}\u{E002}\u{E12E}\u{E003}\u{E607}\u{E044}",
			"mehannoi" : "\u{E201}\u{E002}\u{E12E}\u{E003}\u{E607}\u{E04A}",
			"mehanja" :
				"\u{E201}\u{E002}\u{E12E}\u{E003}\u{E107}\u{E33B}\u{E043}",
			"manacydhe" :
				"\u{E201}\u{E003}\u{E107}\u{E003}\u{E11C}"
					+ "\u{E000}\u{E325}\u{E042}",
			"mehannynimfa" :
				"\u{E201}\u{E002}\u{E12E}\u{E003}\u{E407}"
					+ "\u{E000}\u{E107}\u{E001}\u{E101}\u{E322}\u{E043}",
			"nimfa" : "\u{E207}\u{E001}\u{E101}\u{E322}\u{E043}",
			"nimfae" : "\u{E207}\u{E001}\u{E101}\u{E322}\u{E049}",
			"panzhu" : "\u{E210}\u{E003}\u{E107}\u{E329}\u{E045}",
			"peloshwa" :
				"\u{E210}\u{E002}\u{E167}\u{E004}\u{E128}\u{E331}\u{E043}",
			"panpanoi" :
				"\u{E210}\u{E003}\u{E107}\u{E110}\u{E003}\u{E307}\u{E04A}",
			"tabo" : "\u{E216}\u{E003}\u{E311}\u{E044}",
			"tenghwae" : "\u{E216}\u{E002}\u{E10D}\u{E330}\u{E049}",
			"tenghwadhy" :
				"\u{E216}\u{E002}\u{E10D}\u{E130}\u{E003}\u{E325}\u{E040}",
			"tiluva" : "\u{E216}\u{E001}\u{E167}\u{E005}\u{E323}\u{E043}",
			"droa" : "\u{E217}\u{E347}\u{E044}\u{E043}",
			"dana" : "\u{E217}\u{E003}\u{E307}\u{E043}",
			"dano" : "\u{E217}\u{E003}\u{E307}\u{E044}",
			"danae" : "\u{E217}\u{E003}\u{E307}\u{E049}",
			"dumae" : "\u{E217}\u{E005}\u{E301}\u{E049}",
			"danwa" : "\u{E217}\u{E003}\u{E107}\u{E331}\u{E043}",
			"delegroshe" :
				"\u{E217}\u{E002}\u{E167}\u{E002}\u{E11D}"
					+ "\u{E147}\u{E004}\u{E328}\u{E042}",
			"cydhe" : "\u{E21C}\u{E000}\u{E325}\u{E042}",
			"cobrye" : "\u{E21C}\u{E004}\u{E111}\u{E347}\u{E040}\u{E042}",
			"cureshma" :
				"\u{E21C}\u{E005}\u{E147}\u{E002}\u{E128}\u{E301}\u{E043}",
			"feiwa" : "\u{E222}\u{E008}\u{E331}\u{E043}",
			"feirei" : "\u{E222}\u{E008}\u{E347}\u{E048}",
			"vella" : "\u{E223}\u{E002}\u{E667}\u{E043}",
			"vello" : "\u{E223}\u{E002}\u{E667}\u{E044}",
			"velwa" : "\u{E223}\u{E002}\u{E167}\u{E331}\u{E043}",
			"velloi" : "\u{E223}\u{E002}\u{E667}\u{E04A}",
			"thauma" : "\u{E224}\u{E027}\u{E301}\u{E043}",
			"silwa" : "\u{E226}\u{E001}\u{E167}\u{E331}\u{E043}",
			"silwanimfa" :
				"\u{E226}\u{E001}\u{E167}\u{E131}\u{E003}"
					+ "\u{E107}\u{E001}\u{E101}\u{E322}\u{E043}",
			"sentha" : "\u{E226}\u{E002}\u{E107}\u{E324}\u{E043}",
			"chodhostha" :
				"\u{E22C}\u{E004}\u{E125}\u{E004}\u{E126}\u{E324}\u{E043}",
			"hwane" : "\u{E230}\u{E003}\u{E307}\u{E042}",
			"hwasslacantha" :
				"\u{E230}\u{E003}\u{E426}\u{E167}\u{E003}"
					+ "\u{E11C}\u{E003}\u{E107}\u{E324}\u{E043}",
			"junpa" : "\u{E23B}\u{E005}\u{E107}\u{E310}\u{E043}",
			"joshive" : "\u{E23B}\u{E004}\u{E128}\u{E001}\u{E323}\u{E042}",
			"lors" : "\u{E267}\u{E004}\u{E147}\u{E326}",
			
			// Uncapitalized, leading vowel, final vowel.
			"impala" : "\u{E041}\u{E201}\u{E110}\u{E003}\u{E367}\u{E043}",
			"impalo" : "\u{E041}\u{E201}\u{E110}\u{E003}\u{E367}\u{E044}",
			"ecirye" : "\u{E042}\u{E21C}\u{E001}\u{E347}\u{E040}\u{E042}",
			"eshmene" : "\u{E042}\u{E228}\u{E101}\u{E002}\u{E307}\u{E042}",
			"eluma" : "\u{E042}\u{E267}\u{E005}\u{E301}\u{E043}",
			"elucobrye" :
				"\u{E042}\u{E267}\u{E005}\u{E11C}\u{E004}"
					+ "\u{E111}\u{E347}\u{E040}\u{E042}",
			"elushmene" :
				"\u{E042}\u{E267}\u{E005}\u{E128}\u{E101}"
					+ "\u{E002}\u{E307}\u{E042}",
			"elucureshma" :
				"\u{E042}\u{E267}\u{E005}\u{E11C}\u{E005}"
					+ "\u{E147}\u{E002}\u{E128}\u{E301}\u{E043}",
			"abrue" : "\u{E043}\u{E211}\u{E347}\u{E045}\u{E042}",
			"agama" : "\u{E043}\u{E21D}\u{E003}\u{E301}\u{E043}",
			"agamo" : "\u{E043}\u{E21D}\u{E003}\u{E301}\u{E044}",
			"arcatty" : "\u{E043}\u{E247}\u{E11C}\u{E003}\u{E616}\u{E040}",
			"arcatta" : "\u{E043}\u{E247}\u{E11C}\u{E003}\u{E616}\u{E043}",
			"oppoliteie" :
				"\u{E044}\u{E510}\u{E004}\u{E167}\u{E001}"
					+ "\u{E316}\u{E048}\u{E042}",
			"oppoliteio" :
				"\u{E044}\u{E510}\u{E004}\u{E167}\u{E001}"
					+ "\u{E316}\u{E048}\u{E044}",
			"occulthos" :
				"\u{E044}\u{E51C}\u{E005}\u{E167}\u{E124}\u{E004}\u{E326}",
			
			// Capitalized.
			"Celenthyon" : 
				"\u{EA00}\u{E11C}\u{E002}\u{E167}\u{E002}"
					+ "\u{E107}\u{E124}\u{E000}\u{E004}\u{E307}",
			"Saranelluen" :
				"\u{EA00}\u{E126}\u{E003}\u{E147}\u{E003}"
					+ "\u{E107}\u{E002}\u{E467}\u{E005}\u{E002}\u{E307}",
			"Arhyanne" :
				"\u{EA00}\u{E003}\u{E157}\u{E000}\u{E003}\u{E607}\u{E042}",
			
			// Multiple words.
			"Celenthyon oros" :
				"\u{EA00}\u{E11C}\u{E002}\u{E167}\u{E002}"
					+ "\u{E107}\u{E124}\u{E000}\u{E004}\u{E307}"
					+ " "
					+ "\u{E044}\u{E247}\u{E004}\u{E326}",
			"Celenthyon-oros" :
				"\u{EA00}\u{E11C}\u{E002}\u{E167}\u{E002}"
					+ "\u{E107}\u{E124}\u{E000}\u{E004}\u{E307}"
					+ "-"
					+ "\u{E044}\u{E247}\u{E004}\u{E326}",
			"Celenthyon---oros" :
				"\u{EA00}\u{E11C}\u{E002}\u{E167}\u{E002}"
					+ "\u{E107}\u{E124}\u{E000}\u{E004}\u{E307}"
					+ "---"
					+ "\u{E044}\u{E247}\u{E004}\u{E326}",
			"Celenthyon i Saranelluen" :
				"\u{EA00}\u{E11C}\u{E002}\u{E167}\u{E002}"
					+ "\u{E107}\u{E124}\u{E000}\u{E004}\u{E307}"
					+ " "
					+ "\u{E041}"
					+ " "
					+ "\u{EA00}\u{E126}\u{E003}\u{E147}\u{E003}"
						+ "\u{E107}\u{E002}\u{E467}\u{E005}\u{E002}\u{E307}"

		]
		
		exemplars.forEach { (roman, sildish) in
			XCTAssertEqual(roman.sildish, sildish, roman)
		}
	}
}
