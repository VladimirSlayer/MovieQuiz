import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate{
    
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    var currentQuestion: QuizQuestion?
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewController?
    var correctAnswers = 0
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel
    {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func isLastQuestion() -> Bool{
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion(){
        currentQuestionIndex += 1
    }
    
    func yesButtonClicked()
    {
        yesOrNoClicked(givenAnswer: true, currentQuestion: currentQuestion)
    }
    
    func noButtonClicked()
    {
        yesOrNoClicked(givenAnswer: false, currentQuestion: currentQuestion)
    }
    
    func restartGame(){
        correctAnswers = 0
        currentQuestionIndex = 0
        questionFactory?.requestNextQuestion()
    }
    
    func didAnswer(isCorrectAnswer: Bool){
        correctAnswers += 1
    }
    
    private func yesOrNoClicked(givenAnswer: Bool, currentQuestion: QuizQuestion?)
    {
        guard let currentQuestion = currentQuestion else
        {
            return
        }
        let givenAnswer = givenAnswer
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?){
        guard let question = question else
        {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func showNextQuestionOrResults()
    {
        if self.isLastQuestion()
        {
            //statisticService?.store(correct: correctAnswers, total: self.questionsAmount)
            let results = QuizResultsViewModel(title: "Этот раунд окончен!", text: "Ваш результат: \(self.correctAnswers)/\(self.questionsAmount)", buttonText: "Сыграть ещё раз")
            viewController?.show(quiz: results)
        }
        else
        {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
}
