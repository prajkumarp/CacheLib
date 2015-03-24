//
//  CacheStatus.h
//  cachelib
//
//  Created by Panneerselvam, Rajkumar on 3/16/15.
//  Copyright (c) 2015 Panneerselvam, Rajkumar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef NS_ENUM(NSInteger, FileTypeEnum) {
    JPEGType,
    PNGType ,
    StringType,
    DictionaryType,
    ArrayType,
    CustomObject
};

@interface CacheStatus : NSManagedObject

@property (nonatomic, retain) NSString * key;
@property (nonatomic) FileTypeEnum fileType;
@property (nonatomic, retain) NSDate * expiryDate;
@property (nonatomic, retain) NSDate * lastAccessed;

@end
