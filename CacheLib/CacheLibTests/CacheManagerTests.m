//
//  CacheManagerTests.m
//  CacheLib
//
//  Created by Panneerselvam, Rajkumar on 3/24/15.
//  Copyright (c) 2015 Panneerselvam, Rajkumar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "cacheManager.h"
#import "CacheStatus.h"

@interface CacheManagerTests : XCTestCase

@property (nonatomic, strong) cacheManager *cacheManagerInstance;
@property (nonatomic, strong) NSDate *expiryDate;
@end

#define AssertEqualDictionaries(d1, d2) \
do { \
[self assertDictionary:d1 isEqualToDictionary:d2 name1:#d1 name2:#d2 failureRecorder:NewFailureRecorder()]; \
} while (0)



@interface cacheManager(UnitTests){
    
}
- (void)addToCacheLookup:(NSString *)key fileType:(FileTypeEnum)fileType expiryDate:(NSDate *)date;
- (CacheStatus *)getFromCacheLookupByKey:(NSString *)key;
- (NSArray *)getFromCacheLookupByFileType:(FileTypeEnum)fileType;
- (NSArray *)getCacheWithExpiryDateLessThan:(NSDate *)expiryDate;
- (void)deleteAllEntities;

@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;

@end

@implementation CacheManagerTests

# pragma mark - Boiler plate code

- (void)setUp {
    [super  setUp];
    
    if(!_expiryDate){
        NSString *dateString = @"03-Feb-15";
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"dd-MMM-yy";
        [self setExpiryDate:[dateFormatter dateFromString:dateString]];
    }
    
    [self   setCacheManagerInstance:[cacheManager sharedInstance]];
    
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"L-Brands.CacheLib"];
    NSURL *url = [bundle URLForResource:@"cachelib" withExtension:@"momd"];
    _cacheManagerInstance.managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:url];
}

- (void)populateTestData{
    [_cacheManagerInstance addToCacheLookup:@"String Entry"     fileType:StringType         expiryDate:_expiryDate];
    [_cacheManagerInstance addToCacheLookup:@"Jpeg Entry"       fileType:JPEGType           expiryDate:_expiryDate];
    [_cacheManagerInstance addToCacheLookup:@"Png Entry"        fileType:PNGType            expiryDate:_expiryDate];
    [_cacheManagerInstance addToCacheLookup:@"Dictionary Entry" fileType:DictionaryType     expiryDate:_expiryDate];
    [_cacheManagerInstance addToCacheLookup:@"Array Entry"      fileType:ArrayType          expiryDate:_expiryDate];
    [_cacheManagerInstance addToCacheLookup:@"Object Entry"     fileType:CustomObjectType   expiryDate:_expiryDate];
}

- (void)deleteTestData{
    [_cacheManagerInstance deleteAllEntities];
}

- (void)tearDown {
    [self   setCacheManagerInstance:nil];
    [super tearDown];
}

# pragma mark - Testing cache lookup index with core data

- (void)testStoringandRetrivingFromCoreData{
    
    [self populateTestData];
    CacheStatus *retrivedData = [_cacheManagerInstance getFromCacheLookupByKey:@"String Entry"];
    XCTAssertNotNil(retrivedData,@"Data should exist after populating data");
    [self deleteTestData];
    retrivedData = [_cacheManagerInstance getFromCacheLookupByKey:@"String Entry"];
    XCTAssertNil(retrivedData,@"Data should not exist after deleting data");
}

-(void)testgetFromCacheLookupByKey{
    
    [self deleteTestData];
    [self   populateTestData];
    
    CacheStatus *retrivedData = [_cacheManagerInstance getFromCacheLookupByKey:@"String Entry"];
    XCTAssertNotNil(retrivedData,@"Did not receive data");
    XCTAssertTrue([[retrivedData key]isEqualToString:@"String Entry"],@"Did not match with the key");
    XCTAssertEqual([retrivedData fileType], StringType,@"Did not match the File type");
    XCTAssertEqual([[retrivedData expiryDate] timeIntervalSince1970], [[self expiryDate] timeIntervalSince1970],@"Did not match expiry time");
}

-(void)testgetFromCacheLookupByFileType{
    
    [self deleteTestData];
    [self   populateTestData];
    
    NSArray *retrivedDataCollection = [_cacheManagerInstance getFromCacheLookupByFileType:StringType];
    XCTAssertNotNil(retrivedDataCollection,@"Did not receive data");
    XCTAssertTrue([retrivedDataCollection count] == 1,@"Number of fetched objects does not match");
    
    CacheStatus *retrivedData = retrivedDataCollection[0];
    XCTAssertTrue([[retrivedData key]isEqualToString:@"String Entry"],@"Did not match with the key");
    XCTAssertEqual([retrivedData fileType], StringType,@"Did not match the File type");
    XCTAssertEqual([[retrivedData expiryDate] timeIntervalSince1970], [[self expiryDate] timeIntervalSince1970],@"Did not match expiry time");
}

-(void)testgetCacheWithExpiryDateLessThan{
    
    [self deleteTestData];
    [self   populateTestData];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd-MMM-yy";
    
//    Expiry Date : 03-Feb-15

    NSDate *dateLessthanExpiry    = [dateFormatter dateFromString:@"01-Feb-15"];
    NSDate *dateGreaterthanExpiry = [dateFormatter dateFromString:@"05-Feb-15"];

    NSArray *retrivedDataCollectionforpastExpiry = [_cacheManagerInstance getCacheWithExpiryDateLessThan:dateLessthanExpiry];
    XCTAssertNotNil(retrivedDataCollectionforpastExpiry,@"Did not receive data");
    XCTAssertTrue([retrivedDataCollectionforpastExpiry count] == 0,@"Number of fetched objects does not match");
    
    NSArray *retrivedDataCollectionforFutureExpiry = [_cacheManagerInstance getCacheWithExpiryDateLessThan:dateGreaterthanExpiry];
    XCTAssertNotNil(retrivedDataCollectionforFutureExpiry,@"Did not receive data");
    XCTAssertTrue([retrivedDataCollectionforFutureExpiry count] == 6,@"Number of fetched objects does not match");

}



//# pragma mark - Testing cache storing and retriving

- (void)testCachingandRetrivingString{
    [self deleteTestData];
    
    NSString *testDataForChecking = @"Test String";
    
    [[self cacheManagerInstance] setData:testDataForChecking forKey:@"Test"];
    
    NSString *retrivedData = [[self cacheManagerInstance] getDataForKey:@"Test"];
    
    XCTAssertNotNil(retrivedData,@"Did not fetch");
    XCTAssertTrue([retrivedData isEqualToString:testDataForChecking],@"Did not match with the data");
}

- (void)testCachingandRetrivingDictionary{
    [self deleteTestData];
    
    NSDictionary *testDataForChecking = @{ @"Key 1" : @"Value 1", @"Key 2" : @"Value 2", @"Key 3" : @"Value 3" };
    
    [[self cacheManagerInstance] setData:testDataForChecking forKey:@"Test"];
    
    NSDictionary *retrivedData = [[self cacheManagerInstance] getDataForKey:@"Test"];
    
    XCTAssertNotNil(retrivedData,@"Did not fetch");
    XCTAssertEqualObjects(testDataForChecking, retrivedData, @"Data did not match");
}

- (void)testCachingandRetrivingArray{
    [self deleteTestData];
    
    NSArray *testDataForChecking = @[ @"Value1", @"Value2", @"Value3"];
    
    [[self cacheManagerInstance] setData:testDataForChecking forKey:@"Test"];
    
    NSArray *retrivedData = [[self cacheManagerInstance] getDataForKey:@"Test"];
    
    XCTAssertNotNil(retrivedData,@"Did not fetch");
    XCTAssertEqualObjects(testDataForChecking, retrivedData, @"Data did not match");
}

- (void)testCachingandRetrivingImageJpeg{
    
    [self deleteTestData];
    
    NSString* jpgImagePath = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"jpegTest.jpg"];
    UIImage* testJpegImage = [UIImage imageWithContentsOfFile:jpgImagePath];
    
    NSString* pngImagePath = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"pngTest.png"];
    UIImage* testPngImage = [UIImage imageWithContentsOfFile:pngImagePath];
    
    [[self cacheManagerInstance] setData:testJpegImage forKey:@"jpegTest.jpg"];
    
    UIImage *retrivedImage = [[self cacheManagerInstance] getDataForKey:@"jpegTest.jpg"];
    
    XCTAssertNotNil(retrivedImage,@"Did not fetch");
    XCTAssertTrue(CGSizeEqualToSize(testJpegImage.size,retrivedImage.size),@"Data did not match");
    XCTAssertFalse(CGSizeEqualToSize(testPngImage.size,retrivedImage.size),@"Incorrect data retrived");
}

- (void)testCachingandRetrivingImagePNG{
    
    [self deleteTestData];
    
    NSString* jpgImagePath = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"jpegTest.jpg"];
    UIImage* testJpegImage = [UIImage imageWithContentsOfFile:jpgImagePath];
    
    NSString* pngImagePath = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"pngTest.png"];
    UIImage* testPngImage = [UIImage imageWithContentsOfFile:pngImagePath];
    
    [[self cacheManagerInstance] setData:testPngImage forKey:@"pngTest.png"];
    
    UIImage *retrivedImage = [[self cacheManagerInstance] getDataForKey:@"pngTest.png"];
    
    XCTAssertNotNil(retrivedImage,@"Did not fetch");
    XCTAssertTrue(CGSizeEqualToSize(testPngImage.size,retrivedImage.size),@"Data did not match");
    XCTAssertFalse(CGSizeEqualToSize(testJpegImage.size,retrivedImage.size),@"Incorrect data retrived");
}

//- (void)testCachingandRetrivingCustomObject{
//     XCTAssert(NO, @"To be implemented");
//}
//
//# pragma mark - Testing removng from cache
//
//- (void)testRemovingAllDataOlderThanaGivenDate{
//     XCTAssert(NO, @"To be implemented");
//}
//
//- (void)testRemoveStaleData{
//     XCTAssert(NO, @"To be implemented");
//}
//
//# pragma mark - Testing utility methods
//
//- (void)testCheckingTheValidityoftheKey{
//     XCTAssert(NO, @"To be implemented");
//}
//
//- (void)testExtractingFiletypeBasedonURL{
//     XCTAssert(NO, @"To be implemented");
//}
//
//- (void)testHashEncodingandDecodingofString{
//    XCTAssert(NO, @"To be implemented");
//}

//# pragma mark - Pre populated
////TODO: Remove
//- (void)testExample {
//    // This is an example of a functional test case.
//    XCTAssert(YES, @"Pass");
//}
//
//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
