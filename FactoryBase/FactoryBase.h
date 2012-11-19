//
//  FactoryBase.h
//  Finance
//
//  Created by Tracey Eubanks on 11/16/12.
//  Copyright (c) 2012 DataReef. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FactoryBase : NSObject
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSString *entityName;
+(id)create;
+(id)build;
+(id)createWithDictionary:(NSDictionary *)entityDic;
+(id)buildWithDictionary:(NSDictionary *)entityDic;
@end
