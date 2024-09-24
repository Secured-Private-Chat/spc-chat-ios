//
// Copyright 2024 New Vector Ltd
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import SwiftUI

struct TemplateRoomChatCoordinatorParameters {
    let room: MXRoom
}

final class TemplateRoomChatCoordinator: Coordinator, Presentable {
    private let parameters: TemplateRoomChatCoordinatorParameters
    private let templateRoomChatHostingController: UIViewController
    private var templateRoomChatViewModel: TemplateRoomChatViewModelProtocol

    // Must be used only internally
    var childCoordinators: [Coordinator] = []
    var callback: (() -> Void)?
    
    init(parameters: TemplateRoomChatCoordinatorParameters) {
        self.parameters = parameters
        let viewModel = TemplateRoomChatViewModel(templateRoomChatService: TemplateRoomChatService(room: parameters.room))
        let view = TemplateRoomChat(viewModel: viewModel.context)
            .environmentObject(AvatarViewModel(avatarService: AvatarService(mediaManager: parameters.room.mxSession.mediaManager)))

        templateRoomChatViewModel = viewModel
        templateRoomChatHostingController = VectorHostingController(rootView: view)
    }
    
    // MARK: - Public

    func start() {
        MXLog.debug("[TemplateRoomChatCoordinator] did start.")
        templateRoomChatViewModel.callback = { [weak self] result in
            guard let self = self else { return }
            MXLog.debug("[TemplateRoomChatCoordinator] TemplateRoomChatViewModel did complete with result: \(result).")
            switch result {
            case .done:
                self.callback?()
            }
        }
    }
    
    func toPresentable() -> UIViewController {
        templateRoomChatHostingController
    }
}
