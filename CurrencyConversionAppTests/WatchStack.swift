import Foundation
import RxSwift

@testable import CurrencyConversionApp

final class WatchStack<T> {

    let disposeBag = DisposeBag()

    private let _vars = Variable<[T]>([])
    var vars: [T] {
        return _vars.value
    }

    var errors: [Error] = []
    let semaphore = DispatchSemaphore(value: 0)

    init<O>(_ observable: O) where O: ObservableType, T == O.Element {
        _vars.value.reserveCapacity(10)
        observable
            .subscribe(
                onNext: { [weak self] v in
                    guard let me = self else { return }
                    me._vars.value.append(v)
                    me.semaphore.signal()
                },
                onError: { [weak self] e in
                    guard let me = self else { return }
                    me.errors.append(e)
                    me.semaphore.signal()
                }
            )
            .disposed(by: disposeBag)
    }

    // Latest value received
    var value: T? {
        return _vars.value.last
    }

    // First value stacked
    var first: T? {
        return _vars.value.first
    }

    // Size of stack
    var count: Int {
        return _vars.value.count
    }

    // Clean all variables
    func clean() {
        _vars.value.removeAll()
    }

    // Wait until value received
    func wait(_ seconds: Double = 1.0) {
        _ = semaphore.wait(timeout: DispatchTime.now() + seconds)
    }

    // Latest error received
    var error: Error? {
        if errors.count == 0 {
            wait() // wait for 1 sec
        }
        return errors.last
    }

}
