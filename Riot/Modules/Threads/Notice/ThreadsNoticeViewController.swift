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

class ThreadsNoticeViewController: UIViewController {

    // MARK: Outlets

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var separatorLineView: UIView!
    @IBOutlet private weak var informationLabel: UILabel!
    @IBOutlet private weak var doneButton: UIButton!

    // MARK: Private

    private var theme: Theme!

    // MARK: Public

    @objc var didTapDoneButton: (() -> Void)?

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupViews()

        self.registerThemeServiceDidChangeThemeNotification()
        self.update(theme: self.theme)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Hide back button
        self.navigationItem.setHidesBackButton(true, animated: animated)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.theme.statusBarStyle
    }

    // MARK: - Setup

    @objc class func instantiate() -> ThreadsNoticeViewController {
        let viewController = StoryboardScene.ThreadsNoticeViewController.initialScene.instantiate()
        viewController.theme = ThemeService.shared().theme
        return viewController
    }

    // MARK: - Private

    private func registerThemeServiceDidChangeThemeNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(themeDidChange),
                                               name: .themeServiceDidChangeTheme,
                                               object: nil)
    }

    @objc private func themeDidChange() {
        self.update(theme: ThemeService.shared().theme)
    }

    private func setupViews() {
        self.vc_removeBackTitle()

        self.titleLabel.text = VectorL10n.threadsNoticeTitle
        self.informationLabel.setHTMLFromString(VectorL10n.threadsNoticeInformation)
        self.doneButton.setTitle(VectorL10n.threadsNoticeDone, for: .normal)
    }

    // MARK: - Actions

    @IBAction private func doneButtonAction(_ sender: UIButton) {
        self.didTapDoneButton?()
    }

}

// MARK: - Themable

extension ThreadsNoticeViewController: Themable {

    func update(theme: Theme) {
        self.theme = theme

        self.view.backgroundColor = theme.colors.background

        if let navigationBar = self.navigationController?.navigationBar {
            theme.applyStyle(onNavigationBar: navigationBar)
        }

        self.titleLabel.textColor = theme.textPrimaryColor
        self.separatorLineView.backgroundColor = theme.colors.system
        self.informationLabel.textColor = theme.textPrimaryColor

        self.doneButton.vc_setBackgroundColor(theme.tintColor, for: .normal)
        self.doneButton.setTitleColor(theme.baseTextPrimaryColor, for: .normal)
    }

}

// MARK: - SlidingModalPresentable

extension ThreadsNoticeViewController: SlidingModalPresentable {

    func allowsDismissOnBackgroundTap() -> Bool {
        return false
    }

    func layoutHeightFittingWidth(_ width: CGFloat) -> CGFloat {
        guard let view = ThreadsNoticeViewController.instantiate().view else {
            return 0
        }

        view.widthAnchor.constraint(equalToConstant: width).isActive = true
        view.setNeedsLayout()
        view.layoutIfNeeded()

        let fittingSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)

        return view.systemLayoutSizeFitting(fittingSize).height
            + UIWindow().safeAreaInsets.top
            + UIWindow().safeAreaInsets.bottom
    }

}
