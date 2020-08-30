import RxAlamofire
import RxSwift

public final class CurrencyLayerAPI {
    private let disposeBag = DisposeBag()

    public static func requestCurrenciesList() -> Observable<[String: String]> {
        let parameters = ["access_key": Const.accessKey]
        return RxAlamofire.requestJSON(.get,
                                       Const.currenciesListRequest,
                                       parameters: parameters)
            .flatMap { _, json -> Observable<[String: String]> in
                guard let dict = json as? [String: AnyObject],
                    let currencies = dict["currencies"] as? [String: String] else {
                        // TODO: Create an error class, and handle errors more properly
                        return .error(NSError(domain:"", code:0, userInfo:nil))
                }
                return .just(currencies)
            }
    }

    public static func requestRates() -> Observable<[String: Double]> {
        let parameters = ["access_key": Const.accessKey]
        return RxAlamofire.requestJSON(.get,
                                       Const.ratesRequest,
                                       parameters: parameters)
            .flatMap { _, json -> Observable<[String: Double]> in
                guard let dict = json as? [String: AnyObject],
                    let rates = dict["quotes"] as? [String: Double] else {
                        // TODO: Create an error class, and handle errors more properly
                        return .error(NSError(domain:"", code:0, userInfo:nil))
                }
                return .just(rates)
            }
    }
}

// MARK: - Const

extension CurrencyLayerAPI {
    fileprivate enum Const {
        static let accessKey = "08fa349892f3c1e40344e743de9d9c48"
        static let currenciesListRequest = "http://api.currencylayer.com/list"
        static let ratesRequest = "http://api.currencylayer.com/live"
    }
}
