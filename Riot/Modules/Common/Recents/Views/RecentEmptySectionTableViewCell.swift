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
import Reusable

/// `RecentEmptySectionTableViewCell` can be used as a placeholder for empty sections.
class RecentEmptySectionTableViewCell: UITableViewCell, NibReusable, Themable {
    
    @IBOutlet private var iconBackgroundView: UIView!
    @IBOutlet var iconView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var messageLabel: UILabel!
    
    @objc static func defaultReuseIdentifier() -> String {
        return reuseIdentifier
    }
    
    // MARK: - Life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.iconBackgroundView.layer.cornerRadius = self.iconBackgroundView.bounds.height / 2
        self.iconBackgroundView.layer.masksToBounds = true
        
        self.selectionStyle = .none
        
        update(theme: ThemeService.shared().theme)
    }

    // MARK: - Themable
    
    func update(theme: Theme) {
        self.backgroundColor = theme.colors.background
        
        self.iconBackgroundView.backgroundColor = theme.colors.quinaryContent
        self.iconView.tintColor = theme.colors.secondaryContent
        
        self.titleLabel.textColor = theme.colors.primaryContent
        self.titleLabel.font = theme.fonts.title3SB
        
        self.messageLabel.textColor = theme.colors.secondaryContent
        self.messageLabel.font = theme.fonts.callout
    }
}
