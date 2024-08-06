import Foundation

final class StatisticService: StatisticServiceProtocol{
    private enum Keys: String {
        case totalCorrectAmount
        case correct
        case bestGame_correct
        case bestGame_total
        case bestGame_date
        case gamesCount
        case totalQuestionsAmount
    }
    
    private let storage: UserDefaults = .standard
    
    var gamesCount: Int {
        get { return storage.integer(forKey: Keys.gamesCount.rawValue) }
        set { storage.set(newValue, forKey: Keys.gamesCount.rawValue) }
    }
    
    var bestGame: GameResult
    {
        get {
            return GameResult(correct: storage.integer(forKey: Keys.bestGame_correct.rawValue),
                              total: storage.integer(forKey: Keys.bestGame_total.rawValue),
                              date: storage.object(forKey: Keys.bestGame_date.rawValue) as? Date ?? Date())
        }
        set {
            storage.setValue(newValue.correct, forKey: Keys.bestGame_correct.rawValue)
            storage.setValue(newValue.total, forKey: Keys.bestGame_total.rawValue)
            storage.setValue(newValue.date, forKey: Keys.bestGame_date.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        Double(totalCorrectAmount)/Double(totalQuestionsAmount) * 100
    }
    
    var totalQuestionsAmount: Int {
        get { storage.integer(forKey: Keys.totalQuestionsAmount.rawValue) }
        set { storage.set(newValue, forKey: Keys.totalQuestionsAmount.rawValue) }
    }
    
    var totalCorrectAmount: Int {
        get { storage.integer(forKey: Keys.totalCorrectAmount.rawValue) }
        set { storage.set(newValue, forKey: Keys.totalCorrectAmount.rawValue)}
    }
    
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        totalQuestionsAmount += amount
        totalCorrectAmount += count
        let currentGameResult = GameResult(correct: count, total: amount, date: Date())
        if currentGameResult.isBetterThan(bestGame){
            bestGame = currentGameResult
        }
    }
    
    func generateStatisticString() -> String {
        return "Количество сыграных квизов: \(gamesCount)\nРекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))\nСредняя точность: \(String(format: "%.2f",  totalAccuracy))%"
    }
}
