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
        MKMapView.appearance().mapType = .satellite
    }
    
    var body: some View {
        Map(coordinateRegion: $coordinateRegion,
            annotationItems: viewModel.store) { place in
            //ImageAnnotation(isBig: placeSelected?.id == place.id ? true : false, image: place, imageSelected: $placeSelected).annotation
            MapAnnotation(coordinate: place.coordinate) {

                    if place.image != nil {
                            place.image!
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 160)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.blue, lineWidth: 0.2)
                                        )
                                .scaleEffect(placeSelected?.id == place.id ? 1 : 0.4)
                                .onTapGesture {
                                    if placeSelected?.id  == place.id {
                                        placeSelected = nil
                                    } else {
                                        placeSelected = place
                                    }
                                }
                                
                                .animation(.linear, value: placeSelected?.id)
                    } else {
                        Image(systemName: "drop.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .onAppear {
                                print("apparait")
                                viewModel.fetchImage(for: place.id)
                            }
                    }
                
                


            }

        }
        
//        .sheet(item: $placeSelected) {place in
//            VStack {
//                if let image = place.image {
//                    image
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 250)
//                }
//                Text(place.name)
//            }
//        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct ImageAnnotation {
    var isBig: Bool
    var image: VeganFoodPlace
    @Binding var imageSelected: VeganFoodPlace?
    var annotation: some MapAnnotationProtocol {
        MapAnnotation(coordinate: image.coordinate) {
//            HStack {
//                if !isBig {
//                Image(systemName: "drop.fill")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 100)
//                    .onTapGesture {
//                        imageSelected = image
//                    }
//                } else {
//                    Image(systemName: "drop.fill")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 100)
//                        .onTapGesture {
//                            imageSelected = image
//                        }
//                }
//            }
            Image(systemName: "drop.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100)
                .onTapGesture {
                    imageSelected = image
                }
            .scaleEffect(isBig ? 1 : 0.2)
            .animation(.linear, value: isBig)
            
        }
    }
}

struct TestMap_Previews: PreviewProvider {
    static var previews: some View {
        TestMap(viewModel: ViewModel())
    }
}
