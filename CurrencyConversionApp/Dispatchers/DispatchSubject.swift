import RxSwift

class DispatchSubject<Element>: ObservableType, ObserverType {
    typealias E = Element
    fileprivate let subject = PublishSubject<Element>()

    init() {}

    func dispatch(_ value: Element) {
        onNext(value)
    }

    func subscribe<O: ObserverType>(_ observer: O) -> Disposable where O.Element == Element {
        return subject.subscribe(observer)
    }

    func on(_ event: Event<E>) {
        subject.on(event)
    }
}
