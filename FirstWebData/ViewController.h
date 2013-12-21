//
//  ViewController.h
//  FirstWebData
//
//  Created by Frank Smieja on 13/12/2013.
//  Copyright (c) 2013 Smartatech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UPGrabData.h"

char *name;

@interface ViewController : UIViewController <UITextFieldDelegate>
{
    IBOutlet UILabel *urlName;
    IBOutlet UILabel *threshold;
    IBOutlet UILabel *averageVal;
    IBOutlet UILabel *lastMeasured;
    IBOutlet UILabel *errorField;
    IBOutlet UITextField *urlid;
    IBOutlet UIActivityIndicatorView *myActivityIndicator;
}

-(IBAction)GetUrlData:(id)sender;
-(IBAction)GetUrl:(id)sender;

@end
