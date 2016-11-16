//
//  Copyright © 2016 RunScribe. All rights reserved.
//

#import "RSCoreXYZGraph.h"

static double const kFrameRate = 5.0;  // frames per second
static NSUInteger const kMaxDataPoints = 52;
static NSString *const kXPlotIdentifier = @"x";
static NSString *const kYPlotIdentifier = @"y";
static NSString *const kZPlotIdentifier = @"z";

@interface RSCoreXYZGraph() <CPTPlotDataSource>

@property (nonatomic, strong) CPTGraphHostingView *defaultLayerHostingView;
@property (nonatomic, strong) CPTGraph *graph;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSMutableArray *plotData;
@property (nonatomic, assign) NSSignedRange yAxisRange;
@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, readonly) CGFloat titleSize;

@end

@implementation RSCoreXYZGraph

- (instancetype)initWithHostingView:(CPTGraphHostingView *)hostingView theme:(CPTTheme *)theme title:(NSString *)title yAxisRange:(NSSignedRange)yAxisRange;
{
    self = [super init];
    if (self)
    {
        self.plotData = [[NSMutableArray alloc] initWithCapacity:kMaxDataPoints];
        self.title = title;
        self.yAxisRange = yAxisRange;
        [self renderInView:hostingView withTheme:theme];
    }
    return self;
}

- (CGFloat)titleSize
{
    CGFloat size;
    
    switch (UI_USER_INTERFACE_IDIOM())
    {
        case UIUserInterfaceIdiomPad:
            size = 24.0;
            break;
            
        case UIUserInterfaceIdiomPhone:
            size = 16.0;
            break;
            
        default:
            size = 12.0;
            break;
    }
    
    return size;
}

- (void)renderInView:(CPTGraphHostingView *)hostingView withTheme:(CPTTheme *)theme
{
    [self killGraph];
    [self reset];
    [self renderInGraphHostingView:hostingView withTheme:theme];
    [self formatAllGraphs];
    self.defaultLayerHostingView = hostingView;
}

- (void)killGraph
{
    [[CPTAnimation sharedInstance] removeAllAnimationOperations];
    if (self.defaultLayerHostingView)
    {
        [self.defaultLayerHostingView removeFromSuperview];
        self.defaultLayerHostingView.hostedGraph = nil;
        self.defaultLayerHostingView = nil;
    }
    self.graph = nil;
}

- (void)reset
{
    [self.plotData removeAllObjects];
    self.currentIndex = 0;
}

- (void)renderInGraphHostingView:(CPTGraphHostingView *)hostingView withTheme:(CPTTheme *)theme
{
    CGRect bounds = hostingView.bounds;
    
    self.graph = [[CPTXYGraph alloc] initWithFrame:bounds];
    hostingView.hostedGraph = self.graph;
    [self.graph applyTheme:theme];
    
    self.graph.plotAreaFrame.paddingTop = self.titleSize;
    self.graph.plotAreaFrame.paddingRight = 0;
    self.graph.plotAreaFrame.paddingBottom = self.titleSize;
    self.graph.plotAreaFrame.paddingLeft = self.titleSize * CPTFloat(2.5);
    self.graph.plotAreaFrame.masksToBorder = NO;
    
    // Grid line styles
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 0.75;
    majorGridLineStyle.lineColor = [[CPTColor colorWithGenericGray:CPTFloat(0.2)] colorWithAlphaComponent:CPTFloat(0.75)];
    
    CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
    minorGridLineStyle.lineWidth = 0.25;
    minorGridLineStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:CPTFloat(0.1)];
    
    // Axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self.graph.axisSet;
    CPTXYAxis *x = axisSet.xAxis;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    
    CPTXYAxis *y = axisSet.yAxis;
    y.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
    y.orthogonalPosition = @(0.0);
    y.majorGridLineStyle = majorGridLineStyle;
    y.minorGridLineStyle = minorGridLineStyle;
    y.minorTicksPerInterval = 3;
    y.axisConstraints = [CPTConstraints constraintWithLowerOffset:0.0];
    
    // X, Y, Z plots
    CPTScatterPlot *xLinePlot = [self createScatterPlot:kXPlotIdentifier lineColor:[CPTColor redColor]];
    CPTScatterPlot *yLinePlot = [self createScatterPlot:kYPlotIdentifier lineColor:[CPTColor greenColor]];
    CPTScatterPlot *zLinePlot = [self createScatterPlot:kZPlotIdentifier lineColor:[CPTColor blueColor]];
    [self.graph addPlot:xLinePlot];
    [self.graph addPlot:yLinePlot];
    [self.graph addPlot:zLinePlot];
    
    // Plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@(0.0) length:@(kMaxDataPoints - 2)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@(self.yAxisRange.location) length:@(self.yAxisRange.length)];
    
    // Legend
    self.graph.legend                 = [CPTLegend legendWithGraph:self.graph];
    self.graph.legend.fill            = [CPTFill fillWithColor:[CPTColor darkGrayColor]];
    self.graph.legend.borderLineStyle = x.axisLineStyle;
    self.graph.legend.cornerRadius    = 5.0;
    self.graph.legend.numberOfRows    = 1;
    self.graph.legendAnchor           = CPTRectAnchorBottom;
    self.graph.legendDisplacement     = CGPointMake(0.0, self.titleSize * CPTFloat(1.25));
}

- (CPTScatterPlot *)createScatterPlot:(NSString *)identifier lineColor:(CPTColor *)lineColor
{
    CPTScatterPlot *plot = [[CPTScatterPlot alloc] init];
    plot.identifier = identifier;
    plot.cachePrecision = CPTPlotCachePrecisionDouble;
    CPTMutableLineStyle *zLineStyle = [plot.dataLineStyle mutableCopy];
    zLineStyle.lineWidth = 1.5;
    zLineStyle.lineColor = lineColor;
    plot.dataLineStyle = zLineStyle;
    plot.dataSource = self;
    plot.attributedTitle = [[NSAttributedString alloc] initWithString:identifier];
    
    return plot;
}

- (void)formatAllGraphs
{
    CGFloat graphTitleSize = self.titleSize;
    
    // Title
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color = [CPTColor grayColor];
    textStyle.fontName = @"Helvetica-Bold";
    textStyle.fontSize = graphTitleSize;
    
    self.graph.title = self.title;
    self.graph.titleTextStyle = textStyle;
    self.graph.titleDisplacement = CPTPointMake(0.0, textStyle.fontSize * CPTFloat(1.5));
    self.graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    
    // Padding
    CGFloat boundsPadding = graphTitleSize;
    self.graph.paddingLeft = boundsPadding;
    if (self.graph.title.length > 0)
    {
        self.graph.paddingTop = MAX(self.graph.titleTextStyle.fontSize * CPTFloat(2.0), boundsPadding);
    }
    else
    {
        self.graph.paddingTop = boundsPadding;
    }
    self.graph.paddingRight = boundsPadding;
    self.graph.paddingBottom = boundsPadding;
    
    // Axis labels
    CGFloat labelSize = graphTitleSize * CPTFloat(0.5);
    for (CPTAxis *axis in self.graph.axisSet.axes)
    {
        // Axis labels
        textStyle = [axis.labelTextStyle mutableCopy];
        textStyle.fontSize = labelSize;
        axis.labelTextStyle = textStyle;
        
        textStyle = [axis.minorTickLabelTextStyle mutableCopy];
        textStyle.fontSize = labelSize;
        axis.minorTickLabelTextStyle = textStyle;
    }
    
    // Plot labels
    for (CPTPlot *plot in self.graph.allPlots)
    {
        textStyle = [plot.labelTextStyle mutableCopy];
        textStyle.fontSize = labelSize;
        plot.labelTextStyle = textStyle;
    }
    
    // Legend
    CPTLegend *theLegend = self.graph.legend;
    textStyle = [theLegend.textStyle mutableCopy];
    textStyle.fontSize = labelSize;
    theLegend.textStyle = textStyle;
    theLegend.swatchSize = CGSizeMake( labelSize * CPTFloat(1.5), labelSize * CPTFloat(1.5) );
    theLegend.rowMargin = labelSize * CPTFloat(0.75);
    theLegend.columnMargin = labelSize * CPTFloat(0.75);
    theLegend.paddingLeft = labelSize * CPTFloat(0.375);
    theLegend.paddingTop = labelSize * CPTFloat(0.375);
    theLegend.paddingRight = labelSize * CPTFloat(0.375);
    theLegend.paddingBottom = labelSize * CPTFloat(0.375);
}

- (void)addNewData:(RSSensorSample *)sample
{
    CPTPlot *xPlot = [self.graph plotWithIdentifier:kXPlotIdentifier];
    CPTPlot *yPlot = [self.graph plotWithIdentifier:kYPlotIdentifier];
    CPTPlot *zPlot = [self.graph plotWithIdentifier:kZPlotIdentifier];
    
    if (xPlot && yPlot && zPlot)
    {
        if (self.plotData.count >= kMaxDataPoints)
        {
            [self.plotData removeObjectAtIndex:0];
            [xPlot deleteDataInIndexRange:NSMakeRange(0, 1)];
            [yPlot deleteDataInIndexRange:NSMakeRange(0, 1)];
            [zPlot deleteDataInIndexRange:NSMakeRange(0, 1)];
        }
        
        CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
        NSUInteger location = (self.currentIndex >= kMaxDataPoints ? self.currentIndex - kMaxDataPoints + 2 : 0);
        
        CPTPlotRange *oldRange = [CPTPlotRange plotRangeWithLocation:@((location > 0) ? (location - 1) : 0)
                                                              length:@(kMaxDataPoints - 2)];
        CPTPlotRange *newRange = [CPTPlotRange plotRangeWithLocation:@(location)
                                                              length:@(kMaxDataPoints - 2)];
        
        [CPTAnimation animate:plotSpace
                     property:@"xRange"
                fromPlotRange:oldRange
                  toPlotRange:newRange
                     duration:CPTFloat(1.0 / kFrameRate)];
        
        self.currentIndex++;
        [self.plotData addObject:sample];
        
        [xPlot insertDataAtIndex:self.plotData.count - 1 numberOfRecords:1];
        [yPlot insertDataAtIndex:self.plotData.count - 1 numberOfRecords:1];
        [zPlot insertDataAtIndex:self.plotData.count - 1 numberOfRecords:1];
    }
}

#pragma mark - Plot Data Source Methods

- (NSUInteger)numberOfRecordsForPlot:(nonnull CPTPlot *)plot
{
    return self.plotData.count;
}

- (nullable id)numberForPlot:(nonnull CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber *num = nil;
    
    switch (fieldEnum) {
        case CPTScatterPlotFieldX:
            num = @(index + self.currentIndex - self.plotData.count);
            break;
            
        case CPTScatterPlotFieldY: {
            RSSensorSample *sample = self.plotData[index];
            if ([plot.identifier isEqual:kXPlotIdentifier])
            {
                num = sample.x;
            }
            else if ([plot.identifier isEqual:kYPlotIdentifier])
            {
                num = sample.y;
            }
            else if ([plot.identifier isEqual:kZPlotIdentifier])
            {
                num = sample.z;
            }
            break;
        }
    }
    
    return num;
}

@end
