//
//  NSDictionary+Merge.h
//
//  Created by Tracey Eubanks on 11/16/12.
//  Copyright (c) 2012 Tracey Eubanks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Merge)
+ (NSDictionary *) dictionaryByMerging: (NSDictionary *) dict1 with: (NSDictionary *) dict2;
- (NSDictionary *) dictionaryByMergingWith: (NSDictionary *) dict;
@end
