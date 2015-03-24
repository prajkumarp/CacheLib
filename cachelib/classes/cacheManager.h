//
//  cacheManager.h
//  cachelib
//
//  Created by Panneerselvam, Rajkumar on 3/16/15.
//  Copyright (c) 2015 Panneerselvam, Rajkumar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CacheStatus.h"

@interface cacheManager : NSObject


+ (instancetype)sharedInstance;

- (void)setData:(id)anObject forKey:(NSString *)aKey;
- (id)getDataForKey:(NSString *)aKey;
- (void)setData:(id)anObject forKey:(NSString *)aKey withExpiryDate:(NSDate *)date;

- (void)removeAllDataOlderThan:(NSDate *)date;
- (BOOL)checkIfObjectExistforKey:(NSString *)aKey;
- (FileTypeEnum)extractFileType:(NSString *)url;

@property (nonatomic,retain) NSNumber *timeToLive;
@property (nonatomic,retain) NSNumber *expiryTimeforPurging;

@end
