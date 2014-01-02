//
//  UPPlotViewController.h
//  FirstWebData
//
//  Created by Frank Smieja on 28/12/2013.
//  Copyright (c) 2013 Smartatech. All rights reserved.
//

#import <UIKit/UIKit.h>

NSString *urlId;
NSString *urlName, *urlThreshold, *urlAverage;
NSArray *urlStats;
int maxYValue, minXValue, maxXValue;

@interface UPPlotViewController : UIViewController <CPTPlotDataSource>

@property (nonatomic, strong) CPTGraphHostingView *hostView;
@property (copy) NSDictionary *urlData;


-(void)populateUrlPlot:(NSArray *)stats urlName:(NSString *)name urlId:(NSString *)thisId threshold:(NSString *)threshold average:(NSString *)average;
-(NSNumber *)getIntDate:(NSString *)dateString;
-(void)setAxesLimits:(CPTXYPlotSpace *)plotSpace;
-(int)getMaxYValue;
-(int)getMinXValue;
-(int)getYMajorInterval;
-(void)configureAxis:(CPTXYAxis *)axis title:(NSString *)title majorInterval:(int)interval
        minorTicksPerInterval:(int)minorTicks titleOffset:(CGFloat)titleOffset intersectsOtherAxisAt:(int)intersection
        lineStyle:(CPTLineStyle *)lineStyle axisStyle:axisTextStyle titleStyle:axisTitleStyle labelFormatter:formatter;
-(void)setAxisVisibility:(CPTXYAxis *)axis from:(int)from to:(int)to;
-(void)addLegendToGraph:(CPTGraph *)graph;
-(void)initializePlot:(CPTScatterPlot *)plot lineStyle:(CPTLineStyle *)lineStyle plotSymbol:(CPTPlotSymbol *)plotSymbol identifier:(NSString *)identifier;
@end
