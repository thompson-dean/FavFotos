//
//  DefaultImageViewModifier.swift
//  FavFotos
//
//  Created by Dean Thompson on 2023/08/10.
//

import Foundation
import SwiftUI

extension Image {
    func defaultImageModifier() -> some View {
        self
            .resizable()
            .scaledToFill()
    }
}
