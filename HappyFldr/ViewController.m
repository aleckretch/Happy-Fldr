//
//  ViewController.m
//  HappyFldr
//
//  Created by Alec Kretch on 6/29/14.
//  Copyright (c) 2014 Alec Kretch. All rights reserved.
//

#import "ViewController.h"
#import "AlbumCollectionViewController.h"
#import "MBProgressHUD.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>
#include <stdlib.h>

@interface ViewController ()

@end

@implementation ViewController

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    //set nav bar color
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:140/255.0f green:193/255.0f blue:227/255.0f alpha:1.0f]];
    self.navigationController.navigationBar.translucent = NO;
    
    //remove navbar
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.highestNumber = [self getHighestImageNumber];
    [self setNewRandomImage]; //set the main random image
    [self checkIfEmptyFolder]; //check if the folder is empty. Act from there.
    [[UIApplication sharedApplication] setStatusBarHidden:YES]; //hide status bar
    
    //register taps
    UITapGestureRecognizer *tapOnce = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnce:)];
    UITapGestureRecognizer *tapTwice = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTwice:)];
    
    tapOnce.numberOfTapsRequired = 1;
    tapTwice.numberOfTapsRequired = 2;
    
    [tapOnce requireGestureRecognizerToFail:tapTwice]; //stops tapOnce from overriding tapTwice
    
    //set them to the view
    [self.view addGestureRecognizer:tapOnce];
    [self.view addGestureRecognizer:tapTwice];
}

- (void) viewWillAppear:(BOOL)animated { //this is basically in case an image was deleted from the album
    [super viewWillAppear:animated];
    [self setMainView];
    [self checkIfFileExists];
    self.highestNumber = [self getHighestImageNumber];
}

- (void) checkIfFileExists
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:self.fileName];
    UIImage *imageChecked = [[UIImage alloc] initWithContentsOfFile:filePath];
    
    if (imageChecked == nil)
    {
        [self setNewRandomImage];
    }
}

- (void) setNewRandomImage
{
    int count = [self getImageCount] - 1;
    
    //set image if null
    if (count < 0)
    {
        self.folderIsEmpty = YES;
    }
    else
    {
        self.folderIsEmpty = NO;
        self.image = [self generateRandomImage];
    }
    [self setMainView];
}

- (void) checkIfEmptyFolder
{
    int count = [self getImageCount] - 1;
    if (count < 0)
    {
        [self emptyFolder];
    }
    else
    {
        [self.imageViewEmptyFolder setHidden:YES];
        [self.btnTapAnywhereToAddToFolder setHidden:YES];
    }
    self.imageViewEmptyFolder.center = self.view.center;
}

- (int) getImageCount
{
    int count;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:NULL];
    for (count = 0; count < (int)[directoryContent count]; count++)
    {
        //nothing
    }
    return count/2; //accounting for image and thumbnail
}

- (UIImage *) generateRandomImage
{
    int highest = (self.highestNumber) + 1;
    int currentFileNumber = [self getFileNumber:self.fileName];
    UIImage *randomImage;
    int r = arc4random() % highest; //random number up to the highest image file number
    if (self.getImageCount > 1) //if there are multiple images, make sure it switches everytime shuffle is pressed
    {
        while (r == currentFileNumber || r == 0)
        {
            r = arc4random() % highest;
        }
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    self.fileName=[NSString stringWithFormat:@"img%d", r]; //random file
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:self.fileName];
    randomImage = [[UIImage alloc] initWithContentsOfFile:filePath];
    
    //to make sure that a deleted image isn't brought up
    while (randomImage == nil)
    {
        int r = arc4random() % highest;
        if (self.getImageCount > 1)
        {
            while (r == currentFileNumber || r == 0)
            {
                r = arc4random() % highest;
            }
        }
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        self.fileName=[NSString stringWithFormat:@"img%d", r];
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:self.fileName];
        randomImage = [[UIImage alloc] initWithContentsOfFile:filePath];
    }
    
    return randomImage;
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

- (void) emptyFolder //the folder is empty
{
    [self hideMainButtons];
    [self.imageView setHidden:YES];
    [self.scrollView setHidden:YES];
    [self.imageViewEmptyFolder setHidden:NO];
    [self.btnTapAnywhereToAddToFolder setHidden:NO];
    //set background clear to baby blue
    self.view.backgroundColor = [UIColor colorWithRed:140/255.0f green:193/255.0f blue:227/255.0f alpha:1.0f];
}

- (void) setMainScrollView
{
    //scroll zoom
    self.scrollView.maximumZoomScale = 3.0;
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.zoomScale = 1.0;
    CGSize scrollableSize = CGSizeMake(self.view.frame.size.width, 0); //disable initial scroll
    [self.scrollView setContentSize:scrollableSize];
    
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
    self.scrollView.center = self.view.center;
    self.imageView.center = self.view.center;
    
    [self.imageView setImage:self.image]; //set from setImageFile method called from parent
    
    //this will center the image and keep it in correct proportions
    self.imageView.contentMode = UIViewContentModeCenter;
    if (self.imageView.bounds.size.width > (self.image.size.width && self.imageView.bounds.size.height > self.image.size.height))
    {
        self.imageView.contentMode = UIViewContentModeScaleToFill;
    }
}

- (void) setMainView
{
    //if the image is empty....
    if (self.folderIsEmpty)
    {
        [self emptyFolder];
    }
    else
    {
        self.imageView.image = self.image;
        [self setMainScrollView];
        //set background black
        self.view.backgroundColor = [UIColor blackColor];
    }
}

- (int) getFileNumber:(NSString *)fileName
{
    NSArray *components = [fileName componentsSeparatedByString:@"img"];
    NSString *numberString = [components objectAtIndex:1];
    int fileNumber = (int)[numberString integerValue];
    return fileNumber;
}

- (void) tapOnce:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.mainButtonsAreHidden)
    {
        [self fadeInMainButtons];
    }
    else
    {
        [self fadeOutMainButtons];
    }
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
        if (self.mainButtonsAreHidden)
        {
            [self fadeInMainButtons];
        }
    }
}

- (void) hideMainButtons
{
    [self.btnOptions setHidden:YES];
    [self.btnShuffle setHidden:YES];
    [self.btnFolder setHidden:YES];
    self.mainButtonsAreHidden = YES;
}

- (void) showMainButtons
{
    [self.btnOptions setHidden:NO];
    [self.btnShuffle setHidden:NO];
    [self.btnFolder setHidden:NO];
    self.mainButtonsAreHidden = NO;
}

- (void) fadeOutMainButtons
{
    [UIView animateWithDuration:0.4 animations:^{self.btnFolder.alpha = 0.0; self.btnOptions.alpha = 0.0; self.btnShuffle.alpha = 0.0;}]; //.4 is about duration of uistatusbaranimationfade
    self.mainButtonsAreHidden = YES;
}

- (void) fadeInMainButtons
{
    [UIView animateWithDuration:0.4 animations:^{self.btnFolder.alpha = 1.0; self.btnOptions.alpha = 1.0; self.btnShuffle.alpha = 1.0;}]; //.4 is about duration of uistatusbaranimationfade
    self.mainButtonsAreHidden = NO;
}

- (UIImage *) resizeImage:(UIImage *)image width:(CGFloat) width height:(CGFloat) height
{
    UIImage *resizedImage;
    CGSize size = CGSizeMake(width, height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    [image drawInRect:CGRectMake(0, 0, width, height)];
    resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizedImage;
}

- (void) saveTheImage:(UIImage *)image fileName:(NSString *)name width:(CGFloat) width height:(CGFloat) height quality:(CGFloat) quality extension:(int)fileNumberExtension
{
    UIImage *resizedImage = [self resizeImage:image width:width height:height];
    NSData *data = UIImageJPEGRepresentation(resizedImage, quality);
    NSString *fileName = [NSString stringWithFormat:@"%@%d", name, fileNumberExtension]; //img[unique number].png
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *tempPath = [documentsDirectory stringByAppendingPathComponent:fileName];
    if ([self getImageCount] == 0)
    {
        [data writeToFile:tempPath atomically:YES];
    }
    else
    {
        NSBlockOperation* saveOp = [NSBlockOperation blockOperationWithBlock: ^{
            [data writeToFile:tempPath atomically:YES];
        }];
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [queue addOperation:saveOp];
    }
}

- (void) imagePickerController:(QBImagePickerController *)imagePickerController didSelectAssets:(NSArray *)assets
{
    int initialFileCount = [self getImageCount];
    for (int i=0;i<assets.count;i++)
    {
        @autoreleasepool
        {
            ALAssetRepresentation *rep = [[assets objectAtIndex:i] defaultRepresentation];
            CGImageRef iref = [rep fullResolutionImage];
            UIImage *pickedImage = [UIImage imageWithCGImage:iref scale:[rep scale] orientation:(UIImageOrientation)[rep orientation]];
            self.highestNumber++;
            int fileNumberExtension = self.highestNumber; //new images all have a higher file name
            //set the ratio (width of image is 294)
            CGFloat ratio = pickedImage.size.width / 294;
            CGFloat newHeight = pickedImage.size.height / ratio;
            
            if (newHeight < 430) //image is too wide
            {
                [self saveTheImage:pickedImage fileName:@"img" width:294 height:newHeight quality:0.8f extension:fileNumberExtension];
            }
            else //if the image is too narrow
            {
                //set the ratio (height of image is 430)
                CGFloat ratio = pickedImage.size.height / 430;
                CGFloat newWidth = pickedImage.size.width / ratio;
                
                [self saveTheImage:pickedImage fileName:@"img" width:newWidth height:430 quality:0.8f extension:fileNumberExtension];
            }
            
            [self saveTheImage:pickedImage fileName:@"thm" width:78 height:78 quality:0.0f extension:fileNumberExtension]; //save the thumbnail
        }
    }
    
    if (initialFileCount == 0) //if it is the first image added, set it as the main image
    {
        [self firstItemAddedToFolder];
    }
    
    [self dismissImagePickerController];
    
    //show alert on successful upload //with server must add in if/else statements to make sure it uploads successfully
    if (assets.count == 1) // if one image selected
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Success!" message: @"The photo has been added to your folder." delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Success!" message: @"The photos have been added to your folder." delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
{
    [self dismissImagePickerController];
}

- (void)dismissImagePickerController
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) firstItemAddedToFolder
{
    [self.imageView setHidden:NO];
    [self showMainButtons];
    [self.scrollView setHidden:NO];
    [self.imageViewEmptyFolder setHidden:YES];
    [self.btnTapAnywhereToAddToFolder setHidden:YES];
    [self setNewRandomImage];
}

- (void) addToFolderClicked
{
    QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsMultipleSelection = YES;
    //imagePickerController.maximumNumberOfSelection = 40; No max upload
    imagePickerController.filterType = QBImagePickerControllerFilterTypePhotos;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (IBAction) onTapAnywhereToAddToFolder:(id)sender //for when the folder is empty
{
    [self addToFolderClicked];
}

- (IBAction) onTapOptionsButton:(id)sender
{
    //Shows image options
    self.actionSheetOptions = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Remove from folder" otherButtonTitles:@"Share to Twitter", @"Share to Facebook", @"Save to camera roll", nil];
    
    [self.actionSheetOptions showInView:self.view];
}

- (IBAction) onTapFolderButton:(id)sender
{
    //Shows folder options
    self.actionSheetFolder = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Upload photo(s)", @"View folder", nil];
    
    [self.actionSheetFolder showInView:self.view];
}

- (IBAction) onTapShuffleButton:(id)sender
{
    [self setNewRandomImage]; //call this method to get new random image
}

- (void) actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    //options clicked
    if(actionSheet==self.actionSheetOptions)
    {
        //Warning appears when the remove action is clicked
        if (buttonIndex == 0) //delete button clicked
        {
            [self removeImageWarning];
        }
        else if (buttonIndex == 1) //share to Twitter
        {
            SLComposeViewController *composeController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            
            [composeController setInitialText:@"This photo makes me happy (via @HappyFldr)"];
            [composeController addImage:self.image];
            [self presentViewController:composeController animated:YES completion:nil];
        }
        else if (buttonIndex == 2) //share to Facebook
        {
            SLComposeViewController *composeController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            [composeController setInitialText:@"This photo makes me happy (via HappyFldr iOS)"];
            [composeController addImage:self.image];
            [self presentViewController:composeController animated:YES completion:nil];
        }
        else if (buttonIndex == 3) //save to camera roll
        {
            //add progress hud to view
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"Loading";
            [self saveImageToSavePhotosAlbum];
        }
    }
    //folder clicked
    else if (actionSheet==self.actionSheetFolder)
    {
        if (buttonIndex == 0) //upload to folder clicked
        {
            [self addToFolderClicked];
        }
        else if (buttonIndex == 1) //view folder clicked
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
            AlbumCollectionViewController *albumCollectionViewController = [storyboard instantiateViewControllerWithIdentifier:@"AlbumNavigationController"];
            [UINavigationBar appearance].tintColor = [UIColor whiteColor];
            [self presentViewController:albumCollectionViewController animated:YES completion:nil];
        }
    }
}

- (void) saveImageToSavePhotosAlbum
{
    UIImageWriteToSavedPhotosAlbum(self.image, self, @selector(image:finishedSavingWithError:contextInfo:), nil);
}

- (void) removeImageWarning
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Does this photo not make you happy anymore?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Remove it!", nil];
    [alertView show];
}

- (void) alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) //remove button clicked
    {
        [self removeFile:self.fileName]; //remove the file with the current filename
    }
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
            if (removedFileNumber == self.highestNumber)
            {
                self.highestNumber = [self getHighestImageNumber];
            }
            [self setNewRandomImage];
        }
    }
    else
    {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Fail" message:@"There was a problem removing the photo." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
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
    //remove progress hud
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void) centerScrollViewContents
{
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width)
    {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    }
    else
    {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height)
    {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    }
    else
    {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.imageView.frame = contentsFrame;
}

- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void) scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self centerScrollViewContents];
}

- (CGRect) zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    
    CGRect zoomRect;
    
    zoomRect.size.height = self.imageView.frame.size.height / scale;
    zoomRect.size.width  = self.imageView.frame.size.width  / scale;
    
    center = [self.imageView convertPoint:center fromView:self.view];
    
    zoomRect.origin.x = center.x - ((zoomRect.size.width / 2.0));
    zoomRect.origin.y = center.y - ((zoomRect.size.height / 2.0));
    
    return zoomRect;
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
