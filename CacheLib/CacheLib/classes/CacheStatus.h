//
//  CacheStatus.h
//  cachelib
//
//  Created by Panneerselvam, Rajkumar on 3/16/15.
//  Copyright (c) 2015 Panneerselvam, Rajkumar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

/** These constants indicate the type of file that is being represented.
 */
typedef NS_ENUM(NSInteger, FileTypeEnum) {
    /** Indicates the file types as JPEG image, used for converting
     * from and to NSData.
     */
    JPEGType,
    /** Indicates the file types as PNG image, used for converting
     * from and to NSData.
     */
    PNGType,
    /** Indicates the file types as String, used for converting
     * from and to NSData.
     */
    StringType,
    /** Indicates the file types as NSDictionary, used for converting
     * from and to NSData.
     */
    DictionaryType,
    /** Indicates the file types as NSArray, used for converting
     * from and to NSData.
     */
    ArrayType,
    /** Indicates the file types as Custom object, The object
     * should have implemented NSCoding
     */
    CustomObject
};

@interface CacheStatus : NSManagedObject

@property (nonatomic, retain) NSString        * key;
@property (nonatomic        ) FileTypeEnum    fileType;
@property (nonatomic, retain) NSDate          * expiryDate;
@property (nonatomic, retain) NSDate          * lastAccessed;

@end
