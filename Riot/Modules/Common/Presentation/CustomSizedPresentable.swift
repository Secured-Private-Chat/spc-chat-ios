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

import Foundation

/// Protocol to be used with a `CustomSizedPresentationController`
@objc protocol CustomSizedPresentable {
    
    /// Custom size for presentable. If not implemented, the presentable will have the both half width and height of the container view.
    /// - Parameter containerSize: Container view's size.
    @objc optional func customSize(withParentContainerSize containerSize: CGSize) -> CGSize
    
    /// Position (origin) of presentable in container. If not implemented, the presentable will be centered to the container view.
    /// - Parameter containerSize: Container view's size.
    @objc optional func position(withParentContainerSize containerSize: CGSize) -> CGPoint
    
}
