// 
// Copyright 2017-2024 New Vector Ltd
//
// SPDX-License-Identifier: AGPL-3.0-only
// Please see LICENSE in the repository root for full details.
//

import Foundation

class PollPlainCell: SizableBaseRoomCell, RoomCellReactionsDisplayable, RoomCellReadMarkerDisplayable {

    private var event: MXEvent?
    
    override func render(_ cellData: MXKCellData!) {
        super.render(cellData)
        
        guard
            let contentView = roomCellContentView?.innerContentView,
            let bubbleData = cellData as? RoomBubbleCellData,
            let event = bubbleData.events.last,
            event.isTimelinePollEvent,
            let controller = TimelinePollProvider.shared.buildTimelinePollVCForEvent(event)
        else {
            return
        }
        
        self.event = event
        self.addContentViewController(controller, on: contentView)
    }
    
    override func setupViews() {
        super.setupViews()
        
        roomCellContentView?.backgroundColor = .clear
        roomCellContentView?.showSenderInfo = true
        roomCellContentView?.showPaginationTitle = false
    }
    
    // The normal flow for tapping on cell content views doesn't work for bubbles without attributed strings
    override func onContentViewTap(_ sender: UITapGestureRecognizer) {
        guard let event = self.event else {
            return
        }
        
        delegate.cell(self, didRecognizeAction: kMXKRoomBubbleCellTapOnContentView, userInfo: [kMXKRoomBubbleCellEventKey: event])
    }
}

extension PollPlainCell: RoomCellThreadSummaryDisplayable {}
