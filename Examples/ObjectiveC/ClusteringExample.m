#import "ClusteringExample.h"
@import Mapbox;

NSString *const MBXExampleClustering = @"ClusteringExample";

@interface ClusteringExample () <MGLMapViewDelegate>

@property (nonatomic) MGLMapView *mapView;
@property (nonatomic) UIImage *icon;
@property (nonatomic) UILabel *popup;

@end

@implementation ClusteringExample

- (void)viewDidLoad {
    [super viewDidLoad];

    self.mapView = [[MGLMapView alloc] initWithFrame:self.view.bounds styleURL:[MGLStyle lightStyleURL]];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.tintColor = [UIColor darkGrayColor];
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];

    // Add our own gesture recognizer to handle taps on our custom map features. This gesture requires the built-in MGLMapView tap gestures (such as those for zoom and annotation selection) to fail.
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMapTap:)];
    for (UIGestureRecognizer *recognizer in self.mapView.gestureRecognizers) {
        if ([recognizer isKindOfClass:[UITapGestureRecognizer class]]) {
            [singleTap requireGestureRecognizerToFail:recognizer];
        }
    }
    [self.mapView addGestureRecognizer:singleTap];

    self.icon = [UIImage imageNamed:@"port"];
}

- (void)mapView:(MGLMapView *)mapView didFinishLoadingStyle:(MGLStyle *)style {
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"ports" ofType:@"geojson"]];

    MGLShapeSource *source = [[MGLShapeSource alloc] initWithIdentifier:@"clusteredPorts" URL:url options:@{
        MGLShapeSourceOptionClustered: @(YES),
        MGLShapeSourceOptionClusterRadius: @(self.icon.size.width)
    }];
    [style addSource:source];

    // Use a template image so that we can tint it with the `iconColor` runtime styling property.
    [style setImage:[self.icon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forName:@"icon"];

    // Show unclustered features as icons. The `cluster` attribute is built into clustering-enabled source features.
    MGLSymbolStyleLayer *ports = [[MGLSymbolStyleLayer alloc] initWithIdentifier:@"ports" source:source];
    ports.iconImageName = [NSExpression expressionForConstantValue:@"icon"];
    ports.iconColor = [NSExpression expressionForConstantValue:[[UIColor darkGrayColor] colorWithAlphaComponent:0.9]];
    ports.predicate = [NSPredicate predicateWithFormat:@"cluster != YES"];
    [style addLayer:ports];

    // Color clustered features based on clustered point counts.
    NSDictionary *stops = @{ @20:  [UIColor lightGrayColor],
                             @50:  [UIColor orangeColor],
                             @100: [UIColor redColor],
                             @200: [UIColor purpleColor] };
    // Show clustered features as circles. The `point_count` attribute is built into clustering-enabled source features.
    MGLCircleStyleLayer *circlesLayer = [[MGLCircleStyleLayer alloc] initWithIdentifier:@"clusteredPorts" source:source];
    circlesLayer.circleRadius = [NSExpression expressionForConstantValue:@(self.icon.size.width / 2)];
    circlesLayer.circleOpacity = [NSExpression expressionForConstantValue:@0.75];
    circlesLayer.circleStrokeColor = [NSExpression expressionForConstantValue:[[UIColor whiteColor] colorWithAlphaComponent:0.75]];
    circlesLayer.circleStrokeWidth = [NSExpression expressionForConstantValue:@2];
    circlesLayer.circleColor = [NSExpression expressionWithFormat:@"mgl_step:from:stops:(point_count, %@, %@)",
                                [UIColor lightGrayColor], stops];
    circlesLayer.predicate = [NSPredicate predicateWithFormat:@"cluster == YES"];
    [style addLayer:circlesLayer];

    // Label cluster circles with a layer of text indicating feature count. The value for `point_count` is an integer. In order to use that value for the `MGLSymbolStyleLayer.text` property, cast it as a string. 
    MGLSymbolStyleLayer *numbersLayer = [[MGLSymbolStyleLayer alloc] initWithIdentifier:@"clusteredPortsNumbers" source:source];
    numbersLayer.textColor = [NSExpression expressionForConstantValue:[UIColor whiteColor]];
    numbersLayer.textFontSize = [NSExpression expressionForConstantValue:@(self.icon.size.width / 2)];
    numbersLayer.iconAllowsOverlap = [NSExpression expressionForConstantValue:@(YES)];
    numbersLayer.text = [NSExpression expressionWithFormat:@"CAST(point_count, 'NSString')"];
    numbersLayer.predicate = [NSPredicate predicateWithFormat:@"cluster == YES"];
    [style addLayer:numbersLayer];
}

- (void)mapViewRegionIsChanging:(MGLMapView *)mapView {
    [self showPopup:NO animated:NO];
}

- (IBAction)handleMapTap:(UITapGestureRecognizer *)tap {
    if (tap.state == UIGestureRecognizerStateEnded) {
        CGPoint point = [tap locationInView:tap.view];
        CGFloat width = self.icon.size.width;
        CGRect rect = CGRectMake(point.x - width / 2, point.y - width / 2, width, width);

        // Find cluster circles and/or individual port icons in a touch-sized region around the tap.
        // In theory, we should only find either one cluster (since they don't overlap) or one port
        // (since overlapping ones would be clustered).
        NSArray *clusters = [self.mapView visibleFeaturesInRect:rect inStyleLayersWithIdentifiers:[NSSet setWithObject:@"clusteredPorts"]];
        NSArray *ports    = [self.mapView visibleFeaturesInRect:rect inStyleLayersWithIdentifiers:[NSSet setWithObject:@"ports"]];

        if (clusters.count) {
            [self showPopup:NO animated:YES];
            MGLPointFeature *cluster = (MGLPointFeature *)clusters.firstObject;
            [self.mapView setCenterCoordinate:cluster.coordinate zoomLevel:(self.mapView.zoomLevel + 1) animated:YES];
        } else if (ports.count) {
            MGLPointFeature *port = ((MGLPointFeature *)ports.firstObject);

            if (!self.popup) {
                self.popup = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
                self.popup.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
                self.popup.layer.cornerRadius = 4;
                self.popup.layer.masksToBounds = YES;
                self.popup.textAlignment = NSTextAlignmentCenter;
                self.popup.lineBreakMode = NSLineBreakByTruncatingTail;
                self.popup.font = [UIFont systemFontOfSize:16];
                self.popup.textColor = [UIColor blackColor];
                self.popup.alpha = 0;
                [self.view addSubview:self.popup];
            }

            self.popup.text = [NSString stringWithFormat:@"%@", [port attributeForKey:@"name"]];
            CGSize size = [self.popup.text sizeWithAttributes:@{ NSFontAttributeName: self.popup.font }];
            self.popup.bounds = CGRectInset(CGRectMake(0, 0, size.width, size.height), -10, -10);
            point = [self.mapView convertCoordinate:port.coordinate toPointToView:self.mapView];
            self.popup.center = CGPointMake(point.x, point.y - 50);

            if (self.popup.alpha < 1) {
                [self showPopup:YES animated:YES];
            }
        } else {
            [self showPopup:NO animated:YES];
        }
    }
}

- (void)showPopup:(BOOL)shouldShow animated:(BOOL)animated {
    CGFloat alpha = (shouldShow ? 1 : 0);
    if (animated) {
        __typeof__(self) __weak weakSelf = self;
        [UIView animateWithDuration:0.25 animations:^{
            weakSelf.popup.alpha = alpha;
        }];
    } else {
        self.popup.alpha = alpha;
    }
}

@end
