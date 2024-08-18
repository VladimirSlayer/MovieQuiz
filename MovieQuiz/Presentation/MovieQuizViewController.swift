import UIKit

final class MovieQuizViewController: UIViewController{
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    private var correctAnswers = 0
    private var statisticService: StatisticServiceProtocol?
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter = AlertPresenter()
    private var currentQuestion: QuizQuestion?
    private let presenter = MovieQuizPresenter()

    
    @IBAction private func yesButtonClicked(_ sender: Any)
    {
        yesOrNoClicked(givenAnswer: true, currentQuestion: currentQuestion)
    }
    
    @IBAction private func noButtonClicked(_ sender: Any)
    {
        yesOrNoClicked(givenAnswer: false, currentQuestion: currentQuestion)
    }
    
    private func showLoadingIndicator(){
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator(){
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message:String){
        hideLoadingIndicator()
        
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз",
            completion: {_ in
                self.presenter.resetQuestionIndex()
                self.correctAnswers = 0
                
                self.questionFactory?.requestNextQuestion()})
        alertPresenter.showAlert(alertModel: model)
    }
    
    private func showNextQuestionOrResults()
    {
        if presenter.isLastQuestion()
        {
            statisticService?.store(correct: correctAnswers, total: presenter.questionsAmount)
            let results = QuizResultsViewModel(title: "Этот раунд окончен!", text: "Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)", buttonText: "Сыграть ещё раз")
            show(quiz: results)
        }
        else
        {
            presenter.switchToNextQuestion()
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        yesButton.isEnabled = false
        noButton.isEnabled = false
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        if isCorrect
        {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            correctAnswers+=1
        }
        else
        {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {[weak self] in
            guard let self = self else {return}
            self.showNextQuestionOrResults()
            yesButton.isEnabled = true
            noButton.isEnabled = true
        }
    }
    
    private func show(quiz result: QuizResultsViewModel)
    {
        let alertModel = AlertModel(
            title: result.title,
            message: result.text + "\n\(statisticService?.generateStatisticString() ?? "Error")",
            buttonText: result.buttonText,
            completion:{_ in
                self.presenter.resetQuestionIndex()
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
            })
        alertPresenter.showAlert(alertModel: alertModel)
    }
    
    private func show(quiz step: QuizStepViewModel)
    {
        imageView.image = step.image
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = nil
        imageView.layer.cornerRadius = 20
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        statisticService = StatisticService()
        let questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        self.questionFactory = questionFactory
        questionFactory.requestNextQuestion()
        let alertPresenter = AlertPresenter()
        alertPresenter.delegate = self
        self.alertPresenter = alertPresenter
        showLoadingIndicator()
        questionFactory.loadData()
    }
    
    private func yesOrNoClicked(givenAnswer: Bool, currentQuestion: QuizQuestion?)
    {
        guard let currentQuestion = currentQuestion else
        {
            return
        }
        let givenAnswer = givenAnswer
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
}

extension MovieQuizViewController: QuestionFactoryDelegate{
    func didReceiveNextQuestion(question: QuizQuestion?){
        guard let question = question else
        {
            return
        }
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: any Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    
}


