//
//  SampleCustomClass.m
//  cachelib
//
//  Created by Panneerselvam, Rajkumar on 3/24/15.
//  Copyright (c) 2015 Panneerselvam, Rajkumar. All rights reserved.
//

#import "SampleCustomClass.h"

@implementation SampleCustomClass

@synthesize value1;
@synthesize value2;
@synthesize value3;
@synthesize value4;
@synthesize value5;


- (instancetype)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        [self setValue1:[decoder decodeObjectForKey:@"value1"]];
        [self setValue2:[decoder decodeObjectForKey:@"value2"]];
        [self setValue3:[decoder decodeObjectForKey:@"value3"]];
        [self setValue4:[decoder decodeObjectForKey:@"value4"]];
        [self setValue5:[decoder decodeObjectForKey:@"value5"]];

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:[self value1] forKey:@"value1"];
    [encoder encodeObject:[self value2] forKey:@"value2"];
    [encoder encodeObject:[self value3] forKey:@"value3"];
    [encoder encodeObject:[self value4] forKey:@"value4"];
    [encoder encodeObject:[self value5] forKey:@"value5"];
}


@end
