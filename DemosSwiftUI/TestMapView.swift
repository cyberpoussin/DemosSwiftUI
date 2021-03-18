//
//  TestMap.swift
//  NewFlowerApp
//
//  Created by Admin on 05/02/2021.
//

import MapKit
import SwiftUI
import Combine


struct TestMap: View {
    @ObservedObject var viewModel: ViewModel
    @State var coordinateRegion: MKCoordinateRegion
    @State private var placeSelected: VeganFoodPlace? = nil
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        self._coordinateRegion = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: viewModel.initialLatitude, longitude: viewModel.initialLongitude),
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)))
    }
    
    var body: some View {
        Map(coordinateRegion: $coordinateRegion,
            annotationItems: viewModel.store) { place in
            
            MapAnnotation(coordinate: place.coordinate) {
                Button {
                    if placeSelected?.id == place.id {
                        placeSelected = nil
                    } else {
                        placeSelected = place
                    }
                } label: {
                    if place.image != nil {
                        place.image!
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 60)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.blue, lineWidth: 0.2)
                            )
                    }
                    else {
                        Image(systemName: "drop.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .onAppear {
                                print("apparait")
                                viewModel.fetchImage(for: place.id)
                            }
                    } 
                }
                .foregroundColor(.red)
            }
        }
        
        .sheet(item: $placeSelected) {place in
            VStack {
                if let image = place.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 250)
                }
                Text(place.name)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct TestMap_Previews: PreviewProvider {
    static var previews: some View {
        TestMap(viewModel: ViewModel())
    }
}
