//
//  ViewController.m
//  cachelib
//
//  Created by Panneerselvam, Rajkumar on 3/16/15.
//  Copyright (c) 2015 Panneerselvam, Rajkumar. All rights reserved.
//

#import "ViewController.h"
#import "cacheManager.h"
#import "SampleCustomClass.h"
#import <CocoaLumberjack/CocoaLumberjack.h>

@interface ViewController ()

@end

@implementation ViewController

# pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self createConstraints];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - Autolayout constraints

/**
 *  Create autolayout constarints
 */
- (void)createConstraints {
    
    /**
     * Call -reset the frames created in the xib.
     */
    
    [[self contentTextView] setFrame:CGRectZero];
    [[self imageContainer] setFrame:CGRectZero];
    [[self urlTextField] setFrame:CGRectZero];
    [[self loadButton] setFrame:CGRectZero];
    
    /**
     * Call -setTranslatesAutoresizingMaskIntoConstraints:NO on the views.
     */
    [[self contentTextView] setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[self imageContainer] setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[self urlTextField] setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[self loadButton] setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    /**
     * Establish constraints.
     */
    
    //  Create dictionary of views and constants that appear in the visual format
    //  string
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_contentTextView, _imageContainer, _urlTextField, _loadButton);
    
    NSDictionary *metrics         = @{
                                      @"Padding" : @30,
                                      @"scrollTextHeight" : @80,
                                      @"generalHeight" : @30,
                                      @"buttonWidth": @60
                                      };
    
    // Create constraints
    
    [[self view] addConstraints:[NSLayoutConstraint
                                 constraintsWithVisualFormat:
                                 @"V:|-(Padding)-[_contentTextView(==scrollTextHeight)]-[_imageContainer]-[_urlTextField(generalHeight)]-(Padding)-|"
                                 options:0
                                 metrics:metrics
                                 views:viewsDictionary]];
    
    [[self loadButton] addConstraint:[NSLayoutConstraint
                                   constraintWithItem:[self loadButton]
                                   attribute:NSLayoutAttributeHeight
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:nil
                                   attribute:NSLayoutAttributeNotAnAttribute
                                   multiplier:1.0
                                   constant:30.0f]];
    
    [[self view] addConstraints:[NSLayoutConstraint
                                 constraintsWithVisualFormat:@"H:|-[_contentTextView]-|"
                                 options:0
                                 metrics:nil
                                 views:viewsDictionary]];
    [[self view] addConstraints:[NSLayoutConstraint
                                 constraintsWithVisualFormat:@"H:|-[_imageContainer]-|"
                                 options:0
                                 metrics:nil
                                 views:viewsDictionary]];
    [[self view] addConstraints:[NSLayoutConstraint
                                 constraintsWithVisualFormat:@"H:|-[_urlTextField]-[_loadButton(==buttonWidth)]-|"
                                 options:NSLayoutFormatAlignAllCenterY
                                 metrics:metrics
                                 views:viewsDictionary]];
    
    
}

# pragma mark - Button deleagtes


- (IBAction)loadURL:(id)sender {
    
    DDLogInfo(@"Being Load of url");
    
    cacheManager *cacheInstance = [cacheManager sharedInstance];
    
    NSObject *cacheContent = [cacheInstance getDataForKey:[[self urlTextField] text]];
    
    if (cacheContent) {
        if ([cacheContent isKindOfClass:[NSString class]]) {
            [[self contentTextView] setText:(NSString *)cacheContent];
        }else if ([cacheContent isKindOfClass:[UIImage class]]){
            [[self imageContainer] setImage:(UIImage *)cacheContent];
        }else if ([cacheContent isKindOfClass:[NSDictionary class]]){
            NSDictionary *retirvedConent = (NSDictionary *)cacheContent;
            NSLog(@"%@",[retirvedConent allKeys]);
            
        }else if ([cacheContent isKindOfClass:[NSArray class]]){
            NSArray *retirvedConent = (NSArray *)cacheContent;
            NSLog(@"%@",retirvedConent);

        }
    }else{
        SampleCustomClass *testSample = [[SampleCustomClass alloc] init];
        [testSample setValue1:@""];
        [cacheInstance setData:testSample forKey:[[self urlTextField] text]];
        
        
//        @autoreleasepool {
//        NSString *MyURL = [[self urlTextField] text];
//        // Fetch the content and then save
//        switch ([cacheInstance extractFileType:MyURL]) {
//            case PNGType:
//            {
//                
//                NSURL *imageURL = [NSURL URLWithString:MyURL];
//                NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
//                UIImage *image = [UIImage imageWithData:imageData];
//                
//                [[self imageContainer] setImage:image];
//                [cacheInstance setData:image forKey:MyURL];
//            }
//            break;
//                
//            case JPEGType:
//            {
//                NSURL *imageURL = [NSURL URLWithString:MyURL];
//                NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
//                UIImage *image = [UIImage imageWithData:imageData];
//                
//                [[self imageContainer] setImage:image];
//                
//                [[self imageContainer] setImage:image];
//                [cacheInstance setData:image forKey:MyURL];
//            }
//            break;
//                
//            case StringType:
//            {
//                NSURL *contentURL = [NSURL URLWithString:MyURL];
//                NSData *contentData = [NSData dataWithContentsOfURL:contentURL];
//                NSString *contentValue = [[NSString alloc] initWithData:contentData encoding:NSUTF8StringEncoding];
//                
//                [[self contentTextView] setText:contentValue];
//                [cacheInstance setData:contentValue forKey:MyURL];
//            }
//                break;
//            default:
//            {
//        
//            }
//
//            break;
//        }
//        }
    }
    
    DDLogInfo(@"End Load of url");
}


@end
