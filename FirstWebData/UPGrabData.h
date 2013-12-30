//
//  UPGrabData.h
//  FirstWebData
//
//  Created by Frank Smieja on 17/12/2013.
//  Copyright (c) 2013 Smartatech. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UPGrabData;

@protocol ProcessDataDelegate <NSObject>
@required
- (void) downloadSuccessful: (BOOL)success withData:(UPGrabData *)data;
@end

@interface UPGrabData : NSObject {
    id <ProcessDataDelegate> delegate;
}

@property (copy) NSString *remoteUrl;
@property (copy) NSMutableDictionary *urlVals;
@property (copy) NSArray *urlList;
@property (copy) NSString *errorText;
@property (copy) NSDictionary *jsonArray;
@property (retain) id delegate;
@property (copy) NSString *requestType;
@property (copy) NSMutableArray *urlPoints;

-(void)GetUrlSummaryForUrlId:(int)urlid;
-(void)GetUrlListForUser;
-(NSString *)GetUrlValue:(NSString *)key;
-(NSDictionary *)GetUrlDetails:(int)index;
-(NSString *)GetUrlList:(NSString *)key;
@end

