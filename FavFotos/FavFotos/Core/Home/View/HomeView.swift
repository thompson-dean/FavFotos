//
//  HomeView.swift
//  FavFotos
//
//  Created by Dean Thompson on 2023/08/05.
//

import SwiftUI

struct HomeView: View {
    @StateObject var vm = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                CompositionalLayoutView(items: vm.photos, id: \.self, spacing: 8) { item in
                    GeometryReader { geo in
                        let size = geo.size
                        AsyncImage(url: URL(string: item.src.large)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: size.width, height: size.height)
                                .cornerRadius(4)
                        } placeholder: {
                            VStack(alignment: .center) {
                                ProgressView()
                            }
                            .frame(width: size.width, height: size.height)
                        }
                    }
                    .onTapGesture {
                        print(item.photographer)
                    }
                }
            }
            .padding(8)
            .navigationTitle("FavFotos")
        }
        .searchable(text: $vm.searchTerm)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
