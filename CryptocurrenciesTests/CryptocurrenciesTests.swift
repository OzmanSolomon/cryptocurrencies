//
//cryptocurrenciesTests.swift
//cryptocurrenciesTests
//
//  Created by Osman Ahmed on 23/12/2022.
//


@testable import Cryptocurrencies
import XCTest

class WeatherAppTests: XCTestCase {
    var apiManager: ApiManager!
    var environmentManager: EnvironmentManager!
    var currencyListPresenter: CurrencyListPresenterProtocol!
    var currencyListInteractor: CurrencyListInteractorProtocol!
    var store: AppState!

    override func setUpWithError() throws {
        currencyListPresenter = CurrencyListPresenter()
        apiManager = ApiManager()
        store = AppState.shared
    }

    override func tearDownWithError() throws {
        environmentManager = nil
        apiManager = nil
        currencyListPresenter = nil
        currencyListInteractor = nil
        store = AppState()
    }

    func test_interactor() {
        let expectation = self.expectation(description: "interactor")
        XCTAssertNotNil(store.stateCalculator)
        currencyListInteractor.fetchCurrency() {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 9, handler: nil)
        XCTAssertNotEqual(store.stateCalculator, AppStateEnum.loading)
    }

    func test_Presenter_faild() {
        store.stateCalculator = .idle
        currencyListPresenter.CurrencyListFaild(error: "error")
        XCTAssertEqual(store.stateCalculator, AppStateEnum.failed("error"))
    }
}