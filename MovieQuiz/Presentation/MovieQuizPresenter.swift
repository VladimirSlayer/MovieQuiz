import UIKit

final class MovieQuizPresenter{
    
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    
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
    
    private func yesOrNoClicked(givenAnswer: Bool, currentQuestion: QuizQuestion?)
    {
        guard let currentQuestion = currentQuestion else
        {
            return
        }
        let givenAnswer = givenAnswer
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
}
