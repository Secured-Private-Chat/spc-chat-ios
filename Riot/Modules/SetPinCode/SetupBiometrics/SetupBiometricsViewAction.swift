// File created from ScreenTemplate
// $ createScreen.sh SetPinCode/SetupBiometrics SetupBiometrics
/*
 Copyright 2024 New Vector Ltd
 
 SPDX-License-Identifier: AGPL-3.0-only
 Please see LICENSE in the repository root for full details.
 */

import Foundation

/// SetupBiometricsViewController view actions exposed to view model
enum SetupBiometricsViewAction {
    case loadData
    case enableDisableTapped
    case skipOrCancel
    case unlock
    case cantUnlockedAlertResetAction
}
