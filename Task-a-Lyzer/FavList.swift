
//
//  FavList.swift
//  Task-a-Lyzer
//
//  Created by DHC on 5/30/22.
//

import Foundation

struct FavList: Identifiable {


    var id = UUID()
    let name: String
    let url: String


    var favName: String {
        "\(name)"
    }

    static var sampleData:[FavList] {
        [
            FavList(name: "Udmey", url: "udemy.com"),
            FavList(name: "Google", url: "google.com"),
        ]

    }
}
