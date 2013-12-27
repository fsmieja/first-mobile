//
//  TableViewController.h
//  FirstWebData
//
//  Created by Frank Smieja on 22/12/2013.
//  Copyright (c) 2013 Smartatech. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "UPGrabData.h"

@interface TableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (assign, nonatomic) BOOL ascending;

-(void)reportError:(NSString *)message;
-(void)populateUrlList:(NSArray *)urlList;
-(IBAction)GetUrlData:(id)sender;
-(IBAction)Logout:(id)sender;
@end


