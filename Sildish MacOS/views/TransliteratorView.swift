//
//  TransliteratorView.swift
//  sildish
//
//  Created by Todd L Smith on 8/11/20.
//  Copyright © 2020 Todd L Smith. All rights reserved.
//

import Introspect
import SwiftUI

/// Presentation of a Roman-to-Sildish transliterator as Roman text field and the
/// transliterated Sildish output.
struct TransliteratorView: View
{
	/// The Roman text.
	@ObservedObject private var transliterator = TransliteratorFieldModel()
	
    var body: some View
	{
		VStack
		{
			TextField("Transliterate", text: $transliterator.roman)
				.disableAutocorrection(true)
				.multilineTextAlignment(.center)
			Divider()
			Text(transliterator.sildish)
				.font(Font.custom("Sildish-Regular", size: 64.0))
				.multilineTextAlignment(.center)
		}
		.frame(
			minWidth: 800.0,
			maxWidth: .infinity,
			minHeight: 800.0,
			maxHeight: .infinity,
			alignment: .top
		)
    }
}

/// The model for the transliterator field.
private class TransliteratorFieldModel: ObservableObject
{
	/// The Roman text.
	@Published var roman: String = ""
	{
		didSet
		{
			sildish = roman.sildish
		}
	}
	
	/// The Sildish transliteration of the Roman text.
	@Published var sildish: String = ""
}

struct TransliteratorView_Previews: PreviewProvider
{
    static var previews: some View
	{
        TransliteratorView()
    }
}
