//
//  WatchBook.swift
//  MyBookShelf
//
//  Created by Lorenzo Cavallucci on 02/07/25.
//

import Foundation

struct WatchBook: Identifiable, Codable {
    var id: String
    var title: String
    var author: String
    var coverData: String? // opzionale
}
