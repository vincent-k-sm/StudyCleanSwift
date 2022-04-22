//
//  SearchRepositoryViewControllerTests.swift
//  SampleGithubRepository
//

@testable import SampleGithubRepository
import XCTest
import MKUtils

class SearchRepositoryViewControllerTests: XCTestCase {
    // MARK: Subject under test

    var sut: SearchRepositoryViewController!
    var window: UIWindow!

    // MARK: - Test lifecycle

    override func setUp() {
        super.setUp()
        window = UIWindow()
        setupSearchRepositoryViewController()
    }

    override func tearDown() {
        window = nil
        super.tearDown()
    }

    // MARK: - Test setup

    func setupSearchRepositoryViewController() {
        sut = SearchRepositoryViewController()
    }

    func loadView() {
        window.addSubview(sut.view)
        RunLoop.current.run(until: Date())
    }

    // MARK: - Test doubles

    class SearchRepositoryBusinessLogicSpy: SearchRepositoryBusinessLogic {
        var searchReopsCalled = false
        func fetchRepos(request: SearchRepository.Search.Request) {
            searchReopsCalled = true
        }
    }
    
    class TableViewSpy: UITableView {
        var reloadDataCalled = false
        var insertRowCalled = false
        
        override func reloadData() {
            super.reloadData()
            reloadDataCalled = true
        }
        
        override func insertRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
            super.insertRows(at: indexPaths, with: animation)
            insertRowCalled = true
        }
    }
    
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

    // MARK: - Tests

    func testShouldDoSomethingWhenViewIsLoaded() {
        // Given
        let spy = SearchRepositoryBusinessLogicSpy()
        sut.interactor = spy

        // When
        loadView()

        // Then
        XCTAssertFalse(spy.searchReopsCalled, "viewDidLoad() should not ask anything to interactor")
    }
    
    func testDisplayFetchOrderResult() {
        // given
        let tableViewSpy = TableViewSpy()
        sut.tableView = tableViewSpy
        sut.tableView.dataSource = sut
        
        let expect = expectation(description: "Wait for tableview run in DispatchQueue.main.async")
        
        let count = 10
        let repoList: [Repository] = (0..<count).map({ el -> Repository in
            return Repository(id: el, avatarURL: "", url: "", fullName: "", description: "", starCount: 0, watcherCount: 0, forkCount: 0)
        })
        
        let repos: Repositories = Repositories(
            totalCount: count,
            incompleteResults: false,
            currentPageIndex: 1,
            nextPage: nil,
            repos: repoList
        )
        let viewmodel = SearchRepository.Search.ViewModel(repos: repos)
        
        // when
        sut.displayFetchOrderResult(viewModel: viewmodel)
        DispatchQueue.main.async {
            expect.fulfill()
        }
        
        wait(for: [expect], timeout: 2.0)
        
        // then
        XCTAssert(tableViewSpy.reloadDataCalled, "tableView reloaded when displayfetchorders")
    
        XCTAssertEqual(sut.repos?.repos.count, tableViewSpy.numberOfRows(inSection: 0), "repos count should equal tableview row count")
        
    }
    
    func testDisplayFetchOrderResultWhenAppend() {
        // given
        let tableViewSpy = TableViewSpy()
        sut.tableView = tableViewSpy
        sut.tableView.dataSource = sut

        let expect = expectation(description: "Wait for tableview run in DispatchQueue.main.async")
        
        let count = 10
        let repoList: [Repository] = (0..<count).map({ el -> Repository in
            return Repository(id: el, avatarURL: "", url: "", fullName: "", description: "", starCount: 0, watcherCount: 0, forkCount: 0)
        })
        
        let repos: Repositories = Repositories(
            totalCount: count,
            incompleteResults: false,
            currentPageIndex: 1,
            nextPage: nil,
            repos: repoList
        )
        var viewmodel = SearchRepository.Search.ViewModel(repos: repos)
        
        // when
        sut.displayFetchOrderResult(viewModel: viewmodel)
        viewmodel.repos?.currentPageIndex = 2
        sut.displayFetchOrderResult(viewModel: viewmodel)
        
        DispatchQueue.main.async {
            expect.fulfill()
        }
        
        wait(for: [expect], timeout: 2.0)
        
        // then
        XCTAssert(tableViewSpy.insertRowCalled, "tableView should insert row when displayfetchorders paging")
        XCTAssertEqual(sut.repos?.repos.count, sut.tableView.numberOfRows(inSection: 0), "repos count should equal tableview row count")
    }
    
    func testAsyncImageLoadInTableView() {
        
        // given
        let expect = expectation(description: "Wait for tableview run in DispatchQueue.main.async")
        
        let tableView = sut.tableView
        
        let result = RepoMock.mockRepo

        let viewmodel = SearchRepository.Search.ViewModel(repos: result)
        
//         when
        sut.displayFetchOrderResult(viewModel: viewmodel)
        DispatchQueue.main.async {
            expect.fulfill()
        }
        
        wait(for: [expect], timeout: 2.0)
        
        // then
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! SearchRepositoryTableViewCell
        XCTAssertNotNil(cell, "deque SearchRepositoryTableViewCell")
        
        // when
        let expectCell = expectation(description: "Wait for cell configure run in DispatchQueue.main.async")
        DispatchQueue.main.async {
            expectCell.fulfill()
        }
        wait(for: [expectCell], timeout: 10.0)
        
        // then
        XCTAssertNotNil(cell.titleLabel.text, "title Label Text is shoul not nil")
        
        
        // when
        let expectImage = expectation(description: "Wait for cell configure run in DispatchQueue.main.async")
        DispatchQueue.main.async {
            expectImage.fulfill()
        }
        wait(for: [expectImage], timeout: 10.0)
        
        // then
        XCTAssertEqual(cell.thumbnailImageView.accessibilityLabel, "image \(String(indexPath.row))")
        XCTAssertNil(cell.thumbnailImageView.image, "imageView image should nil when before fetch")
    }
    
    func testCellPrepareForReuse() {
        // given
        let cell = SearchRepositoryTableViewCell()
        let model = RepoMock.mockRepo.repos.first!
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
        
        cell.prepareForReuse()
        
        
        let expectPrepareReuse = expectation(description: "Wait for imageview nil")
        DispatchQueue.main.async {
            expectPrepareReuse.fulfill()
        }
        wait(for: [expectPrepareReuse], timeout: 10)
        
        // then
        XCTAssertNil(cell.thumbnailImageView.image, "image should nil when prepare reload")
        
    }
}

final class RepoMock {
    
    static let mockRepo = Repositories(
        totalCount: 5688,
        incompleteResults: false,
        currentPageIndex: 1,
        nextPage: 2,
        repos: [
            Repository(
                id: 33569135,
                avatarURL: "https://avatars.githubusercontent.com/u/6407041?v=4",
                url: "https://github.com/ReactiveX/RxSwift",
                fullName: "ReactiveX/RxSwift",
                description: "Reactive Programming in Swift",
                starCount: 22068,
                watcherCount: 22068,
                forkCount: 3932
            ),
            Repository(
                id: 116330852,
                avatarURL: "https://avatars.githubusercontent.com/u/27915244?v=4",
                url: "https://github.com/fimuxd/RxSwift",
                fullName: "fimuxd/RxSwift",
                description: "RxSwift를 스터디하는 공간",
                starCount: 524,
                watcherCount: 524,
                forkCount: 141
            ),
            Repository(
                id: 55688297,
                avatarURL: "https://avatars.githubusercontent.com/u/15903991?v=4",
                url: "https://github.com/RxSwiftCommunity/RxSwiftExt",
                fullName: "RxSwiftCommunity/RxSwiftExt",
                description: "A collection of Rx operators & tools not found in the core RxSwift distribution",
                starCount: 1197,
                watcherCount: 1197,
                forkCount: 183
            ),
            Repository(
                id: 51301474,
                avatarURL: "https://avatars.githubusercontent.com/u/2815187?v=4",
                url: "https://github.com/DroidsOnRoids/RxSwiftExamples",
                fullName: "DroidsOnRoids/RxSwiftExamples",
                description: "Examples and resources for RxSwift.",
                starCount: 963,
                watcherCount: 963,
                forkCount: 151
            ),
            Repository(
                id: 98111681,
                avatarURL: "https://avatars.githubusercontent.com/u/5554127?v=4",
                url: "https://github.com/beeth0ven/RxSwift-Chinese-Documentation",
                fullName: "beeth0ven/RxSwift-Chinese-Documentation",
                description: "RxSwift 中文文档",
                starCount: 1238,
                watcherCount: 1238,
                forkCount: 130
            ),
            Repository(
                id: 55787235,
                avatarURL: "https://avatars.githubusercontent.com/u/1611150?v=4",
                url: "https://github.com/Polidea/RxBluetoothKit",
                fullName: "Polidea/RxBluetoothKit",
                description: "iOS & OSX Bluetooth library for RxSwift",
                starCount: 1305,
                watcherCount: 1305,
                forkCount: 264
            ),
            Repository(
                id: 82974632,
                avatarURL: "https://avatars.githubusercontent.com/u/4622322?v=4",
                url: "https://github.com/sergdort/CleanArchitectureRxSwift",
                fullName: "sergdort/CleanArchitectureRxSwift",
                description: "Example of Clean Architecture of iOS app using RxSwift",
                starCount: 3370,
                watcherCount: 3370,
                forkCount: 437
            ),
            Repository(
                id: 190878115,
                avatarURL: "https://avatars.githubusercontent.com/u/53597243?v=4",
                url: "https://github.com/CombineCommunity/rxswift-to-combine-cheatsheet",
                fullName: "CombineCommunity/rxswift-to-combine-cheatsheet",
                description: "RxSwift to Apple’s Combine Cheat Sheet",
                starCount: 1501,
                watcherCount: 1501,
                forkCount: 89
            ),
            Repository(
                id: 54464241,
                avatarURL: "https://avatars.githubusercontent.com/u/15903991?v=4",
                url: "https://github.com/RxSwiftCommunity/RxGesture",
                fullName: "RxSwiftCommunity/RxGesture",
                description: "RxSwift reactive wrapper for view gestures",
                starCount: 1222,
                watcherCount: 1222,
                forkCount: 168
            ),
            Repository(
                id: 62412616,
                avatarURL: "https://avatars.githubusercontent.com/u/931655?v=4",
                url: "https://github.com/devxoul/RxTodo",
                fullName: "devxoul/RxTodo",
                description: "iOS Todo Application using RxSwift and ReactorKit",
                starCount: 1254,
                watcherCount: 1254,
                forkCount: 171
            ),
            Repository(
                id: 56589037,
                avatarURL: "https://avatars.githubusercontent.com/u/15903991?v=4",
                url: "https://github.com/RxSwiftCommunity/RxRealm",
                fullName: "RxSwiftCommunity/RxRealm",
                description: "RxSwift extension for RealmSwift's types",
                starCount: 1088,
                watcherCount: 1088,
                forkCount: 190
            ),
            Repository(
                id: 78011995,
                avatarURL: "https://avatars.githubusercontent.com/u/11523360?v=4",
                url: "https://github.com/khoren93/SwiftHub",
                fullName: "khoren93/SwiftHub",
                description: "GitHub iOS client in RxSwift and MVVM-C clean architecture",
                starCount: 2447,
                watcherCount: 2447,
                forkCount: 439
            ),
            Repository(
                id: 20467848,
                avatarURL: "https://avatars.githubusercontent.com/u/432536?v=4",
                url: "https://github.com/jspahrsummers/RxSwift",
                fullName: "jspahrsummers/RxSwift",
                description: "Proof-of-concept for implementing Rx primitives in Swift",
                starCount: 603,
                watcherCount: 603,
                forkCount: 36
            ),
            Repository(
                id: 46382724,
                avatarURL: "https://avatars.githubusercontent.com/u/15903991?v=4",
                url: "https://github.com/RxSwiftCommunity/Action",
                fullName: "RxSwiftCommunity/Action",
                description: "Abstracts actions to be performed in RxSwift.",
                starCount: 855,
                watcherCount: 855,
                forkCount: 141
            ),
            Repository(
                id: 85860914,
                avatarURL: "https://avatars.githubusercontent.com/u/15903991?v=4",
                url: "https://github.com/RxSwiftCommunity/RxReachability",
                fullName: "RxSwiftCommunity/RxReachability",
                description: "RxSwift bindings for Reachability",
                starCount: 264,
                watcherCount: 264,
                forkCount: 71
            ),
            Repository(
                id: 47712074,
                avatarURL: "https://avatars.githubusercontent.com/u/1921410?v=4",
                url: "https://github.com/bmoliveira/Moya-ObjectMapper",
                fullName: "bmoliveira/Moya-ObjectMapper",
                description: "ObjectMapper bindings for Moya and RxSwift",
                starCount: 475,
                watcherCount: 475,
                forkCount: 162
            ),
            Repository(
                id: 80272046,
                avatarURL: "https://avatars.githubusercontent.com/u/16699975?v=4",
                url: "https://github.com/kLike/ZhiHu-RxSwift",
                fullName: "kLike/ZhiHu-RxSwift",
                description: "知乎日报  with RxSwift",
                starCount: 371,
                watcherCount: 371,
                forkCount: 74
            ),
            Repository(
                id: 127535602,
                avatarURL: "https://avatars.githubusercontent.com/u/15903991?v=4",
                url: "https://github.com/RxSwiftCommunity/RxFirebase",
                fullName: "RxSwiftCommunity/RxFirebase",
                description: "RxSwift extensions for Firebase",
                starCount: 223,
                watcherCount: 223,
                forkCount: 60
            ),
            Repository(
                id: 41247272,
                avatarURL: "https://avatars.githubusercontent.com/u/15903991?v=4",
                url: "https://github.com/RxSwiftCommunity/RxAlamofire",
                fullName: "RxSwiftCommunity/RxAlamofire",
                description: "RxSwift wrapper around the elegant HTTP networking in Swift Alamofire",
                starCount: 1532,
                watcherCount: 1532,
                forkCount: 236
            ),
            Repository(
                id: 39099893,
                avatarURL: "https://avatars.githubusercontent.com/u/15903991?v=4",
                url: "https://github.com/RxSwiftCommunity/RxViewModel",
                fullName: "RxSwiftCommunity/RxViewModel",
                description: "ReactiveViewModel-esque using RxSwift",
                starCount: 398,
                watcherCount: 398,
                forkCount: 41
            ),
            Repository(
                id: 59040730,
                avatarURL: "https://avatars.githubusercontent.com/u/13653215?v=4",
                url: "https://github.com/jhw-dev/RxSwift-CN",
                fullName: "jhw-dev/RxSwift-CN",
                description: ":memo: RxSwift文档的中文翻译",
                starCount: 344,
                watcherCount: 344,
                forkCount: 52
            ),
            Repository(
                id: 66516622,
                avatarURL: "https://avatars.githubusercontent.com/u/15663899?v=4",
                url: "https://github.com/LeoMobileDeveloper/awesome-rxswift",
                fullName: "LeoMobileDeveloper/awesome-rxswift",
                description: "An awesome type curated list of RxSwift library and learning material",
                starCount: 454,
                watcherCount: 454,
                forkCount: 38
            ),
            Repository(
                id: 162612515,
                avatarURL: "https://avatars.githubusercontent.com/u/6276689?v=4",
                url: "https://github.com/iamchiwon/RxSwift_In_4_Hours",
                fullName: "iamchiwon/RxSwift_In_4_Hours",
                description: "RxSwift, 4시간 안에 빠르게 익혀 실무에 사용하기",
                starCount: 280,
                watcherCount: 280,
                forkCount: 98
            ),
            Repository(
                id: 91910288,
                avatarURL: "https://avatars.githubusercontent.com/u/931655?v=4",
                url: "https://github.com/devxoul/RxViewController",
                fullName: "devxoul/RxViewController",
                description: "RxSwift wrapper for UIViewController and NSViewController",
                starCount: 319,
                watcherCount: 319,
                forkCount: 47
            ),
            Repository(
                id: 92299683,
                avatarURL: "https://avatars.githubusercontent.com/u/13078294?v=4",
                url: "https://github.com/aidevjoe/RxSwift-Tutorial",
                fullName: "aidevjoe/RxSwift-Tutorial",
                description: "RxSwift 学习资料(学习教程、开源项目)",
                starCount: 271,
                watcherCount: 271,
                forkCount: 60
            ),
            Repository(
                id: 59140168,
                avatarURL: "https://avatars.githubusercontent.com/u/15903991?v=4",
                url: "https://github.com/RxSwiftCommunity/RxCoreData",
                fullName: "RxSwiftCommunity/RxCoreData",
                description: "RxSwift extensions for Core Data",
                starCount: 163,
                watcherCount: 163,
                forkCount: 65
            ),
            Repository(
                id: 54832564,
                avatarURL: "https://avatars.githubusercontent.com/u/3348292?v=4",
                url: "https://github.com/Edison-Hsu/100-days-of-RxSwift",
                fullName: "Edison-Hsu/100-days-of-RxSwift",
                description: ":dash:100 days and 40 project of RxSwift",
                starCount: 188,
                watcherCount: 188,
                forkCount: 38
            ),
            Repository(
                id: 48885353,
                avatarURL: "https://avatars.githubusercontent.com/u/15903991?v=4",
                url: "https://github.com/RxSwiftCommunity/RxDataSources",
                fullName: "RxSwiftCommunity/RxDataSources",
                description: "UITableView and UICollectionView Data Sources for RxSwift (sections, animated updates, editing ...)",
                starCount: 2856,
                watcherCount: 2856,
                forkCount: 473
            ),
            Repository(
                id: 86144692,
                avatarURL: "https://avatars.githubusercontent.com/u/5118864?v=4",
                url: "https://github.com/AloneMonkey/RxSwiftStudy",
                fullName: "AloneMonkey/RxSwiftStudy",
                description: "RxSwift Article And  Study Demo ",
                starCount: 261,
                watcherCount: 261,
                forkCount: 34
            ),
            Repository(
                id: 94960870,
                avatarURL: "https://avatars.githubusercontent.com/u/1037944?v=4",
                url: "https://github.com/glassonion1/RxStoreKit",
                fullName: "glassonion1/RxStoreKit",
                description: "StoreKit library for RxSwift",
                starCount: 103,
                watcherCount: 103,
                forkCount: 32
            )
        ]
    )

}
