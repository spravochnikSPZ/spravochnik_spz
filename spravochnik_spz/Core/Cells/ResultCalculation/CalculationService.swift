//
//  CalculationService.swift
//  spravochnik_spz
//
//  Created by Swift Learning on 16.05.2023.
//
protocol CalculationServicable {
    func calculate(
        type: СalculationType,
        defaulValueCoefficients: [DefaultCoefficientValueModel],
        valueCoefficients: [ValueСoefficientModel],
        choiceCoefficients: [ChoiceCoefficientModel],
        checkboxCoefficients: [CheckboxСoefficientModel]
    ) -> [CalculationResultModel]
}

final class CalculationService {
    private var defaulValueCoefficients: [DefaultCoefficientValueModel] = []
    private var valueCoefficients: [ValueСoefficientModel] = []
    private var choiceCoefficients: [ChoiceCoefficientModel] = []
    private var checkboxCoefficients: [CheckboxСoefficientModel] = []

}

extension CalculationService: CalculationServicable {
    func calculate(
        type: СalculationType,
        defaulValueCoefficients: [DefaultCoefficientValueModel],
        valueCoefficients: [ValueСoefficientModel],
        choiceCoefficients: [ChoiceCoefficientModel],
        checkboxCoefficients: [CheckboxСoefficientModel]
    ) -> [CalculationResultModel] {
        self.defaulValueCoefficients = defaulValueCoefficients
        self.valueCoefficients = valueCoefficients
        self.choiceCoefficients = choiceCoefficients
        self.checkboxCoefficients = checkboxCoefficients
    
        switch type {
        case .securityAlarm:
            return calculateSecurityAlarm()
        case .perimeterSecurityAlarm:
            return calculatePerimeterSecurityAlarm()
        case .fireAlarmSystem:
            return calculateFireAlarmSystem()
        case .fireWarningSystem:
            return calculateFireWarningSystem()
        case .modularFireExtinguishingSystems:
            return calculateModularFireExtinguishingSystems()
        case .smokeRemovalControlSystem:
            return calculateSmokeRemovalControlSystem()
        case .pumpingStationsOfFireExtinguishingInstallations:
            return calculatePumpingStationsOfFireExtinguishingInstallations()
        }
    }
}

private extension CalculationService {
    private func calculateSecurityAlarm() -> [CalculationResultModel] {
        //Value - м2
        var price: Double = .zero
        valueCoefficients.forEach { value in
            if value.type == .objectArea {
                switch value.value {
                case 0...100:
                    price = 540
                case 100...200:
                    price = 623
                case 200...400:
                    price = 738
                case 400...700:
                    price = 875
                case 700...1_000:
                    price = 1_037
                case 1_000...2_000:
                    price = 2_074
                case 2_000...3_000:
                    price = 2_696
                case 3_000...5_000:
                    price = 3317
                case 5_000...7_000:
                    price = 3_940
                case 7_000...10_000:
                    price = 4561
                case 10_000...13_000:
                    price = 5_184
                case 13_000...17_000:
                    price = 5_702
                case 17_000...21_000:
                    price = 6_140
                case 21_000...25_000:
                    price = 6_530
                case let x where x > 25_000:
                    let temp = Int(x - 25_000)
                    price = 6_530 + (0.366 * Double(temp))
                default:
                    price = 540
                }
            }
        }
        
        //Choice
        var linesOfDefCoef: Double = .zero
        choiceCoefficients.forEach{ lines in
            if lines.type == .numberOfLinesOfDefence {
                switch lines.itemIndex {
                case 0:
                    linesOfDefCoef = 1
                case 1:
                    linesOfDefCoef = 1.2
                case 2:
                    linesOfDefCoef = 1.3
                default:
                    linesOfDefCoef = 1
                }
            }
        }
        
        //Default
        var inflCoef: Double = 1
        defaulValueCoefficients.forEach { coef in
            if coef.type == .inflationRate {
                inflCoef = coef.value ?? coef.type.defaultValue
            }
        }
        
        //Checkbox
        var flag = false
        var specialPurposeCoef: Double = 1
        var outdoorEquipCoef: Double = 1
        var architectCoef: Double = 1
        var importOrNewCoef: Double = 1
        var explosivesZonezCoef: Double = 1
        var highOrLowTempCoef: Double = 1
        var hiddenLayingCoef: Double = 1
        checkboxCoefficients.forEach { checkbox in
            if checkbox.isSelected == true {
                switch checkbox.type {
                case .twoStageDocumentationDevelopment:
                    flag.toggle()
                case .objectOfArchitecturalAndHistoricalValue:
                    architectCoef = 1.3
                case .thePresenceOfHiddenLayingOfEngineeringCommunications:
                    hiddenLayingCoef = 1.2
                case .outdoorEquipmentInstallation:
                    outdoorEquipCoef = 1.1
                case .specialPurposeObject:
                    specialPurposeCoef = 1.4
                case .usingImportedOrNewEquipment:
                    importOrNewCoef = 1.3
                case .presenceOfExplosiveZones:
                    explosivesZonezCoef = 1.3
                case .presenceOfHighOrLowTemperatures:
                    highOrLowTempCoef = 1.2
                default:
                    break
                }
            }
        }
        
        price *= (linesOfDefCoef * inflCoef * specialPurposeCoef * outdoorEquipCoef * architectCoef * importOrNewCoef * explosivesZonezCoef * highOrLowTempCoef * hiddenLayingCoef)
        
        return makeResult(flag: flag, price: price)
    }
    
    private func calculatePerimeterSecurityAlarm() -> [CalculationResultModel] {
        //Value - км
        var price: Double = .zero
        var blockSectionsCoef: Double = 1
        valueCoefficients.forEach { value in
            switch value.type {
            case .lengthOfThePerimeter:
                switch value.value {
                case 0...0.2:
                    price = 800
                case 0.2...0.4:
                    price = 1_314
                case 0.4...0.6:
                    price = 1_724
                case 0.6...0.8:
                    price = 2_000
                case 0.8...1:
                    price = 2_206
                case 1...2:
                    price = 3_556
                case 2...3:
                    price = 4_636
                case 3...4:
                    price = 5_518
                case 4...5:
                    price = 6_400
                case 5...6:
                    price = 7_234
                case 6...7:
                    price = 8_068
                case 7...9:
                    price = 8_852
                case 9...11:
                    price = 9_636
                case 11...13:
                    price = 10_374
                case 13...15:
                    price = 11_108
                case let x where x > 15:
                    let temp = x - 15
                    price = 11_108 + (366 * Double(Int(temp)))
                default:
                    price = 800
                }
            case .numberOfBlockingSections:
                if value.value > 5 {
                    blockSectionsCoef = 1 + Double(((Int(value.value) + Int(value.value) % 4) / 4) - 1) * 0.15
                } else {
                    blockSectionsCoef = 1
                }
            default:
                break
            }
        }
        
        //Choice
        var linesOfDefCoef: Double = 1
        var terrainCoef: Double = 1
        choiceCoefficients.forEach{ lines in
            switch lines.type {
            case .numberOfLinesOfDefence:
                switch lines.itemIndex {
                case 0:
                    linesOfDefCoef = 1
                case 1:
                    linesOfDefCoef = 1.5
                case 2:
                    linesOfDefCoef = 1.7
                default:
                    linesOfDefCoef = 1
                }
            case .terrain:
                switch lines.itemIndex {
                case 0: // Нормальный
                    terrainCoef = 1
                case 1: // Холмистый
                    terrainCoef = 1.3
                case 2: // Гористый
                    terrainCoef = 1.6
                default:
                    terrainCoef = 1
                }
            default:
                break
            }
        }
        
        //Default
        var inflCoef: Double = 1
        defaulValueCoefficients.forEach { coef in
            if coef.type == .inflationRate {
                inflCoef = coef.value ?? coef.type.defaultValue
            }
        }
        
        //Checkbox
        var flag = false
        var specialPurposeCoef: Double = 1
        var architectCoef: Double = 1
        var importOrNewCoef: Double = 1
        var explosivesZonezCoef: Double = 1
        var highOrLowTempCoef: Double = 1
        var lightingCoef: Double = 1
        checkboxCoefficients.forEach { checkbox in
            if checkbox.isSelected == true {
                switch checkbox.type {
                case .twoStageDocumentationDevelopment:
                    flag.toggle()
                case .securityLightingProjectDevelopment:
                    lightingCoef = 1.5
                case .objectOfArchitecturalAndHistoricalValue:
                    architectCoef = 1.3
                case .specialPurposeObject:
                    specialPurposeCoef = 1.4
                case .usingImportedOrNewEquipment:
                    importOrNewCoef = 1.3
                case .presenceOfExplosiveZones:
                    explosivesZonezCoef = 1.3
                case .presenceOfHighOrLowTemperatures:
                    highOrLowTempCoef = 1.2
                default:
                    break
                }
            }
        }
        
        price *= (linesOfDefCoef * inflCoef * specialPurposeCoef * lightingCoef * architectCoef * importOrNewCoef * explosivesZonezCoef * highOrLowTempCoef * blockSectionsCoef * terrainCoef)
        
        return makeResult(flag: flag, price: price)
    }
    
    //TODO: - Should be fixed
    private func calculateFireAlarmSystem() -> [CalculationResultModel] {
        //Value - м2
        var price: Double = .zero
        valueCoefficients.forEach { value in
            switch value.type {
            case .objectArea:
                switch value.value {
                case 0...100:
                    price = 600
                case 100...200:
                    price = 692
                case 200...400:
                    price = 820
                case 400...700:
                    price = 972
                case 700...1_000:
                    price = 1_152
                case 1_000...2_000:
                    price = 2_304
                case 2_000...3_000:
                    price = 2_996
                case 3_000...5_000:
                    price = 3_686
                case 5_000...7_000:
                    price = 4_378
                case 7_000...10_000:
                    price = 5_068
                case 10_000...13_000:
                    price = 5_760
                case 13_000...17_000:
                    price = 6_336
                case 17_000...21_000:
                    price = 6_822
                case 21_000...25_000:
                    price = 7_256
                case let x where x > 25_000:
                    let temp = Int(x - 25000)
                    price = 7_256 + (0.108 * Double(temp))
                default:
                    price = 600
                }
            default:
                break
            }
        }
        
        //Default
        var inflCoef: Double = 1
        defaulValueCoefficients.forEach { coef in
            if coef.type == .inflationRate {
                inflCoef = coef.value ?? coef.type.defaultValue
            }
        }
        
        //Checkbox
        var flag = false
        var manualFlag = false
        var automaticFlag = false
        var specialPurposeCoef: Double = 1
        var architectCoef: Double = 1
        var importOrNewCoef: Double = 1
        var explosivesZonezCoef: Double = 1
        var highOrLowTempCoef: Double = 1
        var individualEvacuationZonesCoef: Double = 1
        var hiddenGasketCoef: Double = 1
        var outdoorEquipment: Double = 1
        var automaticFireDetectorsCoef: Double = 1
        var manualFireDetectorsCoef: Double = 1
        var commandPulseCoef: Double = 1
        var opticalLinearDetectors: Double = 1
        checkboxCoefficients.forEach { checkbox in
            if checkbox.isSelected {
                switch checkbox.type {
                case .twoStageDocumentationDevelopment:
                    flag.toggle()
                case .availabilityOfAlertsForIndividualEvacuationZones:
                    individualEvacuationZonesCoef = 1.3
                case .availabilityOfAutomaticFireDetectors:
                    automaticFireDetectorsCoef = 1.15
                    automaticFlag = true
                case .availabilityOfManualFireDetectors:
                    manualFireDetectorsCoef = 1 // Какая-то херь здесь
                    manualFlag = true
                case .presenceOfACommandPulse:
                    commandPulseCoef = 1.5
                case .availabilityOfOpticalLinearDetectors:
                    opticalLinearDetectors = 1.2
                case .thePresenceOfAHiddenGasket:
                    hiddenGasketCoef = 1.2
                case .outdoorEquipmentInstallation:
                    outdoorEquipment = 1.1
                case .objectOfArchitecturalAndHistoricalValue:
                    architectCoef = 1.3
                case .specialPurposeObject:
                    specialPurposeCoef = 1.4
                case .usingImportedOrNewEquipment:
                    importOrNewCoef = 1.3
                case .presenceOfExplosiveZones:
                    explosivesZonezCoef = 1.3
                case .presenceOfHighOrLowTemperatures:
                    highOrLowTempCoef = 1.2
                default:
                    break
                }
            }
        }
        
        price *= (inflCoef * specialPurposeCoef * architectCoef * importOrNewCoef * explosivesZonezCoef * highOrLowTempCoef * individualEvacuationZonesCoef * hiddenGasketCoef * outdoorEquipment * automaticFireDetectorsCoef * manualFireDetectorsCoef * commandPulseCoef * opticalLinearDetectors)
        
        return makeResult(flag: flag, price: price)
    }
    
    private func calculateFireWarningSystem() -> [CalculationResultModel] {
        //Value - м2
        var price: Double = .zero
        valueCoefficients.forEach { value in
            switch value.type {
            case .objectArea:
                switch value.value {
                case 0...100:
                    price = 480
                case 100...200:
                    price = 554
                case 200...400:
                    price = 656
                case 400...700:
                    price = 778
                case 700...1_000:
                    price = 922
                case 1_000...2_000:
                    price = 1_843
                case 2_000...3_000:
                    price = 2_397
                case 3_000...5_000:
                    price = 2_949
                case 5_000...7_000:
                    price = 3_502
                case 7_000...10_000:
                    price = 4_054
                case 10_000...13_000:
                    price = 4_608
                case 13_000...17_000:
                    price = 5_069
                case 17_000...21_000:
                    price = 5_458
                case 21_000...25_000:
                    price = 5_805
                case let x where x > 25_000:
                    let temp = Int(x - 25000)
                    price = 5_805 + (0.108 * Double(temp))
                default:
                    price = 480
                }
            default:
                break
            }
        }
        
        //Choice
        var notificationTypeCoef: Double = 1
        choiceCoefficients.forEach { lines in
            switch lines.type {
            case .typeOfNotificationSystem:
                switch lines.itemIndex {
                case 0:
                    notificationTypeCoef = 1
                case 1:
                    notificationTypeCoef = 1.2
                case 2:
                    notificationTypeCoef = 1.44
                case 3:
                    notificationTypeCoef = 1.728
                case 4:
                    notificationTypeCoef = 2.0736
                default:
                    notificationTypeCoef = 1
                }
            default:
                break
            }
        }
        
        //Default
        var inflCoef: Double = 1
        defaulValueCoefficients.forEach { coef in
            if coef.type == .inflationRate {
                inflCoef = coef.value ?? coef.type.defaultValue
            }
        }
        
        //Checkbox
        var flag = false
        var specialPurposeCoef: Double = 1
        var architectCoef: Double = 1
        var importOrNewCoef: Double = 1
        var explosivesZonezCoef: Double = 1
        var highOrLowTempCoef: Double = 1
        var individualEvacuationZonesCoef: Double = 1
        var evacuationProjectCoef: Double = 1
        var hiddenGasketCoef: Double = 1
        var outdoorEquipment: Double = 1
        checkboxCoefficients.forEach { checkbox in
            if checkbox.isSelected == true {
                switch checkbox.type {
                case .twoStageDocumentationDevelopment:
                    flag.toggle()
                case .availabilityOfAlertsForIndividualEvacuationZones:
                    individualEvacuationZonesCoef = 1.3
                case .developmentOfTheEvacuationProject:
                    evacuationProjectCoef = 1.5
                case .thePresenceOfAHiddenGasket:
                    hiddenGasketCoef = 1.2
                case .outdoorEquipmentInstallation:
                    outdoorEquipment = 1.1
                case .objectOfArchitecturalAndHistoricalValue:
                    architectCoef = 1.3
                case .specialPurposeObject:
                    specialPurposeCoef = 1.4
                case .usingImportedOrNewEquipment:
                    importOrNewCoef = 1.3
                case .presenceOfExplosiveZones:
                    explosivesZonezCoef = 1.3
                case .presenceOfHighOrLowTemperatures:
                    highOrLowTempCoef = 1.2
                default:
                    break
                }
            }
        }
        
        
        price *= (notificationTypeCoef * inflCoef * specialPurposeCoef * architectCoef * importOrNewCoef * explosivesZonezCoef * highOrLowTempCoef * individualEvacuationZonesCoef * evacuationProjectCoef * hiddenGasketCoef * outdoorEquipment)
        
        return makeResult(flag: flag, price: price)
    }
    
    private func calculateModularFireExtinguishingSystems() -> [CalculationResultModel] {
        var price: Double = .zero
        valueCoefficients.forEach { value in
            switch value.type {
            case .numberOfProtectedPremises:
                switch value.value {
                case 0...2:
                    price = 2_560
                case 2...4:
                    price = 3_814
                case 4...6:
                    price = 5_068
                case 6...8:
                    price = 5_990
                case 8...12:
                    price = 6_910
                case let x where x > 12:
                    let temp = Int(x - 12)
                    price = 6_910 + (200 * Double(temp))
                default:
                    price = 2_560
                }
            default:
                break
            }
        }
        
        //Default
        var inflCoef: Double = 1
        defaulValueCoefficients.forEach { coef in
            if coef.type == .inflationRate {
                inflCoef = coef.value ?? coef.type.defaultValue
            }
        }
        
        //Checkbox
        var flag = false
        var specialPurposeCoef: Double = 1
        var architectCoef: Double = 1
        var importOrNewCoef: Double = 1
        var explosivesZonezCoef: Double = 1
        var highOrLowTempCoef: Double = 1
        var hiddenGasketCoef: Double = 1
        var protectedPremises: Double = 1
        var manualInstallation: Double = 1
        var extinguishingCoef: Double = 1
        checkboxCoefficients.forEach { checkbox in
            if checkbox.isSelected == true {
                switch checkbox.type {
                case .twoStageDocumentationDevelopment:
                    flag.toggle()
                case .thePresenceOfAHiddenGasket:
                    hiddenGasketCoef = 1.2
                case .fireExtinguishingStageForMultipleInstallations:
                    extinguishingCoef = 1.3
                case .availabilityOfProtectedPremisesWithAVolumeOfMoreThanOneThousand:
                    protectedPremises = 1.4
                case .projectedInstallationManualInstallationOfGasPT:
                    manualInstallation = 0.6
                case .objectOfArchitecturalAndHistoricalValue:
                    architectCoef = 1.3
                case .specialPurposeObject:
                    specialPurposeCoef = 1.4
                case .usingImportedOrNewEquipment:
                    importOrNewCoef = 1.3
                case .presenceOfExplosiveZones:
                    explosivesZonezCoef = 1.3
                case .presenceOfHighOrLowTemperatures:
                    highOrLowTempCoef = 1.2
                default:
                    break
                }
            }
        }
        
        price *= (inflCoef * specialPurposeCoef * architectCoef * importOrNewCoef * explosivesZonezCoef * highOrLowTempCoef * hiddenGasketCoef * protectedPremises * manualInstallation * extinguishingCoef)
        
        return makeResult(flag: flag, price: price)
    }
    
    private func calculateSmokeRemovalControlSystem() -> [CalculationResultModel] {
        //Value - м2
        var price: Double = .zero
        valueCoefficients.forEach { value in
            if value.type == .objectArea {
                switch value.value {
                case 0...100:
                    price = 420
                case 100...200:
                    price = 484
                case 200...400:
                    price = 574
                case 400...700:
                    price = 680
                case 700...1_000:
                    price = 806
                case 1_000...2_000:
                    price = 1_613
                case 2_000...3_000:
                    price = 2_097
                case 3_000...5_000:
                    price = 2_580
                case 5_000...7_000:
                    price = 3_065
                case 7_000...10_000:
                    price = 3_548
                case 10_000...13_000:
                    price = 4_032
                case 13_000...17_000:
                    price = 4_435
                case 17_000...21_000:
                    price = 4_775
                case 21_000...25_000:
                    price = 5_079
                case let x where x > 25_000:
                    let temp = Int(x - 25000)
                    price = 5_079 + (0.108 * Double(temp))
                default:
                    price = 540
                }
            }
        }
        
        //Default
        var inflCoef: Double = 1
        defaulValueCoefficients.forEach { coef in
            if coef.type == .inflationRate {
                inflCoef = coef.value ?? coef.type.defaultValue
            }
        }
        
        //Checkbox
        var flag = false
        var specialPurposeCoef: Double = 1
        var architectCoef: Double = 1
        var importOrNewCoef: Double = 1
        var explosivesZonezCoef: Double = 1
        var highOrLowTempCoef: Double = 1
        var hiddenGasketCoef: Double = 1
        var smokeRemovalCoef: Double = 1
        var outdoorCoef: Double = 1
        checkboxCoefficients.forEach { checkbox in
            if checkbox.isSelected == true {
                switch checkbox.type {
                case .twoStageDocumentationDevelopment:
                    flag.toggle()
                case .thePresenceOfAHiddenGasket:
                    hiddenGasketCoef = 1.2
                case .manualTypeOfControlOfSmokeRemovalInstallations:
                    smokeRemovalCoef = 0.7
                case .outdoorEquipmentInstallation:
                    outdoorCoef = 1.1
                case .objectOfArchitecturalAndHistoricalValue:
                    architectCoef = 1.3
                case .specialPurposeObject:
                    specialPurposeCoef = 1.4
                case .usingImportedOrNewEquipment:
                    importOrNewCoef = 1.3
                case .presenceOfExplosiveZones:
                    explosivesZonezCoef = 1.3
                case .presenceOfHighOrLowTemperatures:
                    highOrLowTempCoef = 1.2
                default:
                    break
                }
            }
        }
        
        price *= (inflCoef * specialPurposeCoef * architectCoef * importOrNewCoef * explosivesZonezCoef * highOrLowTempCoef * hiddenGasketCoef * smokeRemovalCoef * outdoorCoef)
        
        return makeResult(flag: flag, price: price)
    }
    
    private func calculatePumpingStationsOfFireExtinguishingInstallations() -> [CalculationResultModel] {
        //Value
        var price: Double = 2_048
        
        //Default
        var inflCoef: Double = 1
        defaulValueCoefficients.forEach { coef in
            if coef.type == .inflationRate {
                inflCoef = coef.value ?? coef.type.defaultValue
            }
        }
        
        //Choice
        var pumpGroupCoef: Double = 1
        choiceCoefficients.forEach{ lines in
            switch lines.type {
            case .numberOfFirePumpGroups:
                switch lines.itemIndex {
                case 0:
                    pumpGroupCoef = 1
                case 1:
                    pumpGroupCoef = 1.1
                case 2:
                    pumpGroupCoef = 1.2
                case 3:
                    pumpGroupCoef = 1.3
                default:
                    pumpGroupCoef = 1
                }
            default:
                break
            }
        }
        
        //Checkbox
        var flag = false
        var specialPurposeCoef: Double = 1
        var architectCoef: Double = 1
        var importOrNewCoef: Double = 1
        var explosivesZonezCoef: Double = 1
        var highOrLowTempCoef: Double = 1
        var motorsWithAVCoef: Double = 1
        var twoPumpCoef: Double = 1
        var enginesCoef: Double = 1
        var pneumaticStationsCoef: Double = 1
        checkboxCoefficients.forEach { checkbox in
            if checkbox.isSelected == true {
                switch checkbox.type {
                case .twoStageDocumentationDevelopment:
                    flag.toggle()
                case .motorsWithAVoltageOfMoreThaFourHundred:
                    motorsWithAVCoef = 1.4
                case .availabilityOfMoreThanTwoPumpsInEachGroup:
                    if pumpGroupCoef > 1 {
                        twoPumpCoef = 1.2
                    }
                case .pumpingInternalCombustionEngines:
                    enginesCoef = 1.1
                case .designOfPneumaticStations:
                    pneumaticStationsCoef = 0.6
                case .objectOfArchitecturalAndHistoricalValue:
                    architectCoef = 1.3
                case .specialPurposeObject:
                    specialPurposeCoef = 1.4
                case .usingImportedOrNewEquipment:
                    importOrNewCoef = 1.3
                case .presenceOfExplosiveZones:
                    explosivesZonezCoef = 1.3
                case .presenceOfHighOrLowTemperatures:
                    highOrLowTempCoef = 1.2
                default:
                    break
                }
            }
        }
        
        price *= (inflCoef * pumpGroupCoef * specialPurposeCoef * architectCoef * importOrNewCoef * explosivesZonezCoef * highOrLowTempCoef * motorsWithAVCoef * twoPumpCoef * enginesCoef * pneumaticStationsCoef)
        
       
        
        return makeResult(flag: flag, price: price)
    }
    
    func makeResult(flag: Bool,
                    price: Double) -> [CalculationResultModel] {
        
        var result: [CalculationResultModel] = []
        if flag {
            
            let stageRPrice: Double = price * 0.25
            result.append(.init(title: .stageP,
                                                          description: "Цена разработки проектной документации:",
                                                          prices: [.init(type: .withoutVat,
                                                                         value: stageRPrice),
                                                                   .init(type: .withVat,
                                                                         value: stageRPrice * 1.2)]))
            let stagePPrice: Double = price * 0.75
            result.append(CalculationResultModel(title: .stageR,
                                                           description: "Цена разработки проектной документации:",
                                                           prices: [.init(type: .withoutVat,
                                                                          value: stagePPrice),
                                                                    .init(type: .withVat,
                                                                          value: stagePPrice * 1.2)]))
            
        } else {
            result.append(.init(title: .stageP,
                                                          description: "Цена разработки проектной документации:",
                                                          prices: [.init(type: .withoutVat,
                                                                         value: price * 0.9),
                                                                   .init(type: .withVat,
                                                                         value: price * 1.20 * 0.9)]))
        }
        
        return result
    }
}
