import XCTest
#if !os(Linux)
import CoreLocation
#endif
import Turf
#if os(OSX)
import struct Turf.Polygon // Conflicts with MapKit’s Polygon
#endif

class MultiPolygonTests: XCTestCase {
    
    func testMultiPolygonFeature() {
        let data = try! Fixture.geojsonData(from: "multipolygon")!
        let firstCoordinate = Location(latitude: 0, longitude: 0)
        let lastCoordinate = Location(latitude: 11, longitude: 11)
        
        let geojson = try! GeoJSON.parse(Feature.self, from: data)
        
        XCTAssert(geojson.geometry.type == .MultiPolygon)
        guard case let .MultiPolygon(multipolygonCoordinates) = geojson.geometry else {
            XCTFail()
            return
        }
        
        XCTAssert(multipolygonCoordinates.coordinates.first?.first?.first == firstCoordinate)
        XCTAssert(multipolygonCoordinates.coordinates.last?.last?.last == lastCoordinate)
        
        let encodedData = try! JSONEncoder().encode(geojson)
        let decoded = try! GeoJSON.parse(Feature.self, from: encodedData)
        guard case let .MultiPolygon(decodedMultipolygonCoordinates) = decoded.geometry else {
            XCTFail()
            return
        }
        XCTAssert(decodedMultipolygonCoordinates.coordinates.first?.first?.first == firstCoordinate)
        XCTAssert(decodedMultipolygonCoordinates.coordinates.last?.last?.last == lastCoordinate)
    }
    
    func testBuildMultiPolygonFeature() {
        let coordinates =
        [
            [
                [
                    Location(latitude: 0, longitude: 0),
                    Location(latitude: 0, longitude: 5),
                    Location(latitude: 0, longitude: 5),
                    Location(latitude: 0, longitude: 10),
                    Location(latitude: 10, longitude: 10),
                    Location(latitude: 10, longitude: 0),
                    Location(latitude: 5, longitude: 0),
                    Location(latitude: 0, longitude: 0),
                ],[
                    Location(latitude: 5, longitude: 1),
                    Location(latitude: 7, longitude: 1),
                    Location(latitude: 8.5, longitude: 1),
                    Location(latitude: 8.5, longitude: 4.5),
                    Location(latitude: 7, longitude: 4.5),
                    Location(latitude: 5, longitude: 4.5),
                    Location(latitude: 5, longitude: 1)
                ]
            ],[
                [
                    Location(latitude: 11, longitude: 11),
                    Location(latitude: 11.5, longitude: 11.5),
                    Location(latitude: 12, longitude: 12),
                    Location(latitude: 11, longitude: 12),
                    Location(latitude: 11, longitude: 11.5),
                    Location(latitude: 11, longitude: 11),
                    Location(latitude: 11, longitude: 11)
                ]
            ]
        ]
        
        let multiPolygon = Geometry.MultiPolygon(coordinates: .init(coordinates))
        var multiPolygonFeature = Feature(multiPolygon)
        multiPolygonFeature.identifier = FeatureIdentifier.string("uniqueIdentifier")
        multiPolygonFeature.properties = ["some": "var"]

        let encodedData = try! JSONEncoder().encode(multiPolygonFeature)
        let decodedCustomMultiPolygon = try! GeoJSON.parse(Feature.self, from: encodedData)
        
        let data = try! Fixture.geojsonData(from: "multipolygon")!
        let bundledMultiPolygon = try! GeoJSON.parse(Feature.self, from: data)
        guard case let .MultiPolygon(bundledMultipolygonCoordinates) = bundledMultiPolygon.geometry else {
            XCTFail()
            return
        }
        
        XCTAssert(decodedCustomMultiPolygon.geometry.type == .MultiPolygon)
        guard case let .MultiPolygon(decodedMultipolygonCoordinates) = decodedCustomMultiPolygon.geometry else {
            XCTFail()
            return
        }
        XCTAssertEqual(decodedMultipolygonCoordinates, bundledMultipolygonCoordinates)
    }
}
