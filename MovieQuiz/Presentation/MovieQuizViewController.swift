import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol{
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    private var correctAnswers = 0
    private var alertPresenter = AlertPresenter()
    private var presenter: MovieQuizPresenter!
    
    
    
    @IBAction private func yesButtonClicked(_ sender: Any)
    {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: Any)
    {
        presenter.noButtonClicked()
    }
    
    func showLoadingIndicator(){
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator(){
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message:String){
        hideLoadingIndicator()
        
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз",
            completion: {_ in
                self.presenter.resetQuestionIndex()
                self.presenter.restartGame()
            })
        alertPresenter.showAlert(alertModel: model)
    }
    
    func disableButtons(){
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    func enableButtons(){
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func show(quiz result: QuizResultsViewModel)
    {
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion:{_ in
                self.presenter.restartGame()
            })
        alertPresenter.showAlert(alertModel: alertModel)
    }
    
    func show(quiz step: QuizStepViewModel)
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
        let alertPresenter = AlertPresenter()
        alertPresenter.delegate = self
        self.alertPresenter = alertPresenter
        showLoadingIndicator()
        presenter = MovieQuizPresenter(viewController: self)
    }
    
}

protocol MovieQuizViewControllerProtocol: AnyObject{
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func disableButtons()
    func enableButtons()
    
    func showNetworkError(message: String)
}


