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
	
	/// The observer for selecting all text upon an edit.
	private let selectAllObserver = SelectAllObserver()
	
    var body: some View
	{
		VStack
		{
			TextField("Transliterate", text: $transliterator.roman)
				.autocapitalization(.none)
				.disableAutocorrection(true)
				.multilineTextAlignment(.center)
				.introspectTextField { textField in
					textField.addTarget(
						self.selectAllObserver,
						action: #selector(SelectAllObserver.editingDidBeginOn),
						for: .editingDidBegin
					)
				}
			Divider()
			SelectableText(transliterator.sildish)
				.font(UIFont(name: "Sildish-Regular", size: 64.0))
				.multilineTextAlignment(.center)
				.frame(
					minWidth: 0.0,
					maxWidth: .infinity,
					minHeight: 0.0,
					maxHeight: 600.0,
					alignment: .bottomLeading
				)
		}
    }
}

/// Observe initiation of editing, for the purpose of selecting all text in a
/// `UITextField` for overwriting by the user.
private class SelectAllObserver: NSObject
{
	/// React to initiation of an edit of the specified `UITextField` by
	/// selecting all of the text that it contains.
	///
	/// - Parameters:
	///   - textField: The `TextField` for which editing has begun.
	@objc func editingDidBeginOn (textField: UITextField)
	{
		textField.selectAll(nil)
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
