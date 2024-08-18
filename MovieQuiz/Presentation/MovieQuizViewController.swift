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
    
    func showAnswerResult(isCorrect: Bool) {
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
            self.presenter.showNextQuestionOrResults()
            yesButton.isEnabled = true
            noButton.isEnabled = true
        }
    }
    
    func show(quiz result: QuizResultsViewModel)
    {
        let alertModel = AlertModel(
            title: result.title,
            message: result.text + "\n\(statisticService?.generateStatisticString() ?? "Error")",
            buttonText: result.buttonText,
            completion:{_ in
                self.presenter.resetQuestionIndex()
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
        statisticService = StatisticService()
        let alertPresenter = AlertPresenter()
        alertPresenter.delegate = self
        self.alertPresenter = alertPresenter
        showLoadingIndicator()
        presenter = MovieQuizPresenter(viewController: self)
    }
    
}


