//
//  FullImageViewController.m
//  HappyFldr
//
//  Created by Alec Kretch on 6/30/14.
//  Copyright (c) 2014 Alec Kretch. All rights reserved.
//

#import "FullImageViewController.h"
#import "ViewController.h"
#import "MBProgressHud.h"
#import <QuartzCore/QuartzCore.h>

@interface FullImageViewController ()

@end

@implementation FullImageViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self setNavBar];
    //register taps
    UITapGestureRecognizer *tapTwice = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTwice:)];
    tapTwice.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tapTwice];
    
    //register swipes
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
    
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    
    [self.view addGestureRecognizer:swipeLeft];
    [self.view addGestureRecognizer:swipeRight];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setImage];
}

- (void) setNavBar
{
    //make it opaque
    self.navigationController.navigationBar.translucent = NO;
    
    //set navbar title
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width/2, self.navigationController.navigationBar.frame.size.height);
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:frame];
    labelTitle.font = [UIFont fontWithName:@"Intro" size:22];
    labelTitle.textColor = [UIColor whiteColor];
    labelTitle.text = @"Photo";
    labelTitle.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = labelTitle;
    
    //back button
    UIImage *imageBack = [UIImage imageNamed:@"back.png"];
    UIBarButtonItem *barButtonItemBack = [[UIBarButtonItem alloc] initWithImage:imageBack style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    self.navigationItem.leftBarButtonItem = barButtonItemBack;
    
    //options button
    UIImage *imageOptions = [UIImage imageNamed:@"options.png"];
    self.barButtonItemOptions = [[UIBarButtonItem alloc] initWithImage:imageOptions style:UIBarButtonItemStylePlain target:self action:@selector(imageOptions:)];
    self.navigationItem.rightBarButtonItem = self.barButtonItemOptions;
}

- (void) setImage
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:self.fileName];
    self.image = [[UIImage alloc] initWithContentsOfFile:filePath];
    [self setMainScrollView];
}

- (void) setMainScrollView
{
    //scroll zoom
    self.scrollView.maximumZoomScale = 3.0;
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.zoomScale = 1.0;
    CGSize scrollableSize = CGSizeMake(self.view.frame.size.width, 0); //disable initial scroll
    [self.scrollView setContentSize:scrollableSize];
    
    //set the ratio (width of image is 294)
    CGFloat originalHeight = self.image.size.height / 2;
    CGFloat originalWidth = self.image.size.width / 2;
    CGFloat ratio = self.view.frame.size.width / originalWidth;
    CGFloat newHeight = originalHeight * ratio;
    
    if (newHeight < self.view.frame.size.height) //wide image
    {
        self.imageView.bounds = CGRectMake(0, 0, self.view.frame.size.width, newHeight);
    }
    else //narrow image
    {
        CGFloat widthRatio = self.view.frame.size.height / originalHeight;
        CGFloat newWidth = originalWidth * widthRatio;
        self.imageView.bounds = CGRectMake(0, 0, newWidth, self.view.frame.size.height);
    }
    self.scrollView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    self.imageView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    
    [self.imageView setImage:self.image]; //set from setImageFile method called from parent
    
    //this will center the image and keep it in correct proportions
    self.imageView.contentMode = UIViewContentModeCenter;
    if (self.imageView.bounds.size.width > (self.image.size.width && self.imageView.bounds.size.height > self.image.size.height))
    {
        self.imageView.contentMode = UIViewContentModeScaleToFill;
    }
}

- (int) getFileNumber:(NSString *)fileName
{
    NSArray *components = [fileName componentsSeparatedByString:@"img"];
    NSString *numberString = [components objectAtIndex:1];
    int fileNumber = (int)[numberString integerValue];
    return fileNumber;
}

- (int) getHighestImageNumber
{
    int highest = 0;
    for (int count = 0; count < 500; count++)//assuming no more than 500 items in folder for now.
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *fileName = [NSString stringWithFormat:@"img%d", count];
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
        UIImage *imageChecked = [[UIImage alloc] initWithContentsOfFile:filePath];
        
        if (imageChecked != nil) //if there is an image there, that is the new highest image
        {
            NSArray *components = [fileName componentsSeparatedByString:@"img"];
            NSString *numberString = [components objectAtIndex:1];
            highest = (int)[numberString integerValue];
        }
    }
    return highest;
}

- (int) getLowestImageNumber
{
    int lowest = 500;
    for (int count = 500; count > 0; count--) //assuming no more than 500 items in folder for now.
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *fileName = [NSString stringWithFormat:@"img%d", count];
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
        UIImage *imageChecked = [[UIImage alloc] initWithContentsOfFile:filePath];
        
        if (imageChecked != nil) //if there is an image there, that is the new lowest image
        {
            NSArray *components = [fileName componentsSeparatedByString:@"img"];
            NSString *numberString = [components objectAtIndex:1];
            lowest = (int)[numberString integerValue];
        }
    }
    return lowest;
}

- (void) tapTwice:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.scrollView.zoomScale == self.scrollView.minimumZoomScale) //if zoomed all the way out
    {
        CGRect zoomRect = [self zoomRectForScale:self.scrollView.maximumZoomScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
        [self.scrollView zoomToRect:zoomRect animated:YES]; //zoom in at the tapped point
    }
    else
    {
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES]; //or else zoom out on double tap
    }
}

- (void) swipeGesture:(UISwipeGestureRecognizer *)swipe
{
    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        if ([self getFileNumber:self.fileName] != self.highestNumber)
        {
            [self loadImageRelatively:1];
            self.prevAction = @"next";
        }
    }
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionRight)
    {
        if ([self getFileNumber:self.fileName] != self.lowestNumber)
        {
            [self loadImageRelatively:-1];
            self.prevAction = @"prev";
        }
    }
}

- (void) loadImageRelatively:(int)relativeIndex
{
    self.prevAction = nil;
    CATransition *transition = [CATransition animation];
    transition.duration = 0.4;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    if (relativeIndex > 0)
    {
        transition.subtype = kCATransitionFromRight;
    }
    else
    {
        transition.subtype = kCATransitionFromLeft;
    }
    transition.delegate = self;
    
    int fileNumber = [self getFileNumber:self.fileName];
    self.fileName = [NSString stringWithFormat:@"img%d", fileNumber+relativeIndex];
    //check if file exists
    while ([self imageDoesNotExist:self.fileName])
    {
        if (relativeIndex > 0)
        {
            relativeIndex++;
        }
        else
        {
            relativeIndex--;
        }
        self.fileName = [NSString stringWithFormat:@"img%d", fileNumber+relativeIndex];
    }
    [self.view.layer addAnimation:transition forKey:nil];
    [self setImage];
}

- (BOOL) imageDoesNotExist:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    UIImage *imageChecked = [[UIImage alloc] initWithContentsOfFile:filePath];
    
    if (imageChecked != nil)
    {
        return NO;
    }
    return YES;
}

- (CGRect) zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    zoomRect.size.height = self.imageView.frame.size.height / scale;
    zoomRect.size.width  = self.imageView.frame.size.width  / scale;
    
    center = [self.imageView convertPoint:center fromView:self.view];
    
    zoomRect.origin.x = center.x - ((zoomRect.size.width / 2.0));
    zoomRect.origin.y = center.y - ((zoomRect.size.height / 2.0));
    
    return zoomRect;
}

- (void) centerScrollViewContents
{
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.imageView.frame = contentsFrame;
}

/***********************************************************
 *
 * UIScrollViewDelegate
 *
 ***********************************************************/

#pragma mark -
#pragma mark UIScrollViewDelegate

- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void) scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self centerScrollViewContents];
}

- (void) back:(id)sender
{
    [self.delegate addItemViewController:self viewShouldRefresh:self.imageWasDeleted];
    [self.navigationController popViewControllerAnimated:YES]; //go back
}

- (void) imageOptions:(id)sender
{
    //Shows image options
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Remove from folder" otherButtonTitles:@"Share to Twitter", @"Share to Facebook", @"Save to camera roll", nil];
    
    [actionSheet showInView:self.view];
}

//Remove button clicked
- (void) actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    //Warning appears when the remove action is clicked
    if (buttonIndex == 0)
    {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Does this photo not make you happy anymore?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Remove it!", nil];
        [alertView show];
        
    }
    else if (buttonIndex == 1) //share to Twitter
    {
        //compose tweet
        SLComposeViewController *composeController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        [composeController setInitialText:@"This photo makes me happy (via @HappyFldr)"];
        [composeController addImage:self.image];
        [self presentViewController:composeController animated:YES completion:nil];
    }
    else if (buttonIndex == 2) //share to Facebook
    {
        //compose status
        SLComposeViewController *composeController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [composeController setInitialText:@"This photo makes me happy (via HappyFldr iOS)"];
        [composeController addImage:self.image];
        [self presentViewController:composeController animated:YES completion:nil];
    }
    else if (buttonIndex == 3) //save image
    {
        //add progress hud
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Loading";
        //save image
        UIImageWriteToSavedPhotosAlbum(self.image, self, @selector(image:finishedSavingWithError:contextInfo:), nil);
    }
}

//Confirm removed button clicked
- (void) alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    //confirm that the photo will be removed!
    if (buttonIndex == 1)
    {
        [self removeFile:self.fileName]; //remove the file with the current filename
    }
}

- (void) image:(UIImage *)image finishedSavingWithError:(NSError *) error contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Failed" message: @"There was a problem saving the photo." delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Success!" message: @"The photo has been saved to your camera roll." delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    //hide progress hud
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void) removeFile:(NSString *)fileName //remove the file from the documents directory
{
    int removedFileNumber = [self getFileNumber:self.fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (success) { //remove the thumbnail too
        int fileNumber = [self getFileNumber:fileName];
        NSString *thmPath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"thm%d", fileNumber]];
        BOOL thmSuccess = [fileManager removeItemAtPath:thmPath error:&error];
        if (thmSuccess)
        {
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"The photo has been removed." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
            self.imageCount--;
            self.imageWasDeleted = YES;
            if (self.imageCount == 0) //go back if there are no more images
            {
                [self.delegate addItemViewController:self viewShouldRefresh:self.imageWasDeleted];
                [self.navigationController popViewControllerAnimated:YES];
            }
            else if ([self.prevAction isEqual:@"next"]) //go to image coming from
            {
                [self loadImageRelatively:-1];
            }
            else if ([self.prevAction isEqual:@"prev"])
            {
                [self loadImageRelatively:1];
            }
            else
            {
                if ([self getFileNumber:self.fileName] != self.lowestNumber) //change image upon deletion
                {
                    [self loadImageRelatively:-1];
                }
                else
                {
                    [self loadImageRelatively:1];
                }
            }
            if (removedFileNumber == self.highestNumber)
            {
                self.highestNumber = [self getHighestImageNumber];
            }
            else if (removedFileNumber == self.lowestNumber)
            {
                self.lowestNumber = [self getLowestImageNumber];
            }
        }
    }
    else
    {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Fail" message:@"There was a problem removing the photo." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
