import SwiftUI
import MapboxMaps

class MapViewModel: ObservableObject {
    @Published var tappedCoordinates: CLLocationCoordinate2D?
}

struct ContentView: View {
    @StateObject private var mapViewModel = MapViewModel()
//    @State var showingPopUp = false


    var body: some View {
        VStack {
            MapBoxMapView(mapViewModel: mapViewModel)
                .environmentObject(mapViewModel)

            if let tappedCoordinates = mapViewModel.tappedCoordinates {
                Text("Tapped Coordinates: \(tappedCoordinates.latitude), \(tappedCoordinates.longitude)")
                    .foregroundColor(.black)
                    .padding()
//                Button(action: {
//                    withAnimation {
//                        showingPopUp = true
//                    } //trueにしないと画面遷移されない
//                }, label: {
//                    Text("View Spectra")
//                    .padding()
//                    .background(Color.white)
//                    .cornerRadius(12)
//                })
//                .fullScreenCover(isPresented: $showingPopUp) { //フルスクリーンの画面遷移
//                    PopupView(isPresent: $showingPopUp, info: url, Lat: tappedCoordinates.latitude, Lon: tappedCoordinates.longitude)
//            }

            }
        }
    }
}
//
//struct PopupView: View {
//    var info:String
//    @State var coordinate:[String]
//    
//    var body: some View {
//        VStack {}
//    }
//}

struct MapBoxMapView: View {
    @ObservedObject var mapViewModel: MapViewModel

    var body: some View {
        MapViewControllerRepresentable(mapViewModel: mapViewModel)
            .environmentObject(mapViewModel)
    }
}



struct MapViewControllerRepresentable: UIViewControllerRepresentable {
    class Coordinator: NSObject, ObservableObject {
        var mapViewModel: MapViewModel

        init(mapViewModel: MapViewModel) {
            self.mapViewModel = mapViewModel
        }
    }

    var mapViewModel: MapViewModel

    func makeCoordinator() -> Coordinator {
        return Coordinator(mapViewModel: mapViewModel)
    }

    func makeUIViewController(context: Context) -> MapViewController {
        let mapViewController = MapViewController()
        mapViewController.mapViewModel = context.coordinator.mapViewModel
        return mapViewController
    }

    func updateUIViewController(_ uiViewController: MapViewController, context: Context) {
        // ビューコントローラ内の関連するUI要素を更新する
    }
}

class MapViewController: UIViewController {
    internal var mapView: MapView!
    private var coordinatesLabel: UILabel!
    var mapViewModel: MapViewModel?

    override public func viewDidLoad() {
        super.viewDidLoad()

        let myResourceOptions = ResourceOptions(accessToken: "accessToken")
        let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), zoom: 0.1)
        
        let myMapInitOptions = MapInitOptions(resourceOptions: myResourceOptions, cameraOptions: cameraOptions, styleURI: StyleURI(rawValue: "mapbox://styles/araharuto/clpvzh143007x01rd13px558d"))

        
        mapView = MapView(frame: view.bounds, mapInitOptions: myMapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.view.addSubview(mapView)
        
        // Add a label to display coordinates
        coordinatesLabel = UILabel(frame: CGRect(x: 16, y: 25, width: 400, height: 60))
        coordinatesLabel.textColor = .white
        coordinatesLabel.backgroundColor = .black
        coordinatesLabel.alpha = 0.7
        coordinatesLabel.layer.cornerRadius = 5
        coordinatesLabel.clipsToBounds = true
        
        self.view.addSubview(coordinatesLabel)
        
        // Set up tap gesture recognizer
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleMapTap(sender:)))
        mapView.addGestureRecognizer(tap)

        mapView.mapboxMap.onNext(.mapLoaded) { _ in
            // Handle map loaded event if needed
        }
    }

    @objc private func handleMapTap(sender: UITapGestureRecognizer) {
        let point = sender.location(in: mapView)
        let coordinates = mapView.mapboxMap.coordinate(for: point)
        coordinatesLabel.text = "Lat: \(coordinates.latitude), Lon: \(coordinates.longitude)"

        // Update the tapped coordinates in the MapViewModel
        mapViewModel?.tappedCoordinates = coordinates
    }
}




#Preview {
    ContentView()
}

