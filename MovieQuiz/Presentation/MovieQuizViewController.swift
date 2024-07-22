import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private var statisticService: StatisticService?
    private var questionFactory: QuestionFactoryProtocol = QuestionFactory()
    private var alertPresenter = AlertPresenter()
    private var currentQuestion: QuizQuestion?
    
    @IBAction private func yesButtonClicked(_ sender: Any) 
    {
        yesOrNoClicked(givenAnswer: true, currentQuestion: currentQuestion)
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) 
    {
        yesOrNoClicked(givenAnswer: false, currentQuestion: currentQuestion)
    }
    
    private func showNextQuestionOrResults() 
    {
        if currentQuestionIndex == questionsAmount - 1
        {
            statisticService?.store(correct: correctAnswers, total: 10)
            let results = QuizResultsViewModel(title: "Этот раунд окончен!", text: "Ваш результат: \(correctAnswers)/10", buttonText: "Сыграть ещё раз")
            show(quiz: results)
        }
        else 
        {
            currentQuestionIndex += 1
            self.questionFactory.requestNextQuestion()
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
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                self.questionFactory.requestNextQuestion()
            })
        alertPresenter.showAlert(alertModel: alertModel)
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel
    {
        let viewModel = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return viewModel
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
        let questionFactory = QuestionFactory()
        questionFactory.setup(delegate: self)
        self.questionFactory = questionFactory
        questionFactory.requestNextQuestion()
        let alertPresenter = AlertPresenter()
        alertPresenter.setup(delegate: self)
        self.alertPresenter = alertPresenter
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?)
    {
        guard let question = question else
        {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
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


