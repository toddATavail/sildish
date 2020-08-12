//
//  SelectableText.swift
//  sildish
//
//  Created by Todd L Smith on 8/12/20.
//  Copyright © 2020 Todd L Smith. All rights reserved.
//

import SwiftUI

/// Present a `SwiftUI` text label that can be selected by the user, especially
/// to permit copy.
struct SelectableText: UIViewRepresentable
{
	typealias UIViewType = ReadonlyUITextView
	
	/// The text to present.
	private var text: String
	
	/// The text alignment to use.
	private var textAlignment: NSTextAlignment = .natural

	/// The font to use.
	private var font: UIFont? = nil
	
	/// Construct a `SelectableText` to present the specified text.
	///
	/// - Parameters:
	///   - text: The text to present.
	init (_ text: String)
	{
		self.text = text
	}
	
	/// Construct a `SelectableText` with the specified properties.
	///
	/// - Parameters:
	///   - text: The text to present.
	///   - textAlignment: The text alignment.
	///   - font: The font.
	private init (
		_ text: String,
		_ textAlignment: NSTextAlignment,
		_ font: UIFont?
	)
	{
		self.text = text
		self.textAlignment = textAlignment
		self.font = font
	}

	func makeUIView (context: Context) -> ReadonlyUITextView
	{
		let textView = ReadonlyUITextView(frame: .zero)
		textView.delegate = textView
		textView.text = self.text
		textView.textAlignment = self.textAlignment
		textView.font = self.font
		textView.setContentHuggingPriority(.defaultHigh, for: .vertical)
		textView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
		textView.autocorrectionType = .no
		textView.inputView = UIView()
		return textView
	}
    
	func updateUIView (_ uiView: ReadonlyUITextView, context: Context)
	{
		uiView.text = self.text
		uiView.textBinding = .constant(self.text)
	}
	
	/// Answer a variant of the receiver that uses the specified font.
	///
	/// - Parameters:
	///   - font: The font.
	func font (_ font: UIFont?) -> SelectableText
	{
		SelectableText(self.text, self.textAlignment, font)
	}
	
	/// Answer a variant of the receiver that uses the specified font.
	///
	/// - Parameters:
	///   - font: The font.
	func multilineTextAlignment (_ alignment: NSTextAlignment) -> SelectableText
	{
		SelectableText(self.text, alignment, self.font)
	}
}

/// Present a text label that can be selected by the user, especially to permit
/// copy.
class ReadonlyUITextView: UITextView, UITextViewDelegate
{
	/// The text.
	fileprivate var textBinding: Binding<String>!
    
	// Ensure that the cursor has zero size.
	override func caretRect (for position: UITextPosition) -> CGRect
	{
		.zero
	}
    
	/// Eliminate edit items from the text selection context menu.
	override func canPerformAction (
		_ action: Selector,
		withSender sender: Any?
	) -> Bool
	{
		switch action
		{
			case
					#selector(cut(_:)),
					#selector(delete(_:)),
					#selector(paste(_:)):
				return false
			default:
				// `_promptForReplace:` is private, but real; wrap the name in
				// parentheses to suppress an erroneous warning about its
				// nonexistence.
				if (action == Selector(("_promptForReplace:")))
				{
					return false
				}
				return super.canPerformAction(action, withSender: sender)
		}
	}
	
	/// Update the text.
	func textViewDidChangeSelection (_ textView: UITextView)
	{
		self.textBinding.wrappedValue = textView.text ?? ""
	}
	
	/// Forbid replacement of the text.
	func textView (
		_ textView: UITextField,
		shouldChangeCharactersIn range: NSRange,
		replacementString string: String
	) -> Bool
	{
		return false
	}
}

struct SelectableText_Previews: PreviewProvider
{
	static var previews: some View
	{
		SelectableText("Selectable Text")
	}
}
