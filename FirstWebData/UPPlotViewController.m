//
//  UPPlotViewController.m
//  FirstWebData
//
//  Created by Frank Smieja on 28/12/2013.
//  Copyright (c) 2013 Smartatech. All rights reserved.
//

#import "UPPlotViewController.h"
#import "UPGrabData.h"



@interface UPPlotViewController ()

@property (nonatomic, strong) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *themeButton;

@end

@implementation UPPlotViewController

#pragma mark - UIViewController lifecycle methods
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self initPlot];
}

#pragma mark - Chart behavior
-(void)initPlot {
    [self configureHost];
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];
}

-(void)configureHost {
    self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:self.view.bounds];
    self.hostView.allowPinchScaling = YES;
    [self.view addSubview:self.hostView];
/*
    // 1 - Set up view frame
    CGRect parentRect = self.view.bounds;
    CGSize toolbarSize = self.toolbar.bounds.size;
    parentRect = CGRectMake(parentRect.origin.x,
                            (parentRect.origin.y + toolbarSize.height),
                            parentRect.size.width,
                            (parentRect.size.height - toolbarSize.height));
    // 2 - Create host view
    self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:parentRect];
    self.hostView.allowPinchScaling = YES;
    [self.view addSubview:self.hostView];
*/

}

-(void)configureGraph {
    
    // If you make sure your dates are calculated at noon, you shouldn't have to
    // worry about daylight savings. If you use midnight, you will have to adjust
    // for daylight savings time.
    
    // Invert graph view to compensate for iOS coordinates
//    CGAffineTransform verticalFlip = CGAffineTransformMakeScale(1,-1);
//    self.view.transform = verticalFlip;

    
    // 1 - Create the graph
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    [graph applyTheme:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
    
    
    
    
    self.hostView.hostedGraph = graph;
    // 2 - Set graph title
    NSString *title = urlName;
    graph.title = title;
    // 3 - Create and set text style
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor whiteColor];
    titleStyle.fontName = @"Helvetica-Bold";
    titleStyle.fontSize = 16.0f;
    graph.titleTextStyle = titleStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    graph.titleDisplacement = CGPointMake(0.0f, 10.0f);
    // 4 - Set padding for plot area
    [graph.plotAreaFrame setPaddingLeft:30.0f];
    [graph.plotAreaFrame setPaddingBottom:30.0f];
    // 5 - Enable user interactions for plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
}

-(void)configurePlots {
    // 1 - Get graph and plot space
    CPTGraph *graph = self.hostView.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;

    // Create the data plot
    CPTScatterPlot *urlPlot = [[CPTScatterPlot alloc] init];
    urlPlot.dataSource = self;
    urlPlot.identifier = @"URL Plot";
    CPTColor *urlColor = [CPTColor redColor];
    [graph addPlot:urlPlot toPlotSpace:plotSpace];

    // Create the threshold line
    CPTScatterPlot *thresholdPlot = [[CPTScatterPlot alloc] init];
    thresholdPlot.dataSource = self;
    thresholdPlot.identifier = @"Threshold";
    CPTColor *thresholdColor = [CPTColor greenColor];
    [graph addPlot:thresholdPlot toPlotSpace:plotSpace];

    // Set up plot space
    [plotSpace scaleToFitPlots:[NSArray arrayWithObjects:urlPlot, thresholdPlot, nil]];
    
    [self setAxesLimits:plotSpace];
    
    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
    [xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
    plotSpace.xRange = xRange;
    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
    [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.2f)];
    plotSpace.yRange = yRange;
    
    
    graph.legend = [CPTLegend legendWithGraph:graph];
    graph.legend.fill = [CPTFill fillWithColor:[CPTColor darkGrayColor]];
    graph.legend.cornerRadius = 5.0;
    graph.legend.swatchSize = CGSizeMake(15.0, 15.0);
    graph.legendAnchor = CPTRectAnchorBottomRight;
    graph.legendDisplacement = CGPointMake(0.0, 12.0);
    
    
    // 4 - Create styles and symbols
    CPTMutableLineStyle *urlLineStyle = [urlPlot.dataLineStyle mutableCopy];
    urlLineStyle.lineWidth = 2.5;
    urlLineStyle.lineColor = urlColor;
    urlPlot.dataLineStyle = urlLineStyle;
    CPTMutableLineStyle *urlSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    urlSymbolLineStyle.lineColor = urlColor;
    CPTPlotSymbol *urlSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    urlSymbol.fill = [CPTFill fillWithColor:urlColor];
    urlSymbol.lineStyle = urlSymbolLineStyle;
    urlSymbol.size = CGSizeMake(6.0f, 6.0f);
    urlPlot.plotSymbol = urlSymbol;
    
    CPTMutableLineStyle *thresholdLineStyle = [thresholdPlot.dataLineStyle mutableCopy];
    thresholdLineStyle.lineWidth = 2.5;
    thresholdLineStyle.lineColor = thresholdColor;
    thresholdPlot.dataLineStyle = thresholdLineStyle;
    thresholdPlot.plotSymbol = nil;
    
}

-(void)configureAxes {
    
    // plotting style is set to line plots
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineColor = [CPTColor blackColor];
    lineStyle.lineWidth = 2.0f;
    

    // X-axis parameters setting
//    CPTXYAxisSet *axisSet = (id)graph.axisSet;
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    
    [self getMinMaxXValue];

    axisSet.xAxis.majorIntervalLength = CPTDecimalFromInt((maxXValue-minXValue)/10);
    axisSet.xAxis.minorTicksPerInterval = 1;
    axisSet.xAxis.orthogonalCoordinateDecimal = CPTDecimalFromInt(0); //added for date, adjust x line
    axisSet.xAxis.majorTickLineStyle = lineStyle;
    axisSet.xAxis.minorTickLineStyle = lineStyle;
    axisSet.xAxis.axisLineStyle = lineStyle;
    axisSet.xAxis.minorTickLength = 5.0f;
    axisSet.xAxis.majorTickLength = 7.0f;
    axisSet.xAxis.labelOffset = 2.0f;
    axisSet.xAxis.titleOffset = 15.0f;
    axisSet.xAxis.visibleRange   = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInteger(minXValue)
                                                                length:CPTDecimalFromInteger(maxXValue-minXValue)];
    axisSet.xAxis.gridLinesRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInteger(minXValue)
                                                                length:CPTDecimalFromInteger(maxXValue-minXValue)];
    
    // added for date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //dateFormatter.dateStyle = kCFDateFormatterMediumStyle;
    [dateFormatter setDateFormat:@"HH:mm"];
    CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];
    axisSet.xAxis.labelFormatter = timeFormatter;
    axisSet.xAxis.title = @"Time of day";
    
    // Y-axis parameters setting
    axisSet.yAxis.majorIntervalLength = CPTDecimalFromInt([self getYMajorInterval]);
    axisSet.yAxis.minorTicksPerInterval = 2;
    axisSet.yAxis.orthogonalCoordinateDecimal = CPTDecimalFromInt(minXValue); // added for date, adjusts y line
    axisSet.yAxis.majorTickLineStyle = lineStyle;
    axisSet.yAxis.minorTickLineStyle = lineStyle;
    axisSet.yAxis.axisLineStyle = lineStyle;
    axisSet.yAxis.minorTickLength = 5.0f;
    axisSet.yAxis.majorTickLength = 7.0f;
    axisSet.yAxis.labelOffset = 2.0f;
    //axisSet.yAxis.titleOffset = 30.0f;
    axisSet.yAxis.title = @"Load time (ms)";
    axisSet.yAxis.visibleRange   = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInteger(0)
                                                        length:CPTDecimalFromInteger(maxYValue)];
    axisSet.yAxis.gridLinesRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInteger(0)
                                                        length:CPTDecimalFromInteger(maxYValue)];

    
    // 1 - Create styles
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor whiteColor];
    axisTitleStyle.fontName = @"Helvetica-Bold";
    axisTitleStyle.fontSize = 12.0f;
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [CPTColor whiteColor];
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = [CPTColor whiteColor];
    axisTextStyle.fontName = @"Helvetica-Bold";
    axisTextStyle.fontSize = 9.0f;

    axisSet.yAxis.labelTextStyle = axisTextStyle;
    axisSet.xAxis.labelTextStyle = axisTextStyle;

    axisSet.xAxis.titleTextStyle = axisTitleStyle;
    axisSet.yAxis.titleTextStyle = axisTitleStyle;

    // integer tick labels
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    CPTXYAxis *y = axisSet.yAxis;
    y.labelFormatter = formatter;
    
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor whiteColor];
    tickLineStyle.lineWidth = 2.0f;
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor blackColor];
    tickLineStyle.lineWidth = 1.0f;
}

// sets the limits on the axes for this plot
-(void)setAxesLimits:(CPTXYPlotSpace *)plotSpace {
    NSDictionary *minPoint = [urlStats objectAtIndex:0];
    NSDictionary *maxPoint = [urlStats objectAtIndex:[urlStats count]-1];
    NSNumber *minDate = [[NSNumber alloc] init];
    NSNumber *maxDate = [[NSNumber alloc] init];
    maxYValue = [self getMaxYValue];
    minDate = [self getIntDate:[minPoint objectForKey:@"created_at"]];
    maxDate = [self getIntDate:[maxPoint objectForKey:@"created_at"]];
    int range = [maxDate integerValue] - [minDate integerValue];
    // sets the range of x values
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInteger([minDate integerValue])
                                                    length:CPTDecimalFromInteger(range)];
    // sets the range of y values
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0)
                                                    length:CPTDecimalFromFloat(maxYValue*1.2f)];
    
}

// returns integer value of (ms?) since Jan 1 2001
-(NSNumber *)getIntDate:(NSString *)dateString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDate *dt = [[NSDate alloc] init];
    dateString = [dateString stringByReplacingOccurrencesOfString:@"UTC" withString:@""];
    // this is imporant - we set our input date format to match our input string
    // if format doesn't match you'll get nil from your string, so be careful
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    // voila!
    dt = [dateFormatter dateFromString:dateString];
    return [NSNumber numberWithDouble:[dt timeIntervalSinceReferenceDate]];
}

-(int)getMaxYValue {
    int maxVal = [urlThreshold integerValue];
    for (NSDictionary *point in urlStats) {
        int thisVal = [[point objectForKey:@"avtime"] integerValue];
        if (thisVal > maxVal)
            maxVal = thisVal;
    }
    return maxVal*1.2f;
}

-(void)getMinMaxXValue {
   minXValue = [[self getIntDate:[[urlStats objectAtIndex:0] objectForKey:@"created_at"]] integerValue];
   maxXValue = [[self getIntDate:[[urlStats objectAtIndex:[urlStats count]-1] objectForKey:@"created_at"]] integerValue];
}

-(int)getYMajorInterval {
    if (maxYValue<100)
        return 20;
    if (maxYValue<200)
        return 50;
    if (maxYValue<500)
        return 100;
    if (maxYValue<1000)
        return 200;
    if (maxYValue<2000)
        return 400;
    if (maxYValue<5000)
        return 1000;
    if (maxYValue < 10000)
        return 2000;
    return 3000;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    if ([plot.identifier isEqual:@"URL Plot"] == YES) {
        return [urlStats count];
    }
    return 2;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    if ([plot.identifier isEqual:@"URL Plot"] == YES) {
        NSDictionary *point = [urlStats objectAtIndex:index];
        switch (fieldEnum) {
            case CPTScatterPlotFieldX:
                return [self getIntDate:[point objectForKey:@"created_at"]];
                break;
            case CPTScatterPlotFieldY:
                return [NSNumber numberWithInt:[[point objectForKey:@"avtime"] intValue]];
                break;
        }
        return [NSDecimalNumber zero];
    }
    else {
        int thisIndex = (index==0) ? 0 : [urlStats count]-1;
        NSDictionary *point = [urlStats objectAtIndex:thisIndex];
        switch (fieldEnum) {
            case CPTScatterPlotFieldX:
                return [self getIntDate:[point objectForKey:@"created_at"]];
                break;
            case CPTScatterPlotFieldY:
                return [NSNumber numberWithInt:[urlThreshold integerValue]];
                break;
        }
        return [NSDecimalNumber zero];
    
    }
    return [NSDecimalNumber zero];
}





-(void)populateUrlPlot:(NSArray *)stats urlName:(NSString *)name urlId:(NSString *)thisId threshold:(NSString *)threshold {
    urlStats = stats;
    urlName = name;
    urlId = thisId;
    urlThreshold = threshold;
    
}

@end

