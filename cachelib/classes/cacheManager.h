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

/**
 *  Returns the shared `cacheManager` instance, creating it if necessary.
 *
 *  @return The shared `cacheManager` instance.
 */
+ (instancetype)sharedInstance;

/**-----------------------------------------------------------------------------
 * @name Store object in cache
 * -----------------------------------------------------------------------------
 */

/** Store object in cache without expiry
 *
 *  Sets the property of the receiver specified by a given key to a given
 *object.
 *
 *  @param anObject The value for the object identified by key.
 *  @param aKey     The value of the key for the object identified.
 */
- (void)setData:(id)object forKey:(NSString *)key;

/**
 *  Sets the property of the receiver specified by a given key to a given
 *object.
 *
 *  @param anObject The value for the object identified by key.
 *  @param aKey     The value of the key for the object identified.
 *  @param date     The expiry time for the object associated with the key
 */
- (void)setData:(id)object forKey:(NSString *)key withExpiryDate:(NSDate *)date;

/**-----------------------------------------------------------------------------
 * @name Retrive object from cache
 * -----------------------------------------------------------------------------
 */

/** Retrive object from cache
 *  Retrive object from cache based on the key
 *
 *  @param aKey The value of the key for the object to be retrived.
 *
 *  @return The object for the key, will return nill in the object does
 *  does not exist
 */
- (id)getDataForKey:(NSString *)aKey;

- (void)removeAllDataOlderThan:(NSDate *)date;
- (BOOL)checkIfObjectExistforKey:(NSString *)aKey;
- (FileTypeEnum)extractFileType:(NSString *)url;

#pragma mark - Properties

@property(nonatomic, retain) NSNumber *timeToLive;
@property(nonatomic, retain) NSNumber *expiryTimeforPurging;

@end
