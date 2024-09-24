// File created from ScreenTemplate
// $ createScreen.sh .KeyBackup/Recover/PrivateKey KeyBackupRecoverFromPrivateKey
/*
 Copyright 2024 New Vector Ltd
 
 SPDX-License-Identifier: AGPL-3.0-only
 Please see LICENSE in the repository root for full details.
 */

import Foundation

final class KeyBackupRecoverFromPrivateKeyViewModel: KeyBackupRecoverFromPrivateKeyViewModelType {    
    
    // MARK: - Properties
    
    // MARK: Private

    private let keyBackup: MXKeyBackup
    private var currentHTTPOperation: MXHTTPOperation?
    private let keyBackupVersion: MXKeyBackupVersion
    private var progressUpdateTimer: Timer?
    
    // MARK: Public

    weak var viewDelegate: KeyBackupRecoverFromPrivateKeyViewModelViewDelegate?
    weak var coordinatorDelegate: KeyBackupRecoverFromPrivateKeyViewModelCoordinatorDelegate?
    
    // MARK: - Setup
    
    init(keyBackup: MXKeyBackup, keyBackupVersion: MXKeyBackupVersion) {
        self.keyBackup = keyBackup
        self.keyBackupVersion = keyBackupVersion
    }
    
    
    // MARK: - Public
    
    func process(viewAction: KeyBackupRecoverFromPrivateKeyViewAction) {
        switch viewAction {
        case .recover:
            self.recoverWithPrivateKey()
        case .cancel:
            self.coordinatorDelegate?.keyBackupRecoverFromPrivateKeyViewModelDidCancel(self)
        }
    }
    
    // MARK: - Private
    
    private func recoverWithPrivateKey() {

        self.update(viewState: .loading(0))
        
        // Update loading progress every second until no longer loading
        progressUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            if let progress = self?.keyBackup.importProgress {
                self?.update(viewState: .loading(progress.fractionCompleted))
            }
        }
        
        self.currentHTTPOperation = keyBackup.restore(usingPrivateKeyKeyBackup: keyBackupVersion, room: nil, session: nil, success: { [weak self] (_, _) in
            guard let self = self else {
                return
            }
            
            // Trust on decrypt
            self.currentHTTPOperation = self.keyBackup.trust(self.keyBackupVersion, trust: true, success: { [weak self] () in
                guard let self = self else {
                    return
                }
                
                self.update(viewState: .loaded)
                self.coordinatorDelegate?.keyBackupRecoverFromPrivateKeyViewModelDidRecover(self)
                
                }, failure: { [weak self] error in
                    self?.update(viewState: .error(error))
            })
            
            }, failure: { [weak self] error in
                guard let self = self else {
                    return
                }
                
                if (error as NSError).domain == MXKeyBackupErrorDomain
                    && (error as NSError).code == Int(MXKeyBackupErrorInvalidOrMissingLocalPrivateKey.rawValue) {
                    self.coordinatorDelegate?.keyBackupRecoverFromPrivateKeyViewModelDidPrivateKeyFail(self)
                } else {
                    self.update(viewState: .error(error))
                }
        })
    }
    
    private func update(viewState: KeyBackupRecoverFromPrivateKeyViewState) {
        if case .loading = viewState {} else {
            progressUpdateTimer?.invalidate()
            progressUpdateTimer = nil
        }
        
        self.viewDelegate?.keyBackupRecoverFromPrivateKeyViewModel(self, didUpdateViewState: viewState)
    }
}
