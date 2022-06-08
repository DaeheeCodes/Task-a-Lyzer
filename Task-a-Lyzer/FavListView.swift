//
//  FavListView.swift
//  Task-a-Lyzer
//
//  Created by DHC on 6/7/22.
//

import Foundation

class FavListView:ObservableObject  {

    
    @Published var favList:[FavList]
    init() {
        favList = FavList.sampleData
    }
    
}
