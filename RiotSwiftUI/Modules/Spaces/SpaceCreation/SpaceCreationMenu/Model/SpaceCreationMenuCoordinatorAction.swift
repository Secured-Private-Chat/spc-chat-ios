// File created from TemplateAdvancedRoomsExample
// $ createSwiftUITwoScreen.sh Spaces/SpaceCreation SpaceCreation SpaceCreationMenu SpaceCreationSettings
//
// Copyright 2017-2024 New Vector Ltd
//
// SPDX-License-Identifier: AGPL-3.0-only
// Please see LICENSE in the repository root for full details.
//

import Foundation

/// Actions returned by the coordinator callback
enum SpaceCreationMenuCoordinatorAction {
    case didSelectOption(_ optionId: SpaceCreationMenuRoomOptionId)
    case cancel
    case back
}
