
#import "HeatmapExample.h"
@import Mapbox;

NSString *const MBXExampleHeatmap = @"HeatmapExample";

@interface HeatmapExample () <MGLMapViewDelegate>

@end

@implementation HeatmapExample

- (void)viewDidLoad {
    [super viewDidLoad];
    MGLMapView *mapView = [[MGLMapView alloc] initWithFrame:self.view.bounds styleURL:[MGLStyle darkStyleURL]];
    mapView.delegate = self;
    mapView.tintColor = [UIColor lightGrayColor];
    [self.view addSubview:mapView];
}

- (void)mapView:(MGLMapView *)mapView didFinishLoadingStyle:(MGLStyle *)style {
    NSURL *url = [NSURL URLWithString:@"https://www.mapbox.com/mapbox-gl-js/assets/earthquakes.geojson"];
    MGLShapeSource *source = [[MGLShapeSource alloc] initWithIdentifier:@"earthquakes" URL:url options:nil];
    [mapView.style addSource:source];
    
    NSDictionary *colorDictionary = @{ @0 : [UIColor clearColor],
                                       @0.01 : [[UIColor whiteColor] colorWithAlphaComponent:0.5],
                                       @0.15 : [UIColor colorWithRed:0.19 green:0.3 blue:0.8 alpha:0.5],
                                       @0.5 : [UIColor colorWithRed:0.73 green:0.23 blue:0.25 alpha:0.5],
                                       @1 : [[UIColor yellowColor] colorWithAlphaComponent:0.5]
                                       };
    MGLHeatmapStyleLayer *layer = [[MGLHeatmapStyleLayer alloc] initWithIdentifier:@"earthquakes" source:source];
    layer.heatmapIntensity = [NSExpression expressionWithFormat:@"FUNCTION($zoomLevel, 'mgl_interpolateWithCurveType:parameters:stops:', 'linear', nil, %@)", @{@0: @1, @9: @3 }];
    layer.heatmapRadius = [NSExpression expressionWithFormat:@"FUNCTION($zoomLevel, 'mgl_interpolateWithCurveType:parameters:stops:', 'linear', nil, %@)", @{@0: @2, @9: @20}];
    layer.heatmapWeight = [NSExpression expressionWithFormat:@"FUNCTION(magnitude, 'mgl_interpolateWithCurveType:parameters:stops:', 'linear', nil, %@)", @{@0: @0, @6: @1}];
    layer.heatmapColor = [NSExpression expressionWithFormat:@"FUNCTION($heatmapDensity, 'mgl_interpolateWithCurveType:parameters:stops:', 'linear', nil, %@)", colorDictionary];
    [style addLayer:layer];
}

@end
