//
//  SwiftUIView15.swift
//  MapViewSwiftUI
//
//  Created by Admin on 24/08/2021.
//

import MapKit
import SwiftUI

 struct Locations: Decodable, Identifiable {
    let _id: Int
    let streetaddress: String?
    let suburb: String?
    let state: String?
    let postcode: String?

    var id: Int { _id }
    var coordinate: CLLocationCoordinate2D? = nil

    private enum CodingKeys: CodingKey {
        case _id, streetaddress, suburb, state, postcode
    }
 }

 @available(iOS 15.0, *)
 final class ModelData: ObservableObject {
    @Published var locations: [Locations] = []

    @MainActor
    func fetchLocationsWithCoordinates() async {
        let locations = await getLocationData()
        return await withTaskGroup(of: Locations.self) { group in
            for location in locations {
                group.async {
                    await self.updateCoordinate(of: location)
                }
            }
            for await location in group {
                self.locations.append(location)
            }
        }
    }

    private func updateCoordinate(of location: Locations) async -> Locations {
        var newLoc = location
        newLoc.coordinate = try? await CLGeocoder().geocodeAddressString(
            "\(location.streetaddress ?? "") \(location.suburb ?? ""), \(location.state ?? "") \(location.postcode ?? "")"
        ).first?.location?.coordinate
        //await Task.sleep(1_000_000_000)
        return newLoc
    }

    private func getLocationData() async -> [Locations] {
        //await Task.sleep(4_000_000_000)
        return [.init(_id: 1, streetaddress: "11 rue Vineuse", suburb: "", state: "France", postcode: "75016"), .init(_id: 2, streetaddress: "11 rue Chardin", suburb: "", state: "France", postcode: "75016"), .init(_id: 3, streetaddress: "11 avenue Kléber", suburb: "", state: "France", postcode: "75016")]
    }
 }

 @available(iOS 15.0, *)
 struct MapView15: View {
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 48.862725, longitude: 2.287592), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    @StateObject var modelData = ModelData() // loads the api data
    var body: some View {
        Map(
            coordinateRegion: $region,
            interactionModes: .all,
            showsUserLocation: true,
            annotationItems: modelData.locations,
            annotationContent: { pin in
                MapPin(coordinate: pin.coordinate ?? CLLocationCoordinate2D())
            }
        )
        .task {
            await modelData.fetchLocationsWithCoordinates()
        }
    }
 }


struct SwiftUIView15_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 15.0, *) {
            MapView15()
               
        } else {
            Text("ios14")
            // Fallback on earlier versions
        }
    }
}
