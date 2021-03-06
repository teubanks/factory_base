//
//  FactoryBase.h
//
//  Created by Tracey Eubanks on 11/16/12.
//  Copyright (c) 2012 Tracey Eubanks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FactoryBase : NSObject
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSString *entityName;
+(id)create;
+(id)build;
+(id)createWithDictionary:(NSDictionary *)entityDic;
+(id)buildWithDictionary:(NSDictionary *)entityDic;
-(id)associationWithName:(NSString*)associationName;
-(id)associationWithName:(NSString*)associationName andAttributes:(NSDictionary *)associationAttributes;
-(NSDictionary*)defaultDictionary;
@end
