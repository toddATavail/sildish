//
//  PhonemeList.swift
//  sildish
//
//  Created by Todd L Smith on 7/31/20.
//  Copyright © 2020 Todd L Smith. All rights reserved.
//

import SwiftUI

struct PhonemeList<T : PhoneticElement>: View
{
	typealias Element = T
	
	/// The navigation bar title.
	let title: String
	
	/// The target phonemes to present.
	let list: [Element]
	
    var body: some View
	{
		NavigationView
		{
			VStack
			{
				List(list)
				{ phoneme in
					NavigationLink(
						destination: PhonemeDetail(phoneme: phoneme)
					)
					{
						Text(phoneme.phonemeData.roman)
						Spacer()
						self.phonemeLabelView(for: phoneme)
						Spacer()
					}
				}
			}
			.navigationViewStyle(DoubleColumnNavigationViewStyle())
			.frame(
				minWidth: 400.0,
				maxWidth: .infinity,
				minHeight: 800.0,
				maxHeight: .infinity,
				alignment: .leading
			)
		}
    }
	
	/// Answer a label appropriate for the phoneme.
	private func phonemeLabelView (for phoneme: T) -> AnyView
	{
		switch phoneme.phonemeData.graphemeSet
		{
			case .vowel(_, let standard),
				 .diphthong(_, let standard),
				 .consonant(let standard, _, _),
				 .reduplicableConsonant(let standard, _, _, _, _, _):
				return AnyView(
					Text(standard)
						.font(Font.custom("Sildish-Regular", size: 24.0)
					)
				)
		}
	}
}

struct PhonemeList_Previews: PreviewProvider
{
    static var previews: some View
	{
		PhonemeList(title: "Phonemes", list: Phoneme.allCases)
    }
}
