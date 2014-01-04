//
//  UPUrlDetailController.h
//  UrlpokeMobile
//
//  Created by Frank Smieja on 13/12/2013.
//  Copyright (c) 2013 Smartatech. All rights reserved.
//

#import <UIKit/UIKit.h>

char *name;
NSString *thisUrlId;
NSString *urlName, *urlThreshold, *urlAverage;
NSArray *urlStats;

@interface UPUrlDetailController : UIViewController <UITextFieldDelegate>
{
    IBOutlet UILabel *urlName;
    IBOutlet UILabel *threshold;
    IBOutlet UILabel *averageVal;
    IBOutlet UILabel *latestVal;
    IBOutlet UILabel *lastMeasured;
    IBOutlet UILabel *errorField;
    IBOutlet UITextField *urlid;
    IBOutlet UIActivityIndicatorView *myActivityIndicator;
}

-(IBAction)GetUrlData:(id)sender;
-(IBAction)GetUrl:(id)sender;
-(IBAction)GetUrlPlot:(id)sender;
-(void)populateUrlDetails:(NSDictionary *) dict;
@end