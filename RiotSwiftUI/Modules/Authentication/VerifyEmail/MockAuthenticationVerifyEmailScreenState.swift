// 
// Copyright 2021 New Vector Ltd
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

import Foundation
import SwiftUI

/// Using an enum for the screen allows you define the different state cases with
/// the relevant associated data for each case.
@available(iOS 14.0, *)
enum MockAuthenticationVerifyEmailScreenState: MockScreenState, CaseIterable {
    // A case for each state you want to represent
    // with specific, minimal associated data that will allow you
    // mock that screen.
    case emptyAddress
    case enteredAddress
    case hasSentEmail
    
    /// The associated screen
    var screenType: Any.Type {
        AuthenticationVerifyEmailScreen.self
    }
    
    /// Generate the view struct for the screen state.
    var screenView: ([Any], AnyView)  {
        let viewModel: AuthenticationVerifyEmailViewModel
        switch self {
        case .emptyAddress:
            viewModel = AuthenticationVerifyEmailViewModel(emailAddress: "")
        case .enteredAddress:
            viewModel = AuthenticationVerifyEmailViewModel(emailAddress: "test@example.com")
        case .hasSentEmail:
            viewModel = AuthenticationVerifyEmailViewModel(emailAddress: "test@example.com")
            Task { await viewModel.updateForSentEmail() }
        }
        
        // can simulate service and viewModel actions here if needs be.
        
        return (
            [viewModel], AnyView(AuthenticationVerifyEmailScreen(viewModel: viewModel.context))
        )
    }
}