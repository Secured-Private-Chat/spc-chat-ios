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

import UIKit

class TextMessageIncomingBubbleCell: TextMessageBaseBubbleCell, BubbleIncomingRoomCellProtocol {
    
    // MARK: - Overrides
    
    override func setupViews() {
        super.setupViews()
        
        roomCellContentView?.showSenderInfo = true

        self.setupBubbleConstraints()
        self.setupBubbleDecorations()
    }
    
    override func update(theme: Theme) {
        super.update(theme: theme)
        
        self.textMessageContentView?.bubbleBackgroundView?.backgroundColor = theme.roomCellIncomingBubbleBackgroundColor
    }
    
    // MARK: - Private
    
    private func setupBubbleConstraints() {
        
        self.roomCellContentView?.innerContentViewLeadingConstraint.constant = BubbleRoomCellLayoutConstants.incomingBubbleBackgroundMargins.left
        
        self.roomCellContentView?.innerContentViewTrailingConstraint.constant = BubbleRoomCellLayoutConstants.incomingBubbleBackgroundMargins.right
    }
}
