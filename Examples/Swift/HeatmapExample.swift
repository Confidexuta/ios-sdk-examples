
import Mapbox

@objc(HeatmapExample_Swift)

class HeatmapExample: UIViewController, MGLMapViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        let mapView = MGLMapView(frame: view.bounds, styleURL: MGLStyle.darkStyleURL())
        mapView.delegate = self
        mapView.tintColor = .lightGray
        view.addSubview(mapView)
        
    }
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        guard let url = URL(string: "https://www.mapbox.com/mapbox-gl-js/assets/earthquakes.geojson") else { return }
        let source = MGLShapeSource(identifier: "earthquakes", url: url, options: nil)
        style.addSource(source)
        
        let layer = MGLHeatmapStyleLayer(identifier: "earthquakes", source: source)
        
        // Set color intervals.
        let colorDictionary : [Double : UIColor] = [0: .clear,
                               0.01 : .white,
                               0.15 : UIColor(red:0.19, green:0.30, blue:0.80, alpha:1.0),
                               0.5 : UIColor(red:0.73, green:0.23, blue:0.25, alpha:1.0),
                               1 : .yellow
        ]
        layer.heatmapColor = NSExpression(format: "FUNCTION($heatmapDensity, 'mgl_interpolateWithCurveType:parameters:stops:', 'linear', nil, %@)", colorDictionary)
        layer.heatmapIntensity = NSExpression(format: "FUNCTION($zoomLevel, 'mgl_interpolateWithCurveType:parameters:stops:', 'linear', nil, %@)",
                                              [0: 1,
                                               9: 3])
        layer.heatmapRadius = NSExpression(format: "FUNCTION($zoomLevel, 'mgl_interpolateWithCurveType:parameters:stops:', 'linear', nil, %@)",
                                           [0: 4,
                                            9: 30])
        layer.heatmapWeight = NSExpression(format: "FUNCTION(magnitude, 'mgl_interpolateWithCurveType:parameters:stops:', 'linear', nil, %@)",
                                           [0: 0,
                                            6: 1])
        
        layer.heatmapOpacity = NSExpression(format: "FUNCTION($zoomLevel, 'mgl_stepWithMinimum:stops:', 0.75, %@)", [9: 0])
        
        style.addLayer(layer)
        
        // TODO: Add circle layer for higher zoom levels
    }

}
