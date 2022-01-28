//
//  PersonView.swift
//  RememberMe
//
//  Created by Christopher Fouts on 11/18/21.
//

import SwiftUI
import MapKit

struct Location: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    let latitude: Double
    let longitude: Double
}

enum ConstantsEnum {
    static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    static let defaultLocation = CLLocationCoordinate2D(latitude: 37.331, longitude: -121.89)
}


struct PersonView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var settings : DisplaySettings
    @ObservedObject var person: Person
    @State private var showingMap = false
    @State private var mapRegion = MKCoordinateRegion(center: ConstantsEnum.defaultLocation, span: ConstantsEnum.defaultSpan)
    @StateObject var lf = LocationFetcher()
    
    var personImage: UIImage
    
    var body: some View {
        
        NavigationView {
            GeometryReader { geo in
                VStack {
                    Form {
                        Section {
                            TextField("Name", text: $person.name)
                        }
                        Section {
                            let image = Image(uiImage: personImage)
                            image
                                .resizable()
                                .scaledToFit()
                        }
                        Section {
                            //Text("Lattitude: \(person.lat), Longitude: \(person.long))
                            if person.coordinate != nil {
                                let newLocation = Location(id: UUID(), name: person.name, latitude: person.coordinate?.latitude ?? ConstantsEnum.defaultLocation.latitude, longitude: person.coordinate?.longitude ?? ConstantsEnum.defaultLocation.longitude)
                                Map(coordinateRegion: $person.region, annotationItems: [newLocation]) { location in
                                    MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)) {
                                        VStack {
                                            Image(systemName: "star.circle")
                                                .resizable()
                                                .foregroundColor(.red)
                                                .frame(width: 44, height: 44)
                                                .background(.white)
                                                .clipShape(Circle())

                                            Text(location.name)
                                                .padding(5)
                                                .background(Color.white)
                                                .cornerRadius(5)
                                        }
                                    }
                                }
                                    .frame(width: geo.size.width * 0.83, height: geo.size.height * 0.7)
                                Button ("Update Location") {
                                    person.lat = nil
                                    person.long = nil
                                }
                            } else {
                                let newLocation = Location(id: UUID(), name: "New location", latitude: lf.lastKnownLocation?.latitude ?? ConstantsEnum.defaultLocation.latitude, longitude: lf.lastKnownLocation?.longitude ?? ConstantsEnum.defaultLocation.longitude)
                                Map(coordinateRegion: $lf.region, annotationItems: [newLocation]) { location in
                                    MapMarker(coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
                                }
                                    .frame(width: geo.size.width * 0.83, height: geo.size.height * 0.7)
                                Button ("Save Location") {
                                    person.lat = newLocation.latitude
                                    person.long = newLocation.longitude
                                    person.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: newLocation.latitude, longitude: newLocation.longitude), span: ConstantsEnum.defaultSpan)
                                }
                            }

        

                        }
                    }

                }
            }

        }
        .navigationTitle("Edit Person")
        .navigationBarItems(trailing: Button("Done") {
            self.presentationMode.wrappedValue.dismiss()
            self.settings.showingPersonView = false
        })
    }

}

//struct PersonView_Previews: PreviewProvider {
//    static var previews: some View {
//        let person = Person(name: "Test name")
//        let image = UIImage(systemName: "person")!
//        let settings = DisplaySettings()
//        PersonView(settings: settings, person: person, personImage: image)
//    }
//}
