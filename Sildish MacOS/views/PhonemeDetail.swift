//
//  PhonemeDeftail.swift
//  sildish
//
//  Created by Todd L Smith on 7/31/20.
//  Copyright © 2020 Todd L Smith. All rights reserved.
//

import SwiftUI

struct PhonemeDetail<T : PhoneticElement>: View
{
	typealias Element = T
	
	/// The target phoneme.
	let phoneme: Element
	
    var body: some View
	{
		VStack
		{
			Spacer()
			Text("Roman: \(phoneme.phonemeData.roman)")
			HStack
			{
				Text("IPA: \(phoneme.phonemeData.pronunciation)")
				PlayIPAButton(roman: phoneme.phonemeData.roman)
			}
			Spacer()
			detailView
		}
		.frame(
			minWidth: 400.0,
			maxWidth: .infinity,
			minHeight: 800.0,
			maxHeight: .infinity,
			alignment: .center
		)
    }
	
	/// Answer a detail view appropriate for the phoneme.
	private var detailView: AnyView
	{
		switch phoneme.phonemeData.graphemeSet
		{
			case .vowel(let standard, let withoutBar):
				return AnyView(VowelDetail(
					standard: standard,
					withoutBar: withoutBar
				))
			case .diphthong(let standard, let withoutBar):
				return AnyView(DiphthongDetail(
					standard: standard,
					withoutBar: withoutBar
				))
			case .consonant(let standard, let initial, let final):
				return AnyView(ConsonantDetail(
					standard: standard,
					initial: initial,
					final: final
				))
			case .reduplicableConsonant(
				let standard,
				let initial,
				let final,
				let reduplicated,
				let initialReduplicated,
				let finalReduplicated
			):
				return AnyView(ReduplicableConsonantDetail(
					standard: standard,
					initial: initial,
					final: final,
					reduplicated: reduplicated,
					initialReduplicated: initialReduplicated,
					finalReduplicated: finalReduplicated
				))
		}
	}
}

/// Present a detail view of a Sildish vowel.
private struct VowelDetail: View
{
	let standard: String
	let withoutBar: String
	
	var body: some View
	{
		VStack
		{
			Spacer()
			Text(withoutBar)
				.font(Font.custom("Sildish-Regular", size: 100.0))
			Spacer()
			HStack
			{
				Text("medial: ")
				Text(standard)
					.font(Font.custom("Sildish-Regular", size: 25.0))
			}
			HStack
			{
				Text("nonmedial: ")
				Text(withoutBar)
					.font(Font.custom("Sildish-Regular", size: 25.0))
			}
			Spacer()
		}
	}
}

/// Present a detail view of a Sildish diphthong.
private struct DiphthongDetail: View
{
	let standard: String
	let withoutBar: String
	
	var body: some View
	{
		VStack
		{
			Spacer()
			Text(withoutBar)
				.font(Font.custom("Sildish-Regular", size: 100.0))
			Spacer()
			HStack
			{
				Text("medial: ")
				Text(standard)
					.font(Font.custom("Sildish-Regular", size: 25.0))
			}
			HStack
			{
				Text("nonmedial: ")
				Text(withoutBar)
					.font(Font.custom("Sildish-Regular", size: 25.0))
			}
			Spacer()
		}
	}
}

/// Present a detail view of a Sildish consonant.
private struct ConsonantDetail: View
{
	let standard: String
	let initial: String
	let final: String
	
	var body: some View
	{
		VStack
		{
			Spacer()
			Text(standard)
				.font(Font.custom("Sildish-Regular", size: 100.0))
			Spacer()
			HStack
			{
				Text("initial: ")
				Text(initial)
					.font(Font.custom("Sildish-Regular", size: 25.0))
			}
			HStack
			{
				Text("medial: ")
				Text(standard)
					.font(Font.custom("Sildish-Regular", size: 25.0))
			}
			HStack
			{
				Text("final: ")
				Text(final)
					.font(Font.custom("Sildish-Regular", size: 25.0))
			}
			Spacer()
		}
	}
}

/// Present a detail view of a Sildish reduplicable consonant.
private struct ReduplicableConsonantDetail: View
{
	let standard: String
	let initial: String
	let final: String
	let reduplicated: String
	let initialReduplicated: String
	let finalReduplicated: String
	
	var body: some View
	{
		VStack
		{
			Spacer()
			Text(standard)
				.font(Font.custom("Sildish-Regular", size: 100.0))
			Spacer()
			// The group is necessary to circumvent a limitation with the number
			// of arguments that can be passed to the builder.
			Group
			{
				HStack
				{
					Text("initial: ")
					Text(initial)
						.font(Font.custom("Sildish-Regular", size: 25.0))
				}
				HStack
				{
					Text("medial: ")
					Text(standard)
						.font(Font.custom("Sildish-Regular", size: 25.0))
				}
				HStack
				{
					Text("final: ")
					Text(final)
						.font(Font.custom("Sildish-Regular", size: 25.0))
				}
				HStack
				{
					Text("reduplicated initial: ")
					Text(initialReduplicated)
						.font(Font.custom("Sildish-Regular", size: 25.0))
				}
				HStack
				{
					Text("reduplicated medial: ")
					Text(reduplicated)
						.font(Font.custom("Sildish-Regular", size: 25.0))
				}
				HStack
				{
					Text("reduplicated final: ")
					Text(finalReduplicated)
						.font(Font.custom("Sildish-Regular", size: 25.0))
				}
			}
			Spacer()
		}
	}
}

struct PhonemeDeftail_Previews: PreviewProvider
{
    static var previews: some View
	{
		PhonemeDetail(phoneme: Phoneme.o)
    }
}
