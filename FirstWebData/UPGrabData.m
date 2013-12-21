//
//  UPGrabData.m
//  FirstWebData
//
//  Created by Frank Smieja on 17/12/2013.
//  Copyright (c) 2013 Smartatech. All rights reserved.
//

#import "UPGrabData.h"
#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"
#import "SBJson.h"
#import "OAuthConsumer.h"
#import "UPParseUrlData.h"


@implementation UPGrabData

-(id)init{
    self = [super init];
    _urlVals = [[NSMutableDictionary alloc] init];
    _errorText = [[NSString alloc] init];
    _remoteUrl = @"http://orion:3000/api/v1/url/get";
    return self;
    
}

-(NSString *)GetUrlValue:(NSString *)key {
   return [self.urlVals valueForKey:key];
}


-(void)GetUrlSummaryForUrlId:(int)urlid {
    NSLog(@"Want to talk to URLPoke using url id %d", urlid);
    
    NSString *urlidStr = [NSString stringWithFormat:@"%d", urlid];
    // Start request
    NSURL *url = [NSURL URLWithString:_remoteUrl];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setShouldPresentAuthenticationDialog:YES];
    [request setUseKeychainPersistence:YES];
    [request setPostValue:urlidStr forKey:@"id"];
    [request setDelegate:self];
    [request startAsynchronous];
    
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    
    if (request.responseStatusCode >= 200 && request.responseStatusCode <= 210) {
        
        NSString *responseString = [request responseString];
        SBJsonParser *parser = [[SBJsonParser alloc] init];

        self.urlVals = [parser objectWithString:responseString error:nil];
        [[self delegate] downloadSuccessful:YES withData:self];
 //       NSDictionary *jsonArray = [parser objectWithString:responseString error:nil];
 //       self.urlVals = [jsonArray valueForKey:@"url"];

    }
    else {
        self.errorText = @"Unexpected error";
    }
}
@end
