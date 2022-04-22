//
//  SearchRepositoryTableViewCellModel.swift
//


import Foundation
import UIKit

enum ImageFetchingError: Error {
    case timeout
    case unknown
}

protocol SearchRepositoryTableViewCellModel {
    var repositoryName: String { get }
    func fetchImage(completion: @escaping (Result<UIImage, ImageFetchingError>) -> Void)
}

protocol SearchRepositoryTableViewCellModelAsync {
    var repositoryName: String { get }
    func fetchImage() async throws -> Result<UIImage, ImageFetchingError>
    
}
