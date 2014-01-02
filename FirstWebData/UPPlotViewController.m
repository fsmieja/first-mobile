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
    
    if ([title length] > 30 && UIDeviceOrientationIsPortrait(self.interfaceOrientation))
        titleStyle.fontSize = 12.0f;
    else
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

   // [self addPlotToGraph:graph name:@"URL Plot"]
    // Create the data plot
    CPTScatterPlot *urlPlot = [[CPTScatterPlot alloc] init];
    [graph addPlot:urlPlot toPlotSpace:plotSpace];

    // Create the threshold line
    CPTScatterPlot *thresholdPlot = [[CPTScatterPlot alloc] init];
    [graph addPlot:thresholdPlot toPlotSpace:plotSpace];

    // Create the average line
    CPTScatterPlot *averagePlot = [[CPTScatterPlot alloc] init];
    [graph addPlot:averagePlot toPlotSpace:plotSpace];

    // Set up plot space
    [plotSpace scaleToFitPlots:[NSArray arrayWithObjects:urlPlot, thresholdPlot, nil]];
    
    [self setAxesLimits:plotSpace];
    
    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
    [xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
    plotSpace.xRange = xRange;
    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
    [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.2f)];
    plotSpace.yRange = yRange;
    
    
    
    CPTMutableLineStyle *urlLineStyle = [urlPlot.dataLineStyle mutableCopy];
    CPTColor *urlColor = [CPTColor redColor];
    urlLineStyle.lineWidth = 2.5;
    urlLineStyle.lineColor = urlColor;
    CPTMutableLineStyle *urlSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    urlSymbolLineStyle.lineColor = urlColor;
    CPTPlotSymbol *urlSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    urlSymbol.fill = [CPTFill fillWithColor:urlColor];
    urlSymbol.lineStyle = urlSymbolLineStyle;
    urlSymbol.size = CGSizeMake(6.0f, 6.0f);

    [self initializePlot:urlPlot lineStyle:urlLineStyle plotSymbol:urlSymbol identifier:@"URL Plot"];
    
    CPTColor *thresholdColor = [CPTColor greenColor];
    CPTMutableLineStyle *thresholdLineStyle = [thresholdPlot.dataLineStyle mutableCopy];
    thresholdLineStyle.lineWidth = 1.5;
    thresholdLineStyle.lineColor = thresholdColor;

    [self initializePlot:thresholdPlot lineStyle:thresholdLineStyle plotSymbol:nil identifier:@"Threshold"];

    CPTColor *averageColor = [CPTColor blueColor];
    CPTMutableLineStyle *averageLineStyle = [averagePlot.dataLineStyle mutableCopy];
    averageLineStyle.lineWidth = 1.5;
    averageLineStyle.lineColor = averageColor;
    
    [self initializePlot:averagePlot lineStyle:averageLineStyle plotSymbol:nil identifier:@"Average"];
    [self addLegendToGraph:graph];

    
}

-(void)initializePlot:(CPTScatterPlot *)plot lineStyle:(CPTLineStyle *)lineStyle plotSymbol:(CPTPlotSymbol *)plotSymbol identifier:(NSString *)identifier {
    plot.dataLineStyle = lineStyle;
    plot.dataSource = self;
    plot.identifier = identifier;
    plot.plotSymbol = plotSymbol;

}
-(void)configureAxes {
    
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineColor = [CPTColor blackColor];
    lineStyle.lineWidth = 2.0f;
    
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

    // added for date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];
    
    // integer tick labels
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];

    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    
    [self getMinMaxXValue];
    
    [self configureAxis:axisSet.xAxis title:@"Time of day" majorInterval:(maxXValue-minXValue)/10 minorTicksPerInterval:1 titleOffset:15.0f
                    intersectsOtherAxisAt:0 lineStyle:lineStyle axisStyle:axisTextStyle titleStyle:axisTitleStyle labelFormatter:timeFormatter];
    [self setAxisVisibility:axisSet.xAxis from:minXValue to:maxXValue];

    [self configureAxis:axisSet.yAxis title:@"Load time (ms)" majorInterval:[self getYMajorInterval] minorTicksPerInterval:2 titleOffset:30.0f
                        intersectsOtherAxisAt:minXValue lineStyle:lineStyle axisStyle:axisTextStyle titleStyle:axisTitleStyle labelFormatter:formatter];
    [self setAxisVisibility:axisSet.yAxis from:0 to:maxYValue];

    /*
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor whiteColor];
    tickLineStyle.lineWidth = 2.0f;
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor blackColor];
    tickLineStyle.lineWidth = 1.0f;
     */
}

-(void)addLegendToGraph:(CPTGraph *)graph {
    graph.legend = [CPTLegend legendWithGraph:graph];
    graph.legend.fill = [CPTFill fillWithColor:[CPTColor darkGrayColor]];
    graph.legend.cornerRadius = 5.0;
    graph.legend.swatchSize = CGSizeMake(15.0, 15.0);
    graph.legend.numberOfRows = 1;
    graph.legendAnchor = CPTRectAnchorBottom;
    graph.legendDisplacement = CGPointMake(0.0, 12.0);
}

-(void)configureAxis:(CPTXYAxis *)axis title:(NSString *)title majorInterval:(int)interval minorTicksPerInterval:(int)minorTicks
            titleOffset:(CGFloat)titleOffset intersectsOtherAxisAt:(int)intersection lineStyle:(CPTLineStyle *)lineStyle
            axisStyle:(CPTTextStyle *)axisStyle titleStyle:(CPTTextStyle *)titleStyle labelFormatter:(NSFormatter *)labelFormatter{
    axis.majorIntervalLength = CPTDecimalFromInt(interval);
    axis.minorTicksPerInterval = minorTicks;
    axis.orthogonalCoordinateDecimal = CPTDecimalFromInt(intersection); //added for date, adjust x line
    axis.majorTickLineStyle = lineStyle;
    axis.minorTickLineStyle = lineStyle;
    axis.axisLineStyle = lineStyle;
    axis.minorTickLength = 5.0f;
    axis.majorTickLength = 7.0f;
    axis.labelOffset = 2.0f;
    axis.titleOffset = titleOffset;
    axis.title = title;
    axis.labelTextStyle = axisStyle;
    axis.titleTextStyle = titleStyle;
    axis.labelFormatter = labelFormatter;
}

-(void)setAxisVisibility:(CPTXYAxis *)axis from:(int)from to:(int)to {
    axis.visibleRange   = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInteger(from)
                                                                length:CPTDecimalFromInteger(to-from)];
    axis.gridLinesRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInteger(from)
                                                                length:CPTDecimalFromInteger(to-from)];
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
    if ([urlAverage integerValue] > maxVal)
        maxVal = [urlAverage integerValue];
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
                if ([plot.identifier isEqual:@"Threshold"] == YES)
                    return [NSNumber numberWithInt:[urlThreshold integerValue]];
                else
                    return [NSNumber numberWithInt:[urlAverage integerValue]];
                break;
        }
        return [NSDecimalNumber zero];
    
    }
    return [NSDecimalNumber zero];
}
/*
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	//	(iOS 5)
	//	Only allow rotation to landscape
	return (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft | toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) ;
}

- (BOOL)shouldAutorotate
{
	//	(iOS 6)
	//	No auto rotating
	return YES;
}


- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
	//	(iOS 6)
	//	Force to landscape
	return UIInterfaceOrientationLandscapeLeft;
}

- (NSUInteger)supportedInterfaceOrientations
{
    //return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft;
    return UIInterfaceOrientationMaskLandscape;
}
*/

// redraw on orientation change
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self initPlot];

}


-(void)populateUrlPlot:(NSArray *)stats urlName:(NSString *)name urlId:(NSString *)thisId threshold:(NSString *)threshold average:(NSString *)average {
    urlStats = stats;
    urlName = name;
    urlId = thisId;
    urlThreshold = threshold;
    urlAverage = average;
}

@end

