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
#import "UPParseUrlData.h"


@implementation UPGrabData

-(id)init{
    self = [super init];
    _urlVals = [[NSMutableDictionary alloc] init];
    _errorText = [[NSString alloc] init];
    _urlList = [[NSHashTable alloc] init];
    _remoteUrl = @"http://orion:3000/api/v1/url/get";
    return self;
    
}

-(NSString *)GetUrlValue:(NSString *)key {
   return [self.urlVals valueForKey:key];
}

-(NSString *)GetUrlList:(NSString *)key {
    return [self.urlList valueForKey:key];
}

-(NSDictionary *)GetUrlDetails:(int)index {
    return [self.urlList objectAtIndex:index];
}
-(void)GetUrlListForUser {
    [self.urlVals removeAllObjects];
    NSLog(@"Want to talk to URLPoke to get list of urls");
    
    // Start request
    NSURL *url = [NSURL URLWithString:@"http://orion:3000/api/v1/urls"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setShouldPresentAuthenticationDialog:YES];
    request.userInfo = [NSDictionary dictionaryWithObject:@"urllist" forKey:@"type"];
    [request setUseKeychainPersistence:YES ];
    [request setDelegate:self];
    
    [request setRequestMethod:@"GET"];
    [request startAsynchronous];
}

-(void)GetUrlSummaryForUrlId:(int)urlid  {
    NSLog(@"Want to talk to URLPoke using url id %d", urlid);
    
    NSString *urlidStr = [NSString stringWithFormat:@"%d", urlid];
    // Start request
    NSURL *url = [NSURL URLWithString:@"http://orion:3000/api/v1/url/get"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    request.userInfo = [NSDictionary dictionaryWithObject:@"url" forKey:@"type"];
    [request setShouldPresentAuthenticationDialog:YES];
    [request setUseKeychainPersistence:YES];
    [request setPostValue:urlidStr forKey:@"id"];
    [request setDelegate:self];
    [request startAsynchronous];
    
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"Request finished");
    if (request.responseStatusCode >= 200 && request.responseStatusCode <= 210) {

        NSString *responseString = [request responseString];
        SBJsonParser *parser = [[SBJsonParser alloc] init];

        if ([[request.userInfo objectForKey:@"type"] isEqualToString:@"url"]) {
            self.urlVals = [parser objectWithString:responseString error:nil];
            [[self delegate] downloadSuccessful:YES withData:self];
        }
        else if ([[request.userInfo objectForKey:@"type"] isEqualToString:@"urllist"]) {
            NSDictionary *jsonArray = (NSDictionary *)[parser objectWithString:responseString error:nil];
            self.urlList = (NSArray *)jsonArray ;
//            self.urlList = [jsonArray valueForKey:@"url"];
            [[self delegate] downloadSuccessful:YES withData:self];
        }
    }
    else {
        [[self delegate] downloadSuccessful:NO withData:self];
    }

}
@end
