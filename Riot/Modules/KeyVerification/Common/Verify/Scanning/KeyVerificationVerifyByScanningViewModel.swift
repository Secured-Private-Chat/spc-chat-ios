// File created from ScreenTemplate
// $ createScreen.sh Verify KeyVerificationVerifyByScanning
/*
 Copyright 2024 New Vector Ltd
 
 SPDX-License-Identifier: AGPL-3.0-only
 Please see LICENSE in the repository root for full details.
 */

import Foundation

enum KeyVerificationVerifyByScanningViewModelError: Error {
    case unknown
}

final class KeyVerificationVerifyByScanningViewModel: KeyVerificationVerifyByScanningViewModelType {
    
    // MARK: - Properties
    
    // MARK: Private

    private let session: MXSession
    private let verificationKind: KeyVerificationKind
    private let keyVerificationRequest: MXKeyVerificationRequest
    private let qrCodeDataCoder: MXQRCodeDataCoder
    private let keyVerificationManager: MXKeyVerificationManager
    
    private var qrCodeTransaction: MXQRCodeTransaction?
    private var scannedQRCodeData: MXQRCodeData?
    
    // MARK: Public

    weak var viewDelegate: KeyVerificationVerifyByScanningViewModelViewDelegate?
    weak var coordinatorDelegate: KeyVerificationVerifyByScanningViewModelCoordinatorDelegate?
    
    // MARK: - Setup
    
    init(session: MXSession, verificationKind: KeyVerificationKind, keyVerificationRequest: MXKeyVerificationRequest) {
        self.session = session
        self.verificationKind = verificationKind
        self.keyVerificationManager = self.session.crypto.keyVerificationManager
        self.keyVerificationRequest = keyVerificationRequest
        self.qrCodeDataCoder = MXQRCodeDataCoder()
    }
    
    deinit {
        self.removePendingQRCodeTransaction()
    }
    
    // MARK: - Public
    
    func process(viewAction: KeyVerificationVerifyByScanningViewAction) {
        switch viewAction {
        case .loadData:
            self.loadData()
        case .scannedCode(payloadData: let payloadData):
            self.scannedQRCode(payloadData: payloadData)
        case .cannotScan:
            self.startSASVerification()
        case .cancel:
            self.cancel()
        case .acknowledgeMyUserScannedOtherCode:
            self.acknowledgeScanOtherCode()
        }
    }
    
    // MARK: - Private
    
    private func loadData() {
        
        let qrCodePayloadData: Data?
        let canShowScanAction: Bool
        
        self.qrCodeTransaction = self.keyVerificationManager.qrCodeTransaction(withTransactionId: self.keyVerificationRequest.requestId)
        
        if let supportedVerificationMethods = self.keyVerificationRequest.myMethods {
            
            if let qrCodeData = self.qrCodeTransaction?.qrCodeData {
                qrCodePayloadData = self.qrCodeDataCoder.encode(qrCodeData)
            } else {
                qrCodePayloadData = nil
            }
            
            canShowScanAction = self.canShowScanAction(from: supportedVerificationMethods)
        } else {
            qrCodePayloadData = nil
            canShowScanAction = false
        }
        
        let viewData = KeyVerificationVerifyByScanningViewData(verificationKind: self.verificationKind,
                                                               qrCodeData: qrCodePayloadData,
                                                               showScanAction: canShowScanAction)
        
        self.update(viewState: .loaded(viewData: viewData))
        
        self.registerDidStateChangeNotification()
    }
    
    private func canShowScanAction(from verificationMethods: [String]) -> Bool {
        return verificationMethods.contains(MXKeyVerificationMethodQRCodeScan)
    }
    
    private func cancel() {
        self.cancelQRCodeTransaction()
        self.keyVerificationRequest.cancel(with: MXTransactionCancelCode.user(), success: nil, failure: nil)
        self.unregisterDidStateChangeNotification()
        self.coordinatorDelegate?.keyVerificationVerifyByScanningViewModelDidCancel(self)
    }
    
    private func cancelQRCodeTransaction() {
        guard let transaction = self.qrCodeTransaction  else {
            return
        }
        
        transaction.cancel(with: MXTransactionCancelCode.user())
        self.removePendingQRCodeTransaction()
    }
    
    private func update(viewState: KeyVerificationVerifyByScanningViewState) {
        self.viewDelegate?.keyVerificationVerifyByScanningViewModel(self, didUpdateViewState: viewState)
    }
    
    // MARK: QR code
    
    private func scannedQRCode(payloadData: Data) {
        self.scannedQRCodeData = self.qrCodeDataCoder.decode(payloadData)
        
        let isQRCodeValid = self.scannedQRCodeData != nil
        
        self.update(viewState: .scannedCodeValidated(isValid: isQRCodeValid))
    }
    
    private func acknowledgeScanOtherCode() {
        guard let scannedQRCodeData = self.scannedQRCodeData else {
            return
        }
        
        guard let qrCodeTransaction = self.qrCodeTransaction else {
            return
        }
        
        self.unregisterDidStateChangeNotification()
        self.coordinatorDelegate?.keyVerificationVerifyByScanningViewModel(self, didScanOtherQRCodeData: scannedQRCodeData, withTransaction: qrCodeTransaction)
    }    
    
    private func removePendingQRCodeTransaction() {
        guard let qrCodeTransaction = self.qrCodeTransaction else {
            return
        }
        self.keyVerificationManager.removeQRCodeTransaction(withTransactionId: qrCodeTransaction.transactionId)
    }
    
    // MARK: SAS
    
    private func startSASVerification() {
        
        self.update(viewState: .loading)
        
        self.session.crypto.keyVerificationManager.beginKeyVerification(from: self.keyVerificationRequest, method: MXKeyVerificationMethodSAS, success: { [weak self] (keyVerificationTransaction) in
                guard let self = self else {
                    return
                }
            
                // Remove pending QR code transaction, as we are going to use SAS verification
                self.removePendingQRCodeTransaction()

                // Check due to legacy implementation of key verification which could pass incorrect type of transaction
                if keyVerificationTransaction is MXIncomingSASTransaction {
                    MXLog.debug("[KeyVerificationVerifyByScanningViewModel] SAS transaction should be outgoing")
                    self.unregisterDidStateChangeNotification()
                    self.update(viewState: .error(KeyVerificationVerifyByScanningViewModelError.unknown))
                }
            
            }, failure: { [weak self] (error) in
                guard let self = self else {
                    return
                }
                self.update(viewState: .error(error))
            }
        )
    }
    
    // MARK: - MXKeyVerificationTransactionDidChange
    
    private func registerDidStateChangeNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(requestDidStateChange(notification:)), name: .MXKeyVerificationRequestDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(transactionDidStateChange(notification:)), name: .MXKeyVerificationTransactionDidChange, object: nil)
    }
    
    private func unregisterDidStateChangeNotification() {
        NotificationCenter.default.removeObserver(self, name: .MXKeyVerificationRequestDidChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: .MXKeyVerificationTransactionDidChange, object: nil)
    }
    
    @objc private func requestDidStateChange(notification: Notification) {
        guard let request = notification.object as? MXKeyVerificationRequest else {
            return
        }
        
        if request.state == MXKeyVerificationRequestStateCancelled, let reason = request.reasonCancelCode {
            self.unregisterDidStateChangeNotification()
            self.update(viewState: .cancelled(cancelCode: reason, verificationKind: verificationKind))
        }
    }
    
    @objc private func transactionDidStateChange(notification: Notification) {
        guard let transaction = notification.object as? MXKeyVerificationTransaction else {
            return
        }
        
        guard self.keyVerificationRequest.requestId == transaction.transactionId else {
            MXLog.debug("[KeyVerificationVerifyByScanningViewModel] transactionDidStateChange: Not for our transaction (\(self.keyVerificationRequest.requestId)): \(transaction.transactionId)")
            return
        }
        
        if let sasTransaction = transaction as? MXSASTransaction {
            self.sasTransactionDidStateChange(sasTransaction)
        } else if let qrCodeTransaction = transaction as? MXQRCodeTransaction {
            self.qrCodeTransactionDidStateChange(qrCodeTransaction)
        }
    }
    
    private func sasTransactionDidStateChange(_ transaction: MXSASTransaction) {
        switch transaction.state {
        case MXSASTransactionStateShowSAS:
            self.unregisterDidStateChangeNotification()
            self.coordinatorDelegate?.keyVerificationVerifyByScanningViewModel(self, didStartSASVerificationWithTransaction: transaction)
        case MXSASTransactionStateCancelled:
            guard let reason = transaction.reasonCancelCode else {
                return
            }
            self.unregisterDidStateChangeNotification()
            self.update(viewState: .cancelled(cancelCode: reason, verificationKind: verificationKind))
        case MXSASTransactionStateCancelledByMe:
            guard let reason = transaction.reasonCancelCode else {
                return
            }
            self.unregisterDidStateChangeNotification()
            self.update(viewState: .cancelledByMe(reason))
        default:
            break
        }
    }
    
    private func qrCodeTransactionDidStateChange(_ transaction: MXQRCodeTransaction) {
        switch transaction.state {
        case .verified:
            // Should not happen
            self.unregisterDidStateChangeNotification()
            self.coordinatorDelegate?.keyVerificationVerifyByScanningViewModelDidCancel(self)
        case .qrScannedByOther:
            self.unregisterDidStateChangeNotification()
            self.coordinatorDelegate?.keyVerificationVerifyByScanningViewModel(self, qrCodeDidScannedByOtherWithTransaction: transaction)
        case .cancelled:
            guard let reason = transaction.reasonCancelCode else {
                return
            }
            self.unregisterDidStateChangeNotification()
            self.update(viewState: .cancelled(cancelCode: reason, verificationKind: verificationKind))
        case .cancelledByMe:
            guard let reason = transaction.reasonCancelCode else {
                return
            }
            self.unregisterDidStateChangeNotification()
            self.update(viewState: .cancelledByMe(reason))
        default:
            break
        }
    }
}
