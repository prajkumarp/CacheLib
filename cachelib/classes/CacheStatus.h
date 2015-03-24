//
//  CacheStatus.h
//  cachelib
//
//  Created by Panneerselvam, Rajkumar on 3/16/15.
//  Copyright (c) 2015 Panneerselvam, Rajkumar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef enum dataTypesEnum : int16_t {
    JPEGType = 0,
    PNGType = 1,
    StringType = 2,
    DictionaryType = 3,
    ArrayType = 4,
    CustomObject = 5
} fileTypeEnum;

@interface CacheStatus : NSManagedObject

@property (nonatomic, retain) NSString * key;
@property (nonatomic) fileTypeEnum fileType;
@property (nonatomic, retain) NSDate * expiryDate;
@property (nonatomic, retain) NSDate * lastAccessed;

@end
