//
//  UserRanking.swift
//  MyBookShelf
//
//  Created by Lorenzo Cavallucci on 03/07/25.
//


struct UserRanking: Identifiable, Codable {
    var id: String // uid
    var email: String
    var level: Int
}