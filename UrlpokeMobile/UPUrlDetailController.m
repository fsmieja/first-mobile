//
//  UPUrlDetailController.m
//  UrlpokeMobile
//
//  Created by Frank Smieja on 13/12/2013.
//  Copyright (c) 2013 Smartatech. All rights reserved.
//

#import "UPUrlDetailController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "SBJson.h"
//#include "<sys/types.h>"
#import "UPGrabData.h"
#import "UPPlotViewController.h"

@interface UPUrlDetailController ()

@end

@interface UIAlertView (SPI)
- (void) addTextFieldWithValue:(NSString *) value label:(NSString *) label;
- (void) addTextFieldAtIndex:(NSUInteger) index;
- (UITextField *) textFieldAtIndex:(NSUInteger) index;
@end

@implementation UPUrlDetailController {
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Initialize table data
    urlid.delegate = self;
}


-(IBAction)GetUrlData:(id)sender {
    UPGrabData *grabData = [[UPGrabData alloc] init];
    [grabData setRemoteUrl:@"http://orion:3000/api/v1/url/get"];
    [myActivityIndicator startAnimating];
    [grabData setDelegate:self];
    [grabData GetUrlSummaryForUrlId:[thisUrlId intValue]];
}



-(void)downloadSuccessful:(BOOL)success withData:(UPGrabData *)grabData {
    [myActivityIndicator stopAnimating];
    [self populateUrlDetails:grabData.urlVals];
}

-(void)populateUrlDetails:(NSDictionary *) dict {
    
    urlName.text = [dict valueForKey:@"url"];
    thisUrlId = [dict valueForKey:@"id"];
    urlThreshold = [dict valueForKey:@"threshold"];
    urlAverage = [dict valueForKey:@"average"];
    threshold.text = [self formatStringIntegerWithThousands:urlThreshold];
    averageVal.text = [self formatStringIntegerWithThousands:urlAverage];
    latestVal.text = [self formatStringIntegerWithThousands:[dict valueForKey:@"latest_val"]];
    lastMeasured.text = [dict valueForKey:@"last_stat"];
    NSString *isDown = [dict objectForKey:@"is_down"] ;
    NSString *isOverThreshold = [dict objectForKey:@"is_over_threshold"];
    NSString *isRecentRecovered = [dict objectForKey:@"recovery"];

    errorField.text = [dict objectForKey:@"message"];
    UIColor *redColour = [UIColor redColor];
    UIColor *brownColour = [UIColor blueColor];
    UIColor *greenColour = [UIColor colorWithRed:0 green:0.5 blue:0 alpha:1];
    if ([isDown boolValue] || [isOverThreshold boolValue])
        errorField.textColor = redColour;
    else if ([isRecentRecovered boolValue])
        errorField.textColor = brownColour;
    else
        errorField.textColor = greenColour;
    urlStats = [dict objectForKey:@"stats"];
    
}

-(NSString *)formatStringIntegerWithThousands:(NSString *)numStr {
    int num = [numStr integerValue];
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior: NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
    return [numberFormatter stringFromNumber: [NSNumber numberWithInteger: num]];
}

-(IBAction)GetUrl:(id)sender{
    NSLog(@"Want to talk to URLPoke using url id %@", urlid.text);
    
    // Start request
    NSString *id = urlid.text;
    NSURL *url = [NSURL URLWithString:@"http://orion:3000/api/v1/url/get"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setShouldPresentAuthenticationDialog:TRUE];
//[useBuiltInDialog isOn]
    //	[request setPostValue: @"Username" forKey:@"username"];
//	[request setPostValue: @"Password" forKey:@"password"];
//    [request setUsername:@"admin"];
//    [request setPassword:@"secrt"];
    [request setUseKeychainPersistence:TRUE];
    [request setPostValue:id forKey:@"id"];
    [request setDelegate:self];
//    [request setDownloadProgressDelegate:myActivityIndicator];
    [myActivityIndicator startAnimating];
    [request startAsynchronous];
    
    
//    [request startSynchronous];
    //NSLog(@"Max: %f, Value: %f", [myProgressIndicator maxValue],[myProgressIndicator doubleValue]);
    
    // Hide keyword
    [urlid resignFirstResponder];
    
    // Clear text field
    urlName.text = @"";
    threshold.text = @"";

    
    //username.text = [NSString stringWithFormat:@"%s", "Any name"];
}



/*
- (void)requestFinished:(ASIHTTPRequest *)request
{
    
    if (request.responseStatusCode >= 200 && request.responseStatusCode <= 210) {
        NSString *responseString = [request responseString];
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *jsonArray = (NSDictionary *) [parser objectWithString:responseString error:nil];
        NSDictionary *userDict = [jsonArray valueForKey:@"url"];
        //NSDictionary *responseDict = [responseString JSONValue];
        //NSDictionary *userDict = [responseDict objectForKey:@"user"];
        urlName.text = [userDict objectForKey:@"url"];
        NSNumber *th = [userDict objectForKey:@"threshold"];
       // threshold.text = [NSString stringWithFormat:@"%d", th.stringValue];
        threshold.text = th.stringValue;
    } else {
        errorField.text = @"Unexpected error";
    }
    [myActivityIndicator stopAnimating];

    
}
 */
/*
- (void)authenticationNeededForRequest:(ASIHTTPRequest *)request
{
    NSLog(@"Need to implement the dialog");
    
    UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Please Login" message:[request authenticationRealm] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil] autorelease];
    // These are undocumented, use at your own risk!
    // A better general approach would be to subclass UIAlertView, or just use ASIHTTPRequest's built-in dialog
    [alertView addTextFieldWithValue:@"" label:@"Username"];
    [alertView addTextFieldWithValue:@"" label:@"Password"];
    [alertView show];

}
*/


-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
}
-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    
}
-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
}
-(void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    errorField.text = error.localizedDescription;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"Want to talk to URLPoke using %@", urlid.text);
    [textField resignFirstResponder];
    return TRUE;
}
/*
- (void)viewDidLoad
{
    [super viewDidLoad];
    urlid.delegate = self;
    // Do any additional setup after loading the view, typically from a nib.
}
 */

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
- (NSUInteger)supportedInterfaceOrientations
{
    //return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft;
    return UIInterfaceOrientationMaskLandscapeLeft;
}
*/
-(IBAction)GetUrlPlot:(id)sender
{
    UIStoryboard *sboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                     bundle:nil];
    UPPlotViewController *urlPlot = [sboard instantiateViewControllerWithIdentifier:@"idUrlPlot"];
   // [self.navigationController ]
    
    [self.navigationController pushViewController:urlPlot animated:YES];
    [urlPlot populateUrlPlot:urlStats urlName:urlName.text urlId:thisUrlId threshold:urlThreshold average:urlAverage];
    
}

// redraw on orientation change
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self viewDidLoad];
    
}


@end