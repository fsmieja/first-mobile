//
//  UPPlotViewController.h
//  FirstWebData
//
//  Created by Frank Smieja on 28/12/2013.
//  Copyright (c) 2013 Smartatech. All rights reserved.
//

#import <UIKit/UIKit.h>

NSString *urlId;
NSString *urlName, *urlThreshold;
NSArray *urlStats;
int maxYValue, minXValue, maxXValue;

@interface UPPlotViewController : UIViewController <CPTPlotDataSource>

@property (nonatomic, strong) CPTGraphHostingView *hostView;
@property (copy) NSDictionary *urlData;


-(void)populateUrlPlot:(NSArray *)stats urlName:(NSString *)name urlId:(NSString *)thisId threshold:(NSString *)threshold;
-(NSNumber *)getIntDate:(NSString *)dateString;
-(void)setAxesLimits:(CPTXYPlotSpace *)plotSpace;
-(int)getMaxYValue;
-(int)getMinXValue;
-(int)getYMajorInterval;
@end
