// 
// Copyright 2017-2024 New Vector Ltd
//
// SPDX-License-Identifier: AGPL-3.0-only
// Please see LICENSE in the repository root for full details.
//

import Foundation

class SpaceListCoordinatorParameters {
    let userSessionsService: UserSessionsService
    
    init(userSessionsService: UserSessionsService) {
        self.userSessionsService = userSessionsService
    }
}
