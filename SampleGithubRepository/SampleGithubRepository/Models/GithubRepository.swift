//
//  GithubRepository.swift
//


import Foundation

struct Repositories: Codable {
    let totalCount: Int
    let incompleteResults: Bool
    let currentPageIndex: Int
    let nextPage: Int?
    let repos: [Repository]

}

struct Repository: Codable {
    let id: Int
    let avatarURL: String
    let url: String
    let fullName: String
    let description: String
    let starCount: Int
    let watcherCount: Int
    let forkCount: Int
}
