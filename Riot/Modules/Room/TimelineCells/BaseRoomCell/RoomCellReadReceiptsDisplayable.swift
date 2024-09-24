/*
 Copyright 2017-2024 New Vector Ltd
 
 SPDX-License-Identifier: AGPL-3.0-only
 Please see LICENSE in the repository root for full details.
 */

import Foundation

/// `RoomCellReadReceiptsDisplayable` is a protocol indicating that a cell support displaying read receipts.
@objc protocol RoomCellReadReceiptsDisplayable {
    func addReadReceiptsView(_ readReceiptsView: UIView)
    func removeReadReceiptsView()
}
