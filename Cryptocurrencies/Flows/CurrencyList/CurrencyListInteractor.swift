//
//  CurrencyListInteractor.swift
// cryptocurrencies
//
//  Created by Osman Ahmed on 23/12/2022.
//

import SwiftUI
import Foundation

// MARK: - CurrencyListInteractorProtocol

protocol CurrencyListInteractorProtocol {
    func fetchCurrency(_ action: ( () -> Void)?)
    func refresh()
    func loadMoreContent(currentItem item: CryptocurrencyModel)
}

// MARK: - CurrencyListInteractor

class CurrencyListInteractor {
    private let apiManager: ApiManagerProtocol
    private var data: Data?
    private let decoder = JSONDecoder()
    private var presenter: CurrencyListPresenterProtocol
    private var cryptocurrencyModel: [CryptocurrencyModel] = []
    // Tells if all records have been loaded. (Used to hide/show activity spinner)
    private var membersListFull = false
    // Tracks last page loaded. Used to load next page (current + 1)
    private var currentPage = 0
    // Limit of records per page. (Only if backend supports, it usually does)
    private let perPage = 20
    private var isFetching = false
    
    init(apiManager: ApiManagerProtocol, presenter: CurrencyListPresenterProtocol) {
        self.apiManager = apiManager
        self.presenter = presenter
        fetchCurrency()
    }
}


// MARK: CurrencyListInteractorProtocol

extension CurrencyListInteractor: CurrencyListInteractorProtocol {
    func refresh() {
        if !isFetching {
            currentPage = 0
            fetchCurrency()
        }
    }
    
    //MARK: - PAGINATION
    func loadMoreContent(currentItem item: CryptocurrencyModel){
        if cryptocurrencyModel.isLastItem(item) {
            fetchCurrency(nil)
        }
    }
    
    func fetchCurrency(_ action: ( () -> Void)? = nil) {
        if !isFetching {
            isFetching = true
            let start = "\(currentPage * perPage + 1)"
            let perPageStr = "\(perPage)"
            let request = FetchCurrencyRequest(start: start, limit: perPageStr)
            apiManager.apiRequest(request, withSuccess: { [weak self] (response: FetchCurrencyResponse?, _, _) in
                if let CurrencyBaseModel = response?.CurrencyList {
                    self?.currentPage += 1
                    if CurrencyBaseModel.cryptocurrencyModel?.count ?? 0 < self?.perPage ?? 10 {
                        self?.membersListFull = true
                    }
                    // notify presenter
                    DispatchQueue.main.async {
                        self?.presenter.CurrencyListSuccessed(model: CurrencyBaseModel)
                    }
                }
                self?.isFetching = false
            }) { (error: Error) in
                DispatchQueue.main.async {
                    #warning("add custom error enum")
                    self.presenter.CurrencyListFaild(error: error.localizedDescription)
                    self.isFetching = false
                }
            }
        }
    }
}


extension RandomAccessCollection where Self.Element: Identifiable {
    public func isLastItem<Item: Identifiable>(_ item: Item) -> Bool {
        guard !isEmpty else {
            return false
        }
        
        guard let itemIndex = lastIndex(where: { AnyHashable($0.id) == AnyHashable(item.id) }) else {
            return false
        }
        
        let distance = self.distance(from: itemIndex, to: endIndex)
        return distance == 1
    }
    
    public func isThresholdItem<Item: Identifiable>(
        offset: Int,
        item: Item
    ) -> Bool {
        guard !isEmpty else {
            return false
        }
        
        guard let itemIndex = lastIndex(where: { AnyHashable($0.id) == AnyHashable(item.id) }) else {
            return false
        }
        
        let distance = self.distance(from: itemIndex, to: endIndex)
        let offset = offset < count ? offset : count - 1
        return offset == (distance - 1)
    }
}