//
//  UPParseUrlData.h
//  FirstWebData
//
//  Created by Frank Smieja on 19/12/2013.
//  Copyright (c) 2013 Smartatech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UPParseUrlData : NSObject


+(void)LoadDataFromJsonArray:(NSDictionary *)jsonArray intoDictionary:(NSMutableDictionary *)urlVals;

@end
