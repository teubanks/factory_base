//
//  FactoryBase.m
//  Finance
//
//  Created by Tracey Eubanks on 11/16/12.
//  Copyright (c) 2012 MoneyDesktop. All rights reserved.
//
//  FactoryBase provides a way to dynamically create entities based on
//  information provided by the defaultDictionary instance method.
//
//  Subclasses must have their names prefixed with the entity name (eg, UserFactory
//  for a User entity). FactoryBase dynamically discovers the entity name based
//  on its class name.
//
//  FactoryBase allows for overriding the existing default dictionary by passing
//  a custom dictionary to the createWithDictionary or buildWithDictionary methods
//
//  Custom dictionaries and the defaultDictionary are merged, removing the need to
//  pass in all keys along with custom overrides

#import "NSDictionary+Merge.h"
#import "FactoryBase.h"
static FactoryBase *_localInstance;
@interface FactoryBase()

@end

@implementation FactoryBase
+(void)initialize {
    _localInstance = [[self alloc] init];

    Class dataSupportClass = NSClassFromString(@"DataSupport");
    if(!dataSupportClass) {
        [NSException raise:@"Expected DataSupport class to be defined" format:@""];
    }
    SEL mainContextSel = @selector(mainManagedObjectContext);
    if([dataSupportClass respondsToSelector:mainContextSel]) {
        _localInstance.context = [dataSupportClass performSelector:mainContextSel];
    } else {
        [NSException raise:@"Selector mainManagedObjectContext for class DataSupport not defined" format:@"Expected %@ to be defined on class DataSupport", NSStringFromSelector(mainContextSel)];
    }
}

-(NSString*)entityName {
    NSString *classAsString = NSStringFromClass([self class]);
    return [classAsString substringToIndex:[classAsString length] - [@"Factory" length]];
}

#pragma mark Public Methods
+(id)create {
    return [_localInstance create];
}

+(id)build {
    return [_localInstance build];
}

+(id)createWithDictionary:(NSDictionary *)entityDic {
    return [_localInstance createWithDictionary:entityDic];
}

+(id)buildWithDictionary:(NSDictionary *)entityDic {
    return [_localInstance buildWithDictionary:entityDic];
}

#pragma mark Private Instance Methods
-(id)create {
    id newEntity = [self buildEntityForName:self.entityName withDictionary:nil];
    __block NSError *saveError = nil;
    [[self context] performBlock:^{
        [[self context] save:&saveError];
    }];
    assert(saveError == nil);
    return newEntity;
}

-(id)build {
    id newEntity = [self buildEntityForName:self.entityName withDictionary:nil];
    return newEntity;
}

-(id)createWithDictionary:(NSDictionary *)entityDic {
    id newEntity = [self buildEntityForName:self.entityName withDictionary:entityDic];
    __block NSError *saveError = nil;
    [[self context] performBlock:^{
        [[self context] save:&saveError];
    }];
    assert(saveError == nil);
    return newEntity;
}

-(id)buildWithDictionary:(NSDictionary *)entityDic {
    id newEntity = [self buildEntityForName:self.entityName withDictionary:entityDic];
    return newEntity;
}

-(id)associationWithName:(NSString*)associationName {
    NSString *associationFactoryName = [NSString stringWithFormat:@"%@Factory", associationName];
    id associationFactory = NSClassFromString(associationFactoryName);
    return [associationFactory create];
}

-(id)associationWithName:(NSString*)associationName andAttributes:(NSDictionary *)associationAttributes {
    NSString *associationFactoryName = [NSString stringWithFormat:@"%@Factory", associationName];
    id associationFactory = NSClassFromString(associationFactoryName);
    return [associationFactory createWithDictionary:associationAttributes];
}

#pragma mark Core Methods
-(id)buildEntityForName:(NSString *)entityName withDictionary:(NSDictionary *)entityDic {
    NSDictionary *fullDictionary = [self defaultDictionary];
    if(entityDic != nil) {
        fullDictionary = [fullDictionary dictionaryByMergingWith:entityDic];
    }
    NSEntityDescription *entityDesc = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.context];

    [fullDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [entityDesc setValue:obj forKey:key];
    }];

    return entityDesc;
}

-(NSDictionary *)defaultDictionary {
    return @{};
}
@end
