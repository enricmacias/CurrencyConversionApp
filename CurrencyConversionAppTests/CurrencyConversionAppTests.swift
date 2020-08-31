import RxTest
import XCTest
import RxSwift
import RxCocoa
import Action

@testable import CurrencyConversionApp

final class CurrencyConversionAppTests: XCTestCase {

    private var dependency: Dependency!

    override func setUp() {
        dependency = Dependency()
    }
    
    // TODO: currenciesNames test
    
    // TODO: convertedRates test
    
    // TODO: reloadTableView test
    
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
    
    /*func test_isLoadingHidden() {
        let eventStack = WatchStack(dependency.testTarget.isLoadingHidden)
        XCTAssertEqual(eventStack.count, 1, "on init")
        
        let fetchCurrencies = Action<Void, [Currency]> { _ in
            return .just([Currency(name: "currency", code: "currency_id")])
        }
        //dependency.testTarget.fetchCurrencies.execute()
        
        XCTAssertEqual(eventStack.count, 2, "on fetching")
    }*/
    
    /*func test_selectedCurrency() {
        let eventStack = WatchStack(dependency.testTarget.selectedCurrency)
        XCTAssertEqual(eventStack.count, "USD", "on init")
        
        // TODO: set mock currencies
        dependency.selectedRowInCurrencyPicker.accept(1)
        XCTAssertEqual(eventStack.count, 2, "on element selected in picker")
    }*/
    
    // TODO: showError test

}

// MARK: - Dependency

extension CurrencyConversionAppTests {

    private struct Dependency {
        let currencyButtonTriggered = PublishRelay<Void>()
        let doneButtonTriggered = PublishRelay<Void>()
        let selectedRowInCurrencyPicker = PublishRelay<Int>()
        let amountTextFieldText = PublishRelay<String?>()
        
        let testTarget: CurrencyConverterTableViewControllerStream
        
        init() {
            testTarget = CurrencyConverterTableViewControllerStream(currencyButtonTriggered: currencyButtonTriggered.asObservable(),
                                                                    doneButtonTriggered: doneButtonTriggered.asObservable(),
                                                                    selectedRowInCurrencyPicker: selectedRowInCurrencyPicker.asObservable(),
                                                                    amountTextFieldText: amountTextFieldText.asObservable())
        }
    }
}
