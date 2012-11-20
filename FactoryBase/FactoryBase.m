//
//  FactoryBase.m
//
//  Created by Tracey Eubanks on 11/16/12.
//  Copyright (c) 2012 Tracey Eubanks. All rights reserved.
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
//
//  This class expects a class called DataSupport to be defined with a class method
//  named mainManagedObjectContext that returns an NSManagedObjectContext

#import "NSDictionary+Merge.h"
#import "FactoryBase.h"
@interface FactoryBase()

@end

@implementation FactoryBase
-(id)init {
    self = [super init];

    Class dataSupportClass = [[self class] classFromString:@"DataSupport"];
    SEL mainContextSel = @selector(mainManagedObjectContext);
    if([dataSupportClass respondsToSelector:mainContextSel]) {
        self.context = [dataSupportClass performSelector:mainContextSel];
    } else {
        [NSException raise:@"Selector mainManagedObjectContext for class DataSupport not defined" format:@"Expected %@ to be defined on class DataSupport", NSStringFromSelector(mainContextSel)];
    }
    return self;
}

-(NSString*)entityName {
    NSString *classAsString = NSStringFromClass([self class]);
    return [classAsString substringToIndex:[classAsString length] - [@"Factory" length]];
}

#pragma mark Public Methods
+(id)create {
    id localInstance = [[self alloc] init];
    return [localInstance create];
}

+(id)build {
    id localInstance = [[self alloc] init];
    return [localInstance build];
}

+(id)createWithDictionary:(NSDictionary *)entityDic {
    id localInstance = [[self alloc] init];
    return [localInstance createWithDictionary:entityDic];
}

+(id)buildWithDictionary:(NSDictionary *)entityDic {
    id localInstance = [[self alloc] init];
    return [localInstance buildWithDictionary:entityDic];
}

#pragma mark Private Instance Methods
-(id)create {
    id newEntity = [self buildEntityForName:self.entityName withDictionary:nil];
    __block NSError *saveError = nil;
    [self.context performBlock:^{
        [self.context save:&saveError];
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
    [self.context performBlock:^{
        [self.context save:&saveError];
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
    id associationFactory = [[self class] classFromString:associationFactoryName];
    return [associationFactory create];
}

-(id)associationWithName:(NSString*)associationName andAttributes:(NSDictionary *)associationAttributes {
    NSString *associationFactoryName = [NSString stringWithFormat:@"%@Factory", associationName];
    id associationFactory = [[self class] classFromString:associationFactoryName];
    return [associationFactory createWithDictionary:associationAttributes];
}

#pragma mark Utility Methods
+(Class)classFromString:(NSString*)className {
    Class expectedClass = NSClassFromString(className);
    if(!expectedClass) {
        [NSException raise:@"Class not found" format:@"Expected %@ to be defined", className];
    }
    return expectedClass;
}

#pragma mark Core Methods
-(id)buildEntityForName:(NSString *)entityName withDictionary:(NSDictionary *)entityDic {
    NSDictionary *fullDictionary = [self defaultDictionary];
    if(entityDic != nil) {
        fullDictionary = [fullDictionary dictionaryByMergingWith:entityDic];
    }
    __block NSEntityDescription *entityDesc = nil;
    [self.context performBlockAndWait:^{
        entityDesc = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.context];
    }];

    [fullDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [entityDesc setValue:obj forKey:key];
    }];

    return entityDesc;
}

-(NSDictionary *)defaultDictionary {
    return @{};
}
@end
