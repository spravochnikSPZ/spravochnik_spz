//
//  AlertPresenter.swift
//  spravochnik_spz
//
//  Created by Максим Косников on 23.03.2023.
//


// MARK: - AlertPresenterProtocol

protocol AlertPresenterDelegate: AnyObject {
    func saveButtonPressed(type: CoefficientType, index: Int)
}

protocol AlertPresenterProtocol: AnyObject {
    func viewDidLoad()
    func rightButtonPressed()
    func leftButtonPressed()
    func method(type: CoefficientType, value: String?)
    func changeRightHandler(handler: (() -> Void)?)
}

// MARK: - ALertPresenter

final class AlertPresenter {
    weak var viewController: AlertViewProtocol?
    weak var delegate: AlertPresenterDelegate?
    
    // MARK: PrivateProperties
    private var rightButtonHandler: (() -> Void)?
    private let coefficientType: CoefficientType
    private let index: Int
    // MARK: - Initializer
    
    init(coefficientType: CoefficientType, index: Int) {
        self.coefficientType = coefficientType
        self.index = index
    }
}

// MARK: - AlertPresenterExtension

extension AlertPresenter: AlertPresenterProtocol {
    func viewDidLoad() {
        viewController?.changeKeyboard(type: coefficientType)
        switch coefficientType {
        case let .clear(model):
            let title = model.title
            let leftButtonTitle = model.leftButton
            let rightButtonTittle = model.rightButton
            rightButtonHandler = model.rightButtonHandler
            viewController?.updateUIForClear(title: title,
                                             leftButtonTitle: leftButtonTitle,
                                             rightButtonTitle: rightButtonTittle)
        case let .value(model):
            let title = model.type.title
            viewController?.updateUIForValue(title: title,
                                             value: model.value)
        case let .choice(model):
            viewController?.changeCurrectSelected(index: model.itemIndex)
            let axis = model.type
            let title = model.type.title
            let collectionViewDataSource = [String]()
            self.viewController?.update(dataSource: self.makeData(axis))
            viewController?.updateUIForChoice(title: title,
                                              axis: axis,
                                              numOfItems: 0)
        case let .defaultValue(model):
            let title = model.type.title
            let value = model.value ?? model.type.defaultValue
            viewController?.updateUIForValue(title: title, value: value)
        }
        viewController?.method(type: coefficientType)
    }
    
    private func makeData(_ axis: ChoiceСoefficientType) -> [String] {
        switch axis {
        case .numberOfLinesOfDefence:
            return ["1", "2", "3"]
        case .terrain:
            return ["Нормальный (перепад менее 1,5 м)", "Холмистый (перепад более 1,5 м)", "Гористый"]
        case .typeOfNotificationSystem:
            return ["1", "2", "3", "4", "5"]
        case .numberOfFirePumpGroups:
            return ["1", "2", "3", "4"]
        }
    }
    
    func leftButtonPressed() {
        viewController?.dismiss(animated: true) { }
    }
    
    func rightButtonPressed() {
        viewController?.dismiss(animated: true) { [self] in
            guard let handler = rightButtonHandler else { return }
            handler()
        }
    }
    
    func method(type: CoefficientType, value: String?) {
        switch type {
        case .clear(let model):
            rightButtonPressed()
        case .value(let model):
            var currentValue = value ?? ""
            
            if currentValue == "" && model.value != .zero {
                currentValue = String(model.value)
            }
            
            let newValue = replaceCommaWithDot(in: currentValue)
        
            let newModel = ValueСoefficientModel(type: model.type, value: newValue, stringValue: value) //TODO: переделать внесение stringValue
            let coefficientType = CoefficientType.value(model: newModel)
            delegate?.saveButtonPressed(type: coefficientType, index: index)
            (rightButtonHandler ?? {})()
            viewController?.dismiss(animated: true)
        case .choice(let model):
            let newModel = ChoiceCoefficientModel(type: model.type, itemIndex: viewController?.currentSelected)
            let coefficientType = CoefficientType.choice(model: newModel)
            viewController?.dismiss(animated: true)
            delegate?.saveButtonPressed(type: coefficientType, index: index)
        case .defaultValue(let model):
            var currentValue = value ?? ""
            
//            if currentValue == "" {
//                currentValue = String(model.type.defaultValue)
//            }
            
            if currentValue == "" && model.value != .zero {
                guard let _value = model.value else { return }
                currentValue = String(_value)
            }
            
//            guard let _currentValue = currentValue else { return }
            
            let newValue = replaceCommaWithDot(in: currentValue)
            
            let newModel = DefaultCoefficientValueModel(type: model.type, value: newValue)
            let coefficientType = CoefficientType.defaultValue(model: newModel)
            viewController?.dismiss(animated: true)
            delegate?.saveButtonPressed(type: coefficientType, index: index)
        }
    
        //saveButtonHandler?(coefficientType)
    }
    
    func changeRightHandler(handler: (() -> Void)?) {
        rightButtonHandler = handler
    }
}

enum CoefficientType {
    case clear(model: NoСoefficientModel)
    case value(model: ValueСoefficientModel)
    case choice(model: ChoiceCoefficientModel)
    case defaultValue(model: DefaultCoefficientValueModel)
}

private extension AlertPresenter {
    func replaceCommaWithDot(in number: String) -> Double {
        let stringRepresentation = number.replacingOccurrences(of: ",", with: ".")
        
        if let doubleValue = Double(stringRepresentation) {
            let roundedValue = (doubleValue * 100).rounded() / 100
            return roundedValue
        } else {
            return 0.0
        }
    }
}
