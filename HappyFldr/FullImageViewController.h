//
//  FullImageViewController.h
//  HappyFldr
//
//  Created by Alec Kretch on 6/30/14.
//  Copyright (c) 2014 Alec Kretch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>

@class FullImageViewController;
@protocol FullImageViewControllerDelegate <NSObject>

- (void) addItemViewController:(FullImageViewController *)controller viewShouldRefresh:(BOOL)refresh;

@end

@interface FullImageViewController : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIImageView *imageView;
@property (retain, nonatomic) IBOutlet UIImage *image;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *barButtonItemOptions;
@property (retain, nonatomic) NSString *fileName;
@property (retain, nonatomic) NSString *prevAction;
@property (nonatomic, assign) BOOL imageWasDeleted;
@property (nonatomic, assign) int highestNumber;
@property (nonatomic, assign) int lowestNumber;
@property (nonatomic, assign) int imageCount;
@property (nonatomic, weak) id <FullImageViewControllerDelegate> delegate;

@end