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
    NSString *title = @"Average load time (ms)";
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
    // 2 - Create the three plots
    CPTScatterPlot *urlPlot = [[CPTScatterPlot alloc] init];
    urlPlot.dataSource = self;
    urlPlot.identifier = @"URL Plot";
    CPTColor *urlColor = [CPTColor redColor];
    [graph addPlot:urlPlot toPlotSpace:plotSpace];
    // 3 - Set up plot space
    [plotSpace scaleToFitPlots:[NSArray arrayWithObjects:urlPlot, nil]];
    
    [self setAxesLimits:plotSpace];
    
    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
    [xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
    plotSpace.xRange = xRange;
    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
    [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.2f)];
    plotSpace.yRange = yRange;
    
    
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
}

-(void)configureAxes {
    
    // plotting style is set to line plots
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineColor = [CPTColor blackColor];
    lineStyle.lineWidth = 2.0f;
    
    NSTimeInterval oneDay = 24 * 60 * 60;
    NSTimeInterval oneHour = 60 * 60;

    // X-axis parameters setting
//    CPTXYAxisSet *axisSet = (id)graph.axisSet;
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    int minX = [self getMinXValue];

    axisSet.xAxis.majorIntervalLength = CPTDecimalFromFloat(oneHour);
    axisSet.xAxis.minorTicksPerInterval = 0;
    axisSet.xAxis.orthogonalCoordinateDecimal = CPTDecimalFromInt(0); //added for date, adjust x line
    axisSet.xAxis.majorTickLineStyle = lineStyle;
    axisSet.xAxis.minorTickLineStyle = lineStyle;
    axisSet.xAxis.axisLineStyle = lineStyle;
    axisSet.xAxis.minorTickLength = 5.0f;
    axisSet.xAxis.majorTickLength = 7.0f;
    axisSet.xAxis.labelOffset = 3.0f;
    
    // added for date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //NSDate *refDate = [NSDate dateWithTimeIntervalSinceReferenceDate:31556926 * 10];
    //NSDate *refDate = [NSDate dateWithTimeIntervalSinceReferenceDate:minX];
    dateFormatter.dateStyle = kCFDateFormatterMediumStyle;
    CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];
    //timeFormatter.referenceDate = refDate;
    axisSet.xAxis.labelFormatter = timeFormatter;
    axisSet.xAxis.title = @"Date";
    
    // Y-axis parameters setting
    axisSet.yAxis.majorIntervalLength = CPTDecimalFromInt(maxYValue/5);
    axisSet.yAxis.minorTicksPerInterval = 2;
    axisSet.yAxis.orthogonalCoordinateDecimal = CPTDecimalFromInt(minX); // added for date, adjusts y line
    axisSet.yAxis.majorTickLineStyle = lineStyle;
    axisSet.yAxis.minorTickLineStyle = lineStyle;
    axisSet.yAxis.axisLineStyle = lineStyle;
    axisSet.yAxis.minorTickLength = 5.0f;
    axisSet.yAxis.majorTickLength = 7.0f;
    axisSet.yAxis.labelOffset = 3.0f;
    axisSet.yAxis.title = @"ms";
    axisSet.yAxis.visibleRange   = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInteger(0)
                                                        length:CPTDecimalFromInteger(1000)];
    axisSet.yAxis.gridLinesRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInteger(0)
                                                        length:CPTDecimalFromInteger(1000)];

    
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
    axisTextStyle.fontSize = 11.0f;
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
    int maxVal = 0;
    for (NSDictionary *point in urlStats) {
        int thisVal = [[point objectForKey:@"avtime"] integerValue];
        if (thisVal > maxVal)
            maxVal = thisVal;
    }
    return maxVal;
}

-(int)getMinXValue {
   return [[self getIntDate:[[urlStats objectAtIndex:0] objectForKey:@"created_at"]] integerValue];
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
    return [urlStats count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
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




-(void)populateUrlPlot:(NSArray *)stats urlName:(NSString *)name urlId:(NSString *)thisId {
    urlStats = stats;
    urlName = name;
    urlId = thisId;
    
    
}

/*
-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    NSInteger valueCount = [[[CPDStockPriceStore sharedInstance] datesInMonth] count];
    switch (fieldEnum) {
        case CPTScatterPlotFieldX:
            if (index < valueCount) {
                return [NSNumber numberWithUnsignedInteger:index];
            }
            break;
            
        case CPTScatterPlotFieldY:
            if ([plot.identifier isEqual:CPDTickerSymbolAAPL] == YES) {
                return [[[CPDStockPriceStore sharedInstance] monthlyPrices:CPDTickerSymbolAAPL] objectAtIndex:index];
            } else if ([plot.identifier isEqual:CPDTickerSymbolGOOG] == YES) {
                return [[[CPDStockPriceStore sharedInstance] monthlyPrices:CPDTickerSymbolGOOG] objectAtIndex:index];
            } else if ([plot.identifier isEqual:CPDTickerSymbolMSFT] == YES) {
                return [[[CPDStockPriceStore sharedInstance] monthlyPrices:CPDTickerSymbolMSFT] objectAtIndex:index];
            }
            break;
    }
    return [NSDecimalNumber zero];
}
 */
@end

