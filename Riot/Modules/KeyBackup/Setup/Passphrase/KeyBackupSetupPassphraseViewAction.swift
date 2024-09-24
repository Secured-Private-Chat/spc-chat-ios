/*
 Copyright 2017-2024 New Vector Ltd
 
 SPDX-License-Identifier: AGPL-3.0-only
 Please see LICENSE in the repository root for full details.
 */

import Foundation

/// KeyBackupSetupPassphraseViewController view actions exposed to view model
enum KeyBackupSetupPassphraseViewAction {
    case setupPassphrase
    case setupRecoveryKey
    case skip
    case skipAlertSkip
    case skipAlertContinue
}
