// File created from FlowTemplate
// $ createRootCoordinator.sh SetPinCode SetPin EnterPinCode
/*
 Copyright 2017-2024 New Vector Ltd
 
 SPDX-License-Identifier: AGPL-3.0-only
 Please see LICENSE in the repository root for full details.
 */

import UIKit

@objcMembers
final class SetPinCoordinator: SetPinCoordinatorType {
    
    // MARK: - Properties
    
    // MARK: Private
    
    private let navigationRouter: NavigationRouterType
    private let session: MXSession?
    var viewMode: SetPinCoordinatorViewMode {
        didSet {
            updateRootCoordinator()
        }
    }
    private let pinCodePreferences: PinCodePreferences
    
    // MARK: Public

    // Must be used only internally
    var childCoordinators: [Coordinator] = []
    
    weak var delegate: SetPinCoordinatorDelegate?
    
    // MARK: - Setup
    
    init(session: MXSession?, viewMode: SetPinCoordinatorViewMode, pinCodePreferences: PinCodePreferences) {
        self.navigationRouter = NavigationRouter(navigationController: RiotNavigationController())
        self.session = session
        self.viewMode = viewMode
        self.pinCodePreferences = pinCodePreferences
    }
    
    private func getRootCoordinator() -> Coordinator & Presentable {
        switch viewMode {
        case .unlock:
            if pinCodePreferences.isBiometricsSet {
                return createSetupBiometricsCoordinator()
            } else {
                return createEnterPinCodeCoordinator()
            }
        case .setPin, .setPinAfterLogin, .setPinAfterRegister, .notAllowedPin, .confirmPinToDeactivate:
            return createEnterPinCodeCoordinator()
        case .setupBiometricsAfterLogin, .setupBiometricsFromSettings, .confirmBiometricsToDeactivate:
            return createSetupBiometricsCoordinator()
        case .inactive:
            return createEnterPinCodeCoordinator()
        case .changePin:
            return createEnterPinCodeCoordinator()
        }
    }
    
    // MARK: - Public methods
    
    func start() {
        updateRootCoordinator()
    }
    
    func toPresentable() -> UIViewController {
        let controller = self.navigationRouter.toPresentable()
        if #available(iOS 13.0, *) {
            controller.modalPresentationStyle = .fullScreen
        }
        return controller
    }
    
    // MARK: - Private methods
    
    private func updateRootCoordinator() {
        let rootCoordinator = getRootCoordinator()
        
        setRootCoordinator(rootCoordinator)
    }
    
    private func setRootCoordinator(_ coordinator: Coordinator & Presentable) {
        coordinator.start()

        self.add(childCoordinator: coordinator)

        self.navigationRouter.setRootModule(coordinator)
    }

    private func createEnterPinCodeCoordinator() -> EnterPinCodeCoordinator {
        let coordinator = EnterPinCodeCoordinator(session: self.session, viewMode: self.viewMode)
        coordinator.delegate = self
        return coordinator
    }
    
    private func createSetupBiometricsCoordinator() -> SetupBiometricsCoordinator {
        let coordinator = SetupBiometricsCoordinator(session: self.session, viewMode: self.viewMode)
        coordinator.delegate = self
        return coordinator
    }
    
    private func storePin(_ pin: String) {
        pinCodePreferences.pin = pin
    }
    
    private func removePin() {
        pinCodePreferences.pin = nil
    }
    
    private func setupBiometrics() {
        pinCodePreferences.biometricsEnabled = true
    }
    
    private func removeBiometrics() {
        pinCodePreferences.biometricsEnabled = nil
    }
}

// MARK: - EnterPinCodeCoordinatorDelegate
extension SetPinCoordinator: EnterPinCodeCoordinatorDelegate {
    
    func enterPinCodeCoordinatorDidComplete(_ coordinator: EnterPinCodeCoordinatorType) {
        if viewMode == .confirmPinToDeactivate {
            removePin()
        }
        self.delegate?.setPinCoordinatorDidComplete(self)
    }
    
    func enterPinCodeCoordinatorDidCompleteWithReset(_ coordinator: EnterPinCodeCoordinatorType, dueToTooManyErrors: Bool) {
        self.delegate?.setPinCoordinatorDidCompleteWithReset(self, dueToTooManyErrors: dueToTooManyErrors)
        pinCodePreferences.reset()
    }
    
    func enterPinCodeCoordinator(_ coordinator: EnterPinCodeCoordinatorType, didCompleteWithPin pin: String) {
        storePin(pin)
        if pinCodePreferences.forcePinProtection && pinCodePreferences.isBiometricsAvailable && !pinCodePreferences.isBiometricsSet {
            viewMode = .setupBiometricsAfterLogin
            setRootCoordinator(createSetupBiometricsCoordinator())
        } else {
            self.delegate?.setPinCoordinatorDidComplete(self)
        }
    }
    
    func enterPinCodeCoordinatorDidCancel(_ coordinator: EnterPinCodeCoordinatorType) {
        self.delegate?.setPinCoordinatorDidCancel(self)
    }
}

extension SetPinCoordinator: SetupBiometricsCoordinatorDelegate {
    
    func setupBiometricsCoordinatorDidComplete(_ coordinator: SetupBiometricsCoordinatorType) {
        switch viewMode {
        case .setupBiometricsAfterLogin, .setupBiometricsFromSettings:
            setupBiometrics()
        case .confirmBiometricsToDeactivate:
            removeBiometrics()
        default:
            break
        }
        self.delegate?.setPinCoordinatorDidComplete(self)
    }
    
    func setupBiometricsCoordinatorDidCompleteWithReset(_ coordinator: SetupBiometricsCoordinatorType, dueToTooManyErrors: Bool) {
        if viewMode == .unlock && pinCodePreferences.isPinSet {
            //  and user also has set a pin, so fallback to it
            setRootCoordinator(createEnterPinCodeCoordinator())
        } else {
            //  cascade rest
            self.delegate?.setPinCoordinatorDidCompleteWithReset(self, dueToTooManyErrors: dueToTooManyErrors)
        }
    }
    
    func setupBiometricsCoordinatorDidCancel(_ coordinator: SetupBiometricsCoordinatorType) {
        switch viewMode {
        case .unlock:
            //  if trying to unlock
            if pinCodePreferences.isPinSet {
                //  and user also has set a pin, so fallback to it
                setRootCoordinator(createEnterPinCodeCoordinator())
            } else {
                //  no pin set, cascade cancellation
                self.delegate?.setPinCoordinatorDidCancel(self)
            }
        case .setupBiometricsAfterLogin:
            self.delegate?.setPinCoordinatorDidComplete(self)
        default:
            self.delegate?.setPinCoordinatorDidCancel(self)
        }
    }
    
}
