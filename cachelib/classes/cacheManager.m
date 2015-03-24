//
//  cacheManager.m
//  cachelib
//
//  Created by Panneerselvam, Rajkumar on 3/16/15.
//  Copyright (c) 2015 Panneerselvam, Rajkumar. All rights reserved.
//

#import "cacheManager.h"
#import "TMCache.h"
#import "RNEncryptor.h"
#import "RNDecryptor.h"
#import "NSString+MD5.h"
#import "CocoaLumberjack.h"
#import <CommonCrypto/CommonDigest.h>
#import <UIKit/UIImage.h>
#import "AppDelegate.h"


static NSString *const kEncryptPassword = @"goodPassword";

@interface cacheManager(){
    NSData *dataFromCache;
}

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;


- (void)saveContext;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSURL *applicationDocumentsDirectory;

@end




@implementation cacheManager

@synthesize expiryTimeforPurging;
@synthesize  timeToLive;

+ (cacheManager *)sharedInstance{
    static cacheManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[cacheManager alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setTimeToLive:@(60 * 60 * 24 * 365 * 5)];// 60 (Seconds) * 60 (Minutes) * 24 (Hours) * 365 (Days) * 5 (Years)
        [self setExpiryTimeforPurging:@(60 * 60 * 24 * 365 * 5)];// 60 (Seconds) * 60 (Minutes) * 24 (Hours) * 30 (Days)
    }
    return self;
}

- (void)dealloc{
    [self saveContext];
}

- (void)setData:(id)anObject forKey:(NSString *)aKey{
    [self setData:anObject forKey:aKey withExpiryDate:nil];
}

- (id)getDataForKey:(NSString *)aKey{
    
    
    
    //    Get the hash ecryption for the key
    NSString *hashKey = [self hashString:aKey];
    
    //    Call if check if object exist
    CacheStatus *lookupCacheInfo = [self getFromCacheLookupByKey:hashKey];
    
    if (lookupCacheInfo) {
        
        if (([[lookupCacheInfo expiryDate] compare:[NSDate new]] == NSOrderedAscending)) {
            // The cache has expired
            [self removeAllDataOlderThan:[lookupCacheInfo expiryDate]];
            [self removeStaleData];
            return nil;
            
        }else{
            
            // Get from TMCache
            dataFromCache = [[TMCache sharedCache] objectForKey:hashKey];
            
            // Decrypt nsdata
            
            NSError *error;
            
            NSData *decryptedData = [RNDecryptor decryptData:dataFromCache
                                                withPassword:kEncryptPassword
                                                       error:&error];
            //  type cast nsdata to the data type
            
            switch ([lookupCacheInfo fileType]) {
                case PNGType:
                {
                    UIImage *returnImage = [UIImage imageWithData:decryptedData];
                    return returnImage;
                }
                    break;
                    
                case JPEGType:
                {
                    UIImage *returnImage = [UIImage imageWithData:decryptedData];
                    return returnImage;
                }
                    break;
                    
                case DictionaryType:
                {
                    NSDictionary *returnDictionary = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:decryptedData];
                    return returnDictionary;
                }
                    break;
                    
                case ArrayType:
                {
                    NSArray *returnArray = (NSArray *)[NSKeyedUnarchiver unarchiveObjectWithData:decryptedData];
                    return returnArray;
                }
                    break;
                case StringType:
                {
                    return [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
                }
                    break;

                    
                default:
                {
                    NSObject *returnObject = [NSKeyedUnarchiver unarchiveObjectWithData:decryptedData];
                    return returnObject;
                }
                    break;
            }
        }
        
    }else{
        //  Data does not exist in the lookup, most likely not available in the persistent storage
        return nil;
    }
    
    return nil;
}

- (void)setData:(id)anObject forKey:(NSString *)aKey withExpiryDate:(NSDate *)date{
    
    FileTypeEnum dataTypeValue = CustomObject;
    if ([anObject isKindOfClass:[UIImage class]]) {
        //    Get the file type from key
        dataTypeValue = [self extractFileType:aKey];
    }else if (([anObject isKindOfClass:[NSMutableDictionary class]]) || ([anObject isKindOfClass:[NSDictionary class]])){
        dataTypeValue = DictionaryType;
    }else if (([anObject isKindOfClass:[NSMutableArray class]]) || ([anObject isKindOfClass:[NSArray class]])){
        dataTypeValue = ArrayType;
    }else if ([anObject isKindOfClass:[NSString class]]){
        dataTypeValue = StringType;
    }
    
    // Check for the validity of date
    if ((!date) || ([date compare:[NSDate new]] == NSOrderedAscending)) {
        NSTimeInterval _timeToLive = [[self timeToLive] doubleValue];
        date = [[NSDate date] dateByAddingTimeInterval:_timeToLive];
    }
    
    //    Get the hash ecryption for the key
    NSString *hashKey = [self hashString:aKey];
    
    //    Get data encryption for the object using RNEncryptor.h with password
    NSData *encryptedData = [self encryptintoData:anObject dataType:dataTypeValue];
    
    //    Put the key and object in to cache using TMCache.h
    [[TMCache sharedCache] setObject:encryptedData forKey:hashKey];
    
    //    Update the records in the core data
    [self addToCacheLookup:hashKey fileType:dataTypeValue expiryDate:date];
}

//TODO:removeAllDataOlderThan
- (void)removeAllDataOlderThan:(NSDate *)date{
    
    //  Get md5 hash keys from core data
    //    deelete the files from TMCache
    
    
}

//TODO:removeStaleData
- (void)removeStaleData{
    
}

- (BOOL)checkIfObjectExistforKey:(NSString *)aKey{
    return NO;
}

# pragma mark - Private methods

-(FileTypeEnum)extractFileType:(NSString *)url{
    
    NSString *extension = [url pathExtension];
    
    FileTypeEnum dataTypeValue = StringType;
    
    if (([[extension uppercaseString] isEqualToString:@"JPEG"])||([[extension uppercaseString] isEqualToString:@"JPG"])) {
        dataTypeValue = JPEGType;
    }else if ([[extension uppercaseString] isEqualToString:@"PNG"]){
        dataTypeValue = PNGType;
    }
    
    return dataTypeValue;
}

- (NSString *)hashString:(NSString *)string{
    
    NSString *encodedString = [self encodedString:string];
    return  [encodedString MD5String];
    
}

- (NSString *)encodedString:(NSString *)string{
    if (![string length])
        return @"";
    
    CFStringRef static const charsToEscape = CFSTR(".:/");
    CFStringRef escapedString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                        (__bridge CFStringRef)string,
                                                                        NULL,
                                                                        charsToEscape,
                                                                        kCFStringEncodingUTF8);
    return (__bridge_transfer NSString *)escapedString;
}

- (NSData *)encryptintoData:(NSObject *)anObject dataType:(FileTypeEnum)dataTypeValue{
    NSData *data;
    
    switch (dataTypeValue) {
        case JPEGType:
            data = UIImageJPEGRepresentation((UIImage *)anObject, 1.0);
            break;
        case PNGType:
            data = UIImagePNGRepresentation((UIImage *)anObject);
            break;
        case DictionaryType:
            data = [NSKeyedArchiver archivedDataWithRootObject:anObject];
            break;
        case ArrayType:
            data = [NSKeyedArchiver archivedDataWithRootObject:anObject];
            break;
        case StringType:
            data = [(NSString *)anObject dataUsingEncoding:NSUTF8StringEncoding];
            break;
        default:
            data = [NSKeyedArchiver archivedDataWithRootObject:anObject];
            break;
    }
    
    NSError *error;
    NSData *encryptedData = [RNEncryptor encryptData:data
                                        withSettings:kRNCryptorAES256Settings
                                            password:kEncryptPassword
                                               error:&error];
    //    DDLogError(@"Encription Fail %@",[error description]);
    
    return encryptedData;
    
}

# pragma mark - Core Data methods

- (void)addToCacheLookup:(NSString *)key fileType:(FileTypeEnum)fileType expiryDate:(NSDate *)date{
    
    NSManagedObjectContext *context = [self managedObjectContext];
    CacheStatus *cacheInformation = [NSEntityDescription
                                     insertNewObjectForEntityForName:@"CacheStatus"
                                     inManagedObjectContext:context];
    [cacheInformation setKey:key];
    [cacheInformation setExpiryDate:date];
    [cacheInformation setLastAccessed:[[NSDate alloc] init]];
    [cacheInformation setFileType:fileType];
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

- (CacheStatus *)getFromCacheLookupByKey:(NSString *)key{
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CacheStatus"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *keyPredicate = [NSPredicate predicateWithFormat:@"key = %@",key];
    [fetchRequest setPredicate:keyPredicate];
    
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    CacheStatus *returnData;
    
    if ([fetchedObjects count]>0) {
        returnData = fetchedObjects[0];
    }
    
    return returnData;
}

- (void)getFromCacheLookupByFileType:(NSString *)fileType{
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CacheStatus"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    for (CacheStatus *cacheInformation in fetchedObjects) {
        NSLog(@"Name: %@", cacheInformation.key);
    }
}

- (void)getCacheWithExpiryDateLessThan:(NSDate *)expiryDate{
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CacheStatus"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    for (CacheStatus *cacheInformation in fetchedObjects) {
        NSLog(@"Name: %@", cacheInformation.key);
    }
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "test.cachelib" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"cachelib" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"cachelib.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


@end
