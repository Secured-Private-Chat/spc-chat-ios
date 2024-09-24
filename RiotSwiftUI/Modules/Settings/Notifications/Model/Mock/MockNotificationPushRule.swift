//
// Copyright 2017-2024 New Vector Ltd
//
// SPDX-License-Identifier: AGPL-3.0-only
// Please see LICENSE in the repository root for full details.
//

import Foundation

struct MockNotificationPushRule: NotificationPushRuleType, Equatable {
    var ruleId: String!
    var enabled: Bool
    var ruleActions: NotificationActions? = NotificationStandardActions.notifyDefaultSound.actions
    
    func matches(standardActions: NotificationStandardActions?) -> Bool {
        standardActions?.actions == ruleActions
    }
}
