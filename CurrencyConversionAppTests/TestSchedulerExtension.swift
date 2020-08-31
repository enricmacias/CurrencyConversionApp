import RxTest

extension TestScheduler {
    func wait(_ interval: Int) {
        advanceTo(clock + interval)
    }
}
