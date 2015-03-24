//
//  ViewController.h
//  cachelib
//
//  Created by Panneerselvam, Rajkumar on 3/16/15.
//  Copyright (c) 2015 Panneerselvam, Rajkumar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITextView  *contentTextView;
@property (nonatomic, weak) IBOutlet UIImageView *imageContainer;
@property (nonatomic, weak) IBOutlet UITextField *urlTextField;
@property (nonatomic, weak) IBOutlet UIButton    *loadButton;

- (IBAction)loadURL:(id)sender;

@end
