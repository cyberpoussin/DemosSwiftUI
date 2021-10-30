//
//  SelectingAnnotationInMap.swift
//  SelectingAnnotationInMap
//
//  Created by Admin on 31/08/2021.
//

import SwiftUI
import MapKit

private struct SelectedCourseKey: EnvironmentKey {
    static let defaultValue: Binding<Course?> = .constant(nil)
}

extension EnvironmentValues {
    var selectedCourse: Binding<Course?> {
        get { self[SelectedCourseKey.self] }
        set { self[SelectedCourseKey.self] = newValue }
    }
}

struct Course: Identifiable {
    let id = UUID()
    var location: CLLocationCoordinate2D
}
struct LocationInfoView: View {
    @Environment(\.selectedCourse) var selectedCourse: Binding<Course?>
    var viewModel: LocationInfoViewModel
    var body: some View {
        VStack {
            Button("close") {
                selectedCourse.wrappedValue = nil
            }
            Text(viewModel.course.id.description)
        }
    }
}

class LocationInfoViewModel: ObservableObject {
    var course: Course
    init(course: Course) {
        self.course = course
    }
}
class CourseSearchViewModel: ObservableObject {
    var courses: [Course] = [.init(location: CLLocationCoordinate2D(latitude: 60.480960,
                                                                       longitude: 22.239808)), .init(location:  CLLocationCoordinate2D(latitude: 62,
                                                                                                                                         longitude: 25))]
    var location: CLLocationCoordinate2D? = CLLocationCoordinate2D(latitude: 60.480960, longitude: 22.239808)
}
struct CourseMapView: View {

 @StateObject var viewModel = CourseSearchViewModel()

  @State var isShowSheet = false
  @State var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 60.480960,
                                                                            longitude: 22.239808),
                                             span: MKCoordinateSpan(latitudeDelta: 0.1,
                                                                    longitudeDelta: 0.1))

  @State var selectedCourse: Course? = nil

 func setCurrentLocation() {
  region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 60.480960, longitude: 22.239808), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
  }

  var body: some View {
   ZStack {
    if viewModel.location != nil {
      Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true, userTrackingMode: nil, annotationItems: viewModel.courses) { course in
        MapAnnotation(coordinate: .init(latitude: course.location.latitude, longitude: course.location.longitude)) {
          Image(systemName: "person")
            .frame(width: 44, height: 44)
            .onTapGesture(count: 1, perform: {
              selectedCourse = course
              print("\(selectedCourse)")
            })
        }
      }
      .ignoresSafeArea()
    } else {
      Text("locating user location")
    }
  }
   .fullScreenCover(item: $selectedCourse) { course in
       if let course = course {
         LocationInfoView(viewModel: LocationInfoViewModel(course: course))
           .environment(\.selectedCourse, self.$selectedCourse)
       }
   }
  .onAppear {
    setCurrentLocation()
  }
 }
}

struct SelectingAnnotationInMap_Previews: PreviewProvider {
    static var previews: some View {
        CourseMapView()
    }
}
