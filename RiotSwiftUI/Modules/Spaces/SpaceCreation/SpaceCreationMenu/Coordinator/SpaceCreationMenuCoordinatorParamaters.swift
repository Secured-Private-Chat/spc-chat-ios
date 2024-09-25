// File created from TemplateAdvancedRoomsExample
// $ createSwiftUITwoScreen.sh Spaces/SpaceCreation SpaceCreation SpaceCreationMenu SpaceCreationSettings
//
// Copyright 2021-2024 New Vector Ltd.
//
// SPDX-License-Identifier: AGPL-3.0-only
// Please see LICENSE in the repository root for full details.
//

import Foundation

struct SpaceCreationMenuCoordinatorParameters {
    let session: MXSession
    let creationParams: SpaceCreationParameters
    let navTitle: String?
    let showBackButton: Bool
    let title: String
    let detail: String
    let options: [SpaceCreationMenuRoomOption]
}
