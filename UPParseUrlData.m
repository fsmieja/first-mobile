//
//  UPParseUrlData.m
//  FirstWebData
//
//  Created by Frank Smieja on 19/12/2013.
//  Copyright (c) 2013 Smartatech. All rights reserved.
//

#import "UPParseUrlData.h"

@implementation UPParseUrlData

+(void)LoadDataFromJsonArray:(NSDictionary *)jsonArray intoDictionary:(NSMutableDictionary *) urlVals {
    NSString *urlVal = [jsonArray objectForKey:@"url"];
    [urlVals setValue:urlVal forKey:@"url"];
    NSNumber *threshold = [jsonArray objectForKey:@"threshold"];
    [urlVals setValue:threshold.stringValue forKey:@"threshold"];
}


@end
