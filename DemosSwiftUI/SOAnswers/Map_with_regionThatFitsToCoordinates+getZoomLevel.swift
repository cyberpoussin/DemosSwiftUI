//
//  SwiftUIView2.swift
//  DemosSwiftUI
//
//  Created by Admin on 16/08/2021.
//

import MapKit
import SwiftUI

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

extension MKCoordinateSpan: Equatable {
    public static func == (lhs: MKCoordinateSpan, rhs: MKCoordinateSpan) -> Bool {
        lhs.latitudeDelta == rhs.latitudeDelta && lhs.longitudeDelta == rhs.longitudeDelta
    }
}

extension MKCoordinateRegion: Equatable {
    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        lhs.center == rhs.center && lhs.span == rhs.span
    }
}

struct MapItem: Identifiable, Equatable {
    let id = UUID()
    let coordinate = CLLocationCoordinate2D(latitude: Double.random(in: 40 ... 44), longitude: Double.random(in: 2 ... 5))
}

struct MapThatFits: View {
    @State private var region = MKCoordinateRegion(center: .init(latitude: 44, longitude: 1.2), span: .init(latitudeDelta: 10, longitudeDelta: 10))
    @State private var drag: Int = 0
    @State private var pinch: Int = 0
    @State private var oldZoomLevel: Double?
    @State private var searchResults = [MapItem()]
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
            // GeometryReader { proxy in
            Map(coordinateRegion: $region, annotationItems: searchResults) { result in
                MapMarker(coordinate: result.coordinate)
            }
            .onChange(of: searchResults) { _ in
                if !searchResults.isEmpty {
                    region = regionThatFitsTo(coordinates: searchResults.map { $0.coordinate })
                }
            }

            .onAppear {
                searchResults = [MapItem(), MapItem(), MapItem(), MapItem()]
            }
            .onChange(of: region) { newRegion in
                let zlevel = getZoomLevel(mapWidth: UIScreen.main.bounds.width)
                if zlevel != oldZoomLevel {
                    pinch += 1
                } else {
                    drag += 1
                }
                oldZoomLevel = zlevel
            }

            HStack {
                Text(drag.description)
                    .padding()
                    .background(Color.pink)
                Spacer()
                Text(pinch.description)
                    .padding()
                    .background(Color.yellow)
                Spacer()
                Text((oldZoomLevel ?? 0).description)
                    .padding()
                    .background(Color.purple)
                
            }
        }
    }

    func regionThatFitsTo(coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        var topLeftCoord = CLLocationCoordinate2D(latitude: -90, longitude: 180)
        var bottomRightCoord = CLLocationCoordinate2D(latitude: 90, longitude: -180)
        for coordinate in coordinates {
            topLeftCoord.longitude = fmin(topLeftCoord.longitude, coordinate.longitude)
            topLeftCoord.latitude = fmax(topLeftCoord.latitude, coordinate.latitude)
            bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, coordinate.longitude)
            bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, coordinate.latitude)
        }

        var region: MKCoordinateRegion = MKCoordinateRegion()
        region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5
        region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5
        region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.4
        region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.4
        return region
    }

    func getZoomLevel(mapWidth: Double) -> Double {
        let MERCATOR_RADIUS = 85445659.44705395
        let level = 20.00 - log2(region.span.longitudeDelta * MERCATOR_RADIUS * Double.pi / (180.0 * mapWidth))
        return round(level * 100000) / 100000
    }
}

struct SwiftUIView2_Previews: PreviewProvider {
    static var previews: some View {
        MapThatFits()
    }
}
