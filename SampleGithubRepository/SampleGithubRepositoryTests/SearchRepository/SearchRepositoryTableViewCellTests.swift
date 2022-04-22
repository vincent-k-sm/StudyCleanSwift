//
//  SearchRepositoryTableViewCellTests.swift
//

@testable import SampleGithubRepository
import XCTest

class SearchRepositoryTableViewCellTests: XCTestCase {
    
    var sut: SearchRepositoryTableViewCell!
    var model: SearchRepositoryTableViewCellModel!
    
    
    class SearchRepositoryTableViewCellModelSpy: SearchRepositoryTableViewCellModel {
        enum TestCase {
            case success
            case timeoutOnceSuccess
            case timeoutSecondSuccess
            case timeoutSecondFailure
            case failure
        }

        var testCase: TestCase = .success
        var retryCount: Int = 0

        init() {
            self.repositoryName = "test"
        }

        var repositoryName: String
        
        func fetchImage(completion: @escaping (Result<UIImage, ImageFetchingError>) -> Void) {
            
            DispatchQueue.global().async {
                var result: Result<UIImage, ImageFetchingError>!
                
                let testImage = UIImage()
                switch self.testCase {
                    case .success:
                        result = .success(testImage)
                        
                    case .failure:
                        result = .failure(.unknown)
                        
                    case .timeoutOnceSuccess:
                        if self.retryCount == 0 {
                            result = .failure(.timeout)
                        }
                        if self.retryCount == 1 {
                            result = .success(testImage)
                        }
                        
                    case .timeoutSecondSuccess:
                        if self.retryCount == 0 {
                            result = .failure(.timeout)
                        }
                        if self.retryCount == 1 {
                            result = .failure(.timeout)
                        }
                        if self.retryCount == 2 {
                            result = .success(testImage)
                        }
                    case .timeoutSecondFailure:
                        result = .failure(.timeout)
                }
                completion(result)
            }

        }
    }
    override func setUp() {
        super.setUp()
        sut = SearchRepositoryTableViewCell()
        model = SearchRepositoryTableViewCellModelSpy()
    }
    
    func testCellSetModelSuccess() {
        // given
        let cell = SearchRepositoryTableViewCell()
        let model = SearchRepositoryTableViewCellModelSpy()
        model.testCase = .success
        cell.set(model: model)
        
        // when
        let expectResetImage = expectation(description: "Wait for imageview nil")
        let expectFetchImage = expectation(description: "Wait for model.fetchImage")
        let expectFetchImageResult = expectation(description: "Wait for model.fetchImage Result in main.async")
        
        DispatchQueue.main.async {
            expectResetImage.fulfill()
        }
        
        model.fetchImage { result in
            expectFetchImage.fulfill()
        }
        
        DispatchQueue.main.async {
            expectFetchImageResult.fulfill()
        }
        
        wait(for: [expectResetImage, expectFetchImage, expectFetchImageResult], timeout: 10)
        
        // then
        XCTAssertNotNil(cell.thumbnailImageView.image, "image should not nil when success")
        XCTAssertNotNil(cell.titleLabel.text, "title should not nil when success")
    }
    
    func testCellSetModelFailure() {
        // given
        let cell = SearchRepositoryTableViewCell()
        let model = SearchRepositoryTableViewCellModelSpy()
        model.testCase = .failure
        cell.set(model: model)
        
        // when
        let expectResetImage = expectation(description: "Wait for imageview nil")
        let expectFetchImage = expectation(description: "Wait for model.fetchImage")
        let expectFetchImageResult = expectation(description: "Wait for model.fetchImage Result in main.async")
        
        DispatchQueue.main.async {
            expectResetImage.fulfill()
        }
        
        model.fetchImage { result in
            expectFetchImage.fulfill()
        }
        
        DispatchQueue.main.async {
            expectFetchImageResult.fulfill()
        }
        
        wait(for: [expectResetImage, expectFetchImage, expectFetchImageResult], timeout: 10)
        
        // then
        XCTAssertNil(cell.thumbnailImageView.image, "image should nil when success")
        XCTAssertNotNil(cell.titleLabel.text, "title should not nil when success")
    }
    
    func testCellSetModelTimeOutOnceSuccess() {
        
        // given
        let cell = SearchRepositoryTableViewCell()
        let model = SearchRepositoryTableViewCellModelSpy()
        model.testCase = .timeoutOnceSuccess
        cell.set(model: model)
        
        // when
        let expectResetImage = expectation(description: "Wait for imageview nil")
        let expectFetchImage = expectation(description: "Wait for model.fetchImage")
        let expectFetchImageResult = expectation(description: "Wait for model.fetchImage Result in main.async")
        
        DispatchQueue.main.async {
            expectResetImage.fulfill()
        }
        
        model.fetchImage { result in
            model.retryCount += 1
            expectFetchImage.fulfill()
        }
        
        DispatchQueue.main.async {
            expectFetchImageResult.fulfill()
        }
        
        wait(for: [expectResetImage, expectFetchImage, expectFetchImageResult], timeout: 20)
        
        // then
        XCTAssertNotNil(cell.thumbnailImageView.image, "image should not nil when success")
        XCTAssertNotNil(cell.titleLabel.text, "title should not nil when success")
    }
    
    func testCellSetModelTimeOutSecondSuccess() {
        
        // given
        let cell = SearchRepositoryTableViewCell()
        let model = SearchRepositoryTableViewCellModelSpy()
        model.testCase = .timeoutSecondSuccess
        cell.set(model: model)
        
        // when
        let expectResetImage = expectation(description: "Wait for imageview nil")
        let expectFetchImage = expectation(description: "Wait for model.fetchImage")
        let expectFetchImageResult = expectation(description: "Wait for model.fetchImage Result in main.async")
        
        DispatchQueue.main.async {
            expectResetImage.fulfill()
        }
        
        model.fetchImage { result in
            model.retryCount += 2
            expectFetchImage.fulfill()
        }
        
        DispatchQueue.main.async {
            expectFetchImageResult.fulfill()
        }
        
        wait(for: [expectResetImage, expectFetchImage, expectFetchImageResult], timeout: 20)
        
        // then
        XCTAssertNotNil(cell.thumbnailImageView.image, "image should not nil when success")
        XCTAssertNotNil(cell.titleLabel.text, "title should not nil when success")
    }
    
    func testCellSetModelTimeOutSecondFailure() {
        
        // given
        let cell = SearchRepositoryTableViewCell()
        let model = SearchRepositoryTableViewCellModelSpy()
        model.testCase = .timeoutSecondFailure
        cell.set(model: model)
        
        // when
        let expectResetImage = expectation(description: "Wait for imageview nil")
        let expectFetchImage = expectation(description: "Wait for model.fetchImage")
        let expectFetchImageResult = expectation(description: "Wait for model.fetchImage Result in main.async")
        
        DispatchQueue.main.async {
            expectResetImage.fulfill()
        }
        
        model.fetchImage { result in
            model.retryCount += 2
            expectFetchImage.fulfill()
        }
        
        DispatchQueue.main.async {
            expectFetchImageResult.fulfill()
        }
        
        wait(for: [expectResetImage, expectFetchImage, expectFetchImageResult], timeout: 20)
        
        // then
        XCTAssertNil(cell.thumbnailImageView.image, "image should nil when success")
        XCTAssertNotNil(cell.titleLabel.text, "title should not nil when success")
    }

}
