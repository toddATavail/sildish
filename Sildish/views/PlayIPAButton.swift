//
//  PlayIPAButton.swift
//  sildish
//
//  Created by Todd L Smith on 8/9/20.
//  Copyright © 2020 Todd L Smith. All rights reserved.
//

import AVFoundation
import SwiftUI

/// Present a button to play the IPA sound associated with the Sildish phoneme
/// indicated by the specified Roman transliteration.
struct PlayIPAButton: View
{
	/// The Roman transliteration of the Sildish phoneme, which names the sound
	/// file to play.
	let roman: String

	@State var player: AVAudioPlayer? = nil

	var body: AnyView
	{
		if let path = Bundle.main.path(
			forResource: "\(self.roman).mp3",
			ofType: nil
		)
		{
			return AnyView(
				Button(action: {
					self.player = try? AVAudioPlayer(
						contentsOf: URL(fileURLWithPath: path)
					)
					self.player?.play()
				}) {
					Image(systemName: "speaker.fill")
				}
			)
		}
		return AnyView(EmptyView())
	}
}

struct PlayIPAButton_Previews: PreviewProvider
{
	static var previews: some View
	{
		PlayIPAButton(roman: "o")
	}
}
