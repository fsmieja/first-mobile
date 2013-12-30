//
//  PlotViewController.h
//  FirstWebData
//
//  Created by Frank Smieja on 28/12/2013.
//  Copyright (c) 2013 Smartatech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlotViewController : UIViewController <CPTPlotDataSource>

@property (nonatomic, strong) CPTGraphHostingView *hostView;

@end
