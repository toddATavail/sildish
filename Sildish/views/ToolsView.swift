//
//  ContentView.swift
//  sildish
//
//  Created by Todd L Smith on 7/30/20.
//  Copyright © 2020 Todd L Smith. All rights reserved.
//

import SwiftUI

struct ToolsView: View
{
    var body: some View
	{
		VStack
		{
			NavigationView
			{
				List
				{
					NavigationLink(
						destination: PhonemeList(
							title: "Phonemes",
							list: Phoneme.allCases))
					{
						Text("Phonemes")
					}
					NavigationLink(
						destination: PhonemeList(
							title: "Clusters",
							list: PhonemeCluster.allCases))
					{
						Text("Clusters")
					}
					NavigationLink(destination: TransliteratorView())
					{
						Text("Transliteration")
					}
				}
				.navigationBarTitle("Tools")
			}
		}
    }
}

struct ContentView_Previews: PreviewProvider
{
    static var previews: some View
	{
        ToolsView()
    }
}
