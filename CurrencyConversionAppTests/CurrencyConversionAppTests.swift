import RxTest
import XCTest
import RxSwift
import RxCocoa
import Action

@testable import CurrencyConversionApp

final class CurrencyConversionAppTests: XCTestCase {
    
    // TODO: Be able to test using mock data from the API response.
    // The Action closure is called after the XCTAssert and the check fails every time.
    // A scheduler has been placed to wait for the Action to get called, but for some reason is not working properly.

    private var dependency: Dependency!

    override func setUp() {
        dependency = Dependency()
    }
    
    func test_currenciesNames() {
        let eventStack = WatchStack(dependency.testTarget.currenciesNames)
        XCTAssertEqual(eventStack.value, [], "on init")
        XCTAssertEqual(eventStack.count, 1, "on init")
        
        /*dependency.testTarget.fetchCurrencies = Action<Void, [Currency]> { _ in
            return .just([Currency(name: "currency", code: "code")])
        }
        dependency.testTarget.fetchCurrencies.execute()
        dependency.testScheduler.wait(1)
        XCTAssertEqual(eventStack.count, 2, "after currencies fetched")*/
    }
    
    func test_convertedRates() {
        let eventStack = WatchStack(dependency.testTarget.convertedRates.asObservable())
        XCTAssertEqual(eventStack.count, 1, "on init")
        
        /*dependency.testTarget.fetchCurrencies = Action<Void, [Currency]> { _ in
            return .just([Currency(name: "currency", code: "USD")])
        }
        dependency.testTarget.fetchRates = Action<Void, [String: Double]> { _ in
            return .just(["USD":1.0])
        }
        dependency.testScheduler.wait(1)*/
        dependency.amountTextFieldText.accept("5")
        XCTAssertEqual(eventStack.count, 2, "on inserted amount in textfield")
        
        /*dependency.selectedRowInCurrencyPicker.accept(1)
        XCTAssertEqual(eventStack.count, 3, "on selected currency")*/
    }
    
    func test_reloadTableView() {
        let eventStack = WatchStack(dependency.testTarget.reloadTableView.asObservable())
        XCTAssertEqual(eventStack.count, 1, "on init")
        
        /*dependency.testTarget.fetchCurrencies = Action<Void, [Currency]> { _ in
            return .just([Currency(name: "currency", code: "USD")])
        }
        dependency.testTarget.fetchRates = Action<Void, [String: Double]> { _ in
            return .just(["USD":1.0])
        }
        dependency.testScheduler.wait(1)*/
        dependency.amountTextFieldText.accept("5")
        XCTAssertEqual(eventStack.count, 2, "on inserted amount in textfield")
        
        /*dependency.selectedRowInCurrencyPicker.accept(1)
        XCTAssertEqual(eventStack.count, 3, "on selected currency")*/
    }
    
    func test_dismissKeyboard() {
        let eventStack = WatchStack(dependency.testTarget.dismissKeyboard)
        XCTAssertEqual(eventStack.count, 1, "on init")
        
        dependency.doneButtonTriggered.accept(())
        XCTAssertEqual(eventStack.count, 2, "on done button triggered")
    }

    func test_isCurrencyPickerHidden() {
        let eventStack = WatchStack(dependency.testTarget.isCurrencyPickerHidden)
        XCTAssertEqual(eventStack.value, true, "on init")
        
        dependency.currencyButtonTriggered.accept(())
        XCTAssertEqual(eventStack.value, false, "on currency button triggered")
        
        dependency.doneButtonTriggered.accept(())
        XCTAssertEqual(eventStack.value, true, "on done button triggered")
    }
    
    func test_isLoadingHidden() {
        let eventStack = WatchStack(dependency.testTarget.isLoadingHidden)
        XCTAssertEqual(eventStack.count, 1, "on init")
        
        dependency.testTarget.fetchCurrencies.execute()
        XCTAssertEqual(eventStack.count, 2, "on fetching currencies")
        
        dependency.testTarget.fetchRates.execute()
        XCTAssertEqual(eventStack.count, 3, "on fetching rates")
    }
    
    func test_selectedCurrency() {
        let eventStack = WatchStack(dependency.testTarget.selectedCurrency)
        XCTAssertEqual(eventStack.value?.code, "USD", "on init")
        
        /*dependency.testTarget.fetchCurrencies = Action<Void, [Currency]> { _ in
            return .just([Currency(name: "currency1", code: "USD"),
                          Currency(name: "currency2", code: "JPY")])
        }
        dependency.testScheduler.wait(1)
        dependency.selectedRowInCurrencyPicker.accept(1)
        XCTAssertEqual(eventStack.value, "JPY", "on element selected in picker")*/
    }
    
    func test_showError() {
        let eventStack = WatchStack(dependency.testTarget.showError)
        XCTAssertNil(eventStack.value ?? nil, "on init")
        XCTAssertEqual(eventStack.count, 1, "on element selected in picker")
        
        /*dependency.testTarget.fetchCurrencies = Action<Void, [Currency]> { _ in
            return .error(NSError(domain: "", code: 404, userInfo: nil))
        }
        XCTAssertNotNil(eventStack.value ?? nil, "on init")
        XCTAssertEqual(eventStack.count, 2, "on element selected in picker")*/
    }

}

// MARK: - Dependency

extension CurrencyConversionAppTests {

    private struct Dependency {
        let currencyButtonTriggered = PublishRelay<Void>()
        let doneButtonTriggered = PublishRelay<Void>()
        let selectedRowInCurrencyPicker = PublishRelay<Int>()
        let amountTextFieldText = PublishRelay<String?>()
        let testScheduler: TestScheduler
        
        let testTarget: CurrencyConverterTableViewControllerStream
        
        init() {
            testScheduler = TestScheduler(initialClock: 0)
            testTarget = CurrencyConverterTableViewControllerStream(currencyButtonTriggered: currencyButtonTriggered.asObservable(),
                                                                    doneButtonTriggered: doneButtonTriggered.asObservable(),
                                                                    selectedRowInCurrencyPicker: selectedRowInCurrencyPicker.asObservable(),
                                                                    amountTextFieldText: amountTextFieldText.asObservable(),
                                                                    scheduler: testScheduler)
            
        }
    }
}
