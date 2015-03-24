//
//  SampleCustomClass.h
//  cachelib
//
//  Created by Panneerselvam, Rajkumar on 3/24/15.
//  Copyright (c) 2015 Panneerselvam, Rajkumar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SampleCustomClass : NSObject <NSCoding>

@property (nonatomic, retain) NSString * value1;
@property (nonatomic, retain) NSNumber * value2;
@property (nonatomic, retain) NSDate * value3;
@property (nonatomic, retain) NSMutableDictionary * value4;
@property (nonatomic, retain) NSMutableArray * value5;

@end
