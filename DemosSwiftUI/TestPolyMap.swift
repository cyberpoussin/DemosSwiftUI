import SwiftUI
import MapKit


let places: [AnyShopItem] = [
    .init(CoffeeShopItem(
            name: "KB",
            latitude: 48.8806699,
            longitude: 2.340791)),
    .init(CoffeeShopItem(
            name: "Ten Belles",
            latitude:  48.8734841,
            longitude: 2.3647217)),
    .init(CoffeeShopItem(
            name: "Terres de Café",
            latitude: 48.856904,
            longitude: 2.3015659)),
    .init(BurgerShopItem(
            name: "Dumbo",
            latitude: 48.88095,
            longitude: 2.33577)),
    .init(DefinitelyClosedShopItem(
        name: "PNY",
        latitude: 48.8719216,
        longitude: 2.353978
    ))
]

let places2: some ShopItem = anyShopItem(shop: CoffeeShopItem(
                                            name: "KB",
                                            latitude: 48.8806699,
                                            longitude: 2.340791))

func anyNyShopItem() -> some ShopItem {
    return CoffeeShopItem(
        name: "KB",
        latitude: 48.8806699,
        longitude: 2.340791)
}

struct MapViewWithAnnotations: View {
    
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 48.856614,
            longitude: 2.3522219),
        span: MKCoordinateSpan(
            latitudeDelta: 0.1,
            longitudeDelta: 0.1))
    
    @State private var selectedPlace: AnyShopItem? = nil
    
    var body: some View {
        
        NavigationView {
            Map(coordinateRegion: $region,
                annotationItems: places){ place in
                
                MapAnnotation(coordinate: place.coordinate){
                    place.annotation {
                        print("interactive and tapped")
                        selectedPlace = place
                    }
                    //place.annotation()
                }
            }
            .edgesIgnoringSafeArea(.all)
            .sheet(item: $selectedPlace) {item in
                if item.type is CoffeeShopItem {
                    Text("CoffeeShop : " + item.name)
                }
            }
        }
        
    }
}

typealias Action =  () -> ()

protocol ShopItem: Identifiable {
    associatedtype AnnotationView: View

    var id: UUID { get }
    var name: String { get }
    var latitude: Double { get }
    var longitude: Double { get }
    func annotation() -> AnnotationView
    

}
extension ShopItem {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude,
                               longitude: longitude)
    }
}

protocol Tappable {
}

func anyShopItem<T: ShopItem>(shop: T) -> some ShopItem {
    return shop
}

struct AnyShopItem: ShopItem, Tappable {
    let id: UUID
    let name: String
    let latitude: Double
    let longitude: Double
    let annotationStored: AnyView
    let type: Any
    
    func annotation(action: @escaping Action) -> some View {
        if type is Tappable {
            return AnyView(Button {
                action()
            } label: {
                annotation()
            })
        } else {
            return AnyView(annotation())
        }
    }
    
    func annotation() -> some View {
        annotationStored
    }
    
    init<T: ShopItem>(_ shop: T) {
        self.type = shop
        self.id = shop.id
        self.name = shop.name
        self.latitude = shop.latitude
        self.longitude = shop.longitude
        self.annotationStored = AnyView(shop.annotation())
    }
}


struct CoffeeShopItem: ShopItem, Tappable {
    var id = UUID()
    let name: String
    let latitude: Double
    let longitude: Double
    
    func annotation() -> some View {
        Image(systemName: "drop.fill")
            .foregroundColor(.pink)
            .font(.title)
    }
}

struct BurgerShopItem: ShopItem {
    var id = UUID()
    let name: String
    let latitude: Double
    let longitude: Double

    func annotation() -> some View {
        NavigationLink(
            destination: Text("BurgerShop : " + name)) {
            Image(systemName: "pin.circle.fill")
                .foregroundColor(.green)
                .font(.title)
        }
    }
}

struct DefinitelyClosedShopItem: ShopItem {
    var id = UUID()
    let name: String
    let latitude: Double
    let longitude: Double

    func annotation() -> some View {
        Text("closed")
            .foregroundColor(.purple)
            .font(.caption)
    }

}

struct MapDisplay_Previews: PreviewProvider {
    static var previews: some View {
        MapViewWithAnnotations()
    }
}
