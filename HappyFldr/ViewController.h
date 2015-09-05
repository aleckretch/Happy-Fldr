//
//  ViewController.h
//  HappyFldr
//
//  Created by Alec Kretch on 6/29/14.
//  Copyright (c) 2014 Alec Kretch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QBImagePickerController.h"
#import <Social/Social.h>

@interface ViewController : UIViewController <UINavigationControllerDelegate,QBImagePickerControllerDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UIScrollViewDelegate>

@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIImage *image;
@property (retain, nonatomic) IBOutlet UIImageView *imageView;
@property (retain, nonatomic) IBOutlet UIImageView *imageViewEmptyFolder;
@property (retain, nonatomic) IBOutlet UIButton *btnTapAnywhereToAddToFolder;
@property (retain, nonatomic) IBOutlet UIButton *btnFolder;
@property (retain, nonatomic) IBOutlet UIButton *btnOptions;
@property (retain, nonatomic) IBOutlet UIButton *btnShuffle;
@property (retain, nonatomic) IBOutlet UIActionSheet *actionSheetOptions;
@property (retain, nonatomic) IBOutlet UIActionSheet *actionSheetFolder;
@property (retain, nonatomic) NSString *fileName;
@property (nonatomic, assign) BOOL mainButtonsAreHidden;
@property (nonatomic, assign) BOOL folderIsEmpty;
@property (nonatomic, assign) int highestNumber;

- (IBAction) onTapOptionsButton:(id)sender;
- (IBAction) onTapFolderButton:(id)sender;
- (IBAction) onTapShuffleButton:(id)sender;

@end
