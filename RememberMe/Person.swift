//
//  Person.swift
//  RememberMe
//
//  Created by Christopher Fouts on 11/18/21.
//

import Foundation
import SwiftUI
import MapKit

class Person : ObservableObject, Hashable, Codable {
    enum CodingKeys: CodingKey {
        case id, name, lat, long
    }
    
    var id = UUID()
    @Published var name : String
    @Published var lat : Double?
    @Published var long : Double?
    @Published var region : MKCoordinateRegion
    
//    var region: MKCoordinateRegion {
//        get {
//            if let lattitude = lat {
//                if let longitude = long {
//                    return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lattitude, longitude: longitude), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
//                }
//            }
//
//            return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), span: MKCoordinateSpan(latitudeDelta: 20, longitudeDelta: 20))
//
//        } set {
//            self.region = newValue
//        }
//    }
    
    init(name: String, lat: Double, long: Double) {
        self.name = name
        self.lat = lat
        self.long = long
        
        self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: long), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
    }
    
    init(name: String) {
        self.name = name
        
        self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5))
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var coordinate: CLLocationCoordinate2D? {
        if lat != nil && long != nil {
            return CLLocationCoordinate2D(latitude: lat!, longitude: long!)
        }
        
        return nil
    }
    
    
    static func ==(lhs: Person, rhs: Person) -> Bool {
        return lhs.id == rhs.id
    }
    
    public required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        let lattitude = try container.decode(Double.self, forKey: .lat)
        lat = lattitude
        let longitude = try container.decode(Double.self, forKey: .long)
        long = longitude
        
        self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lattitude, longitude: longitude), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
        
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(lat, forKey: .lat)
        try container.encode(long, forKey: .long)
    }

}
