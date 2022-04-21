//
//  GithubRepository.swift
//


import Foundation

struct Repositories: Codable {
    let totalCount: Int
    let incompleteResults: Bool
    var currentPageIndex: Int
    let nextPage: Int?
    var repos: [Repository]

}

struct Repository: Codable, Equatable {
    let id: Int
    let avatarURL: String
    let url: String
    let fullName: String
    let description: String
    let starCount: Int
    let watcherCount: Int
    let forkCount: Int
}
