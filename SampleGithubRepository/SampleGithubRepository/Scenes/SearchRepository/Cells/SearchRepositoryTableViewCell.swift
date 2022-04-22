//
//  SearchRepositoryTableViewCell.swift
//


import UIKit
import SnapKit
import MKUtils

class SearchRepositoryTableViewCell: UITableViewCell {
    var uuid: UUID? = nil
    
    lazy var thumbnailImageView: UIImageView = {
        let v = UIImageView()
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 15
        return v
    }()

    lazy var titleLabel: UILabel = {
        let v = UILabel()
        v.font = UIFont.boldSystemFont(ofSize: 17)
        v.numberOfLines = 0
        return v
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        DispatchQueue.main.async { [weak self] in
            self?.thumbnailImageView.image = nil
        }
    }
    
    func set(model: SearchRepositoryTableViewCellModel) {
        
        self.fetchImage(model: model, retryCount: 0)
    }
}

extension SearchRepositoryTableViewCell {
    private func setUI() {
        self.contentView.addSubview(self.thumbnailImageView)
        self.thumbnailImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().inset(8)
            make.width.height.equalTo(60)
        }
        
        self.contentView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.thumbnailImageView.snp.right).offset(20)
            make.right.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(8)
        }
        
    }
    
    private func fetchImage(model: SearchRepositoryTableViewCellModel, retryCount: Int = 0) {
        let local = UUID()
        self.uuid = local
        
        DispatchQueue.main.async { [weak self] in
            self?.thumbnailImageView.image = nil
            self?.titleLabel.text = "retry \(retryCount)\n" + model.repositoryName
        }
        
        model.fetchImage(completion: { [weak self] result in
            
            switch result {
                case let .success(image):
                    DispatchQueue.main.async {
                        self?.titleLabel.text = "retry \(retryCount) Success\n " + model.repositoryName
                        self?.thumbnailImageView.image = (local == self?.uuid) ? image : nil
                    }
                    
                case let .failure(error):
                    DispatchQueue.main.async {
                        self?.thumbnailImageView.image = nil
                    }
                    switch error {
                        case .timeout:

                            let count = retryCount + 1
                            if count <= 2 {
                                self?.fetchImage(model: model, retryCount: count)
                            }
                            else {
                                DispatchQueue.main.async {
                                    self?.titleLabel.text = "FAILED ! \n" + model.repositoryName
                                }
                            }
                            Debug.print(model.repositoryName)
                            Debug.print(error.localizedDescription)
                            
                        case .unknown:
                            DispatchQueue.main.async {
                                self?.titleLabel.text = "FAILED ! \n" + model.repositoryName
                            }
                            Debug.print(error.localizedDescription)
                    }
                    
            }
        })
    }
}
