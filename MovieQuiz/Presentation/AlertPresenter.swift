import UIKit

class AlertPresenter{
    
    weak var delegate: MovieQuizViewController?
    
    func setup(delegate: MovieQuizViewController)
    {
        self.delegate = delegate
    }
    
    func showAlert(alertModel: AlertModel)
    {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)
        let action = UIAlertAction(
            title: alertModel.buttonText,
            style: .default,
            handler: alertModel.completion)
        alert.addAction(action)
        delegate?.present(alert, animated: true, completion: nil)
    }
}
