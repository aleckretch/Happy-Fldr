//
//  AlbumCollectionViewController.m
//  HappyFldr
//
//  Created by Alec Kretch on 7/8/14.
//  Copyright (c) 2014 Alec Kretch. All rights reserved.
//

#import "AlbumCollectionViewController.h"
#import "FullImageViewController.h"

@interface AlbumCollectionViewController ()

@end

@implementation AlbumCollectionViewController

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
    [self setNavBar];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide]; //slide in status bar
    
    //set cache
    self.cacheThumbnailImage = [[NSCache alloc] init];
    self.cacheThumbnailImage.name = @"com.aleckretch.HappyFldr.thmImageCache";
    
    //set view background
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.viewFirstOpened = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //start the scroll at the bottom
    if (self.viewFirstOpened)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.arrayThumbnails = [self arrayOfThumbnails];
            [self setFooterText];
            CGSize contentSize = [self.collectionView.collectionViewLayout collectionViewContentSize];
            if (contentSize.height > self.collectionView.bounds.size.height)
            {
                CGPoint targetContentOffset = CGPointMake(0.0f, contentSize.height - self.collectionView.bounds.size.height);
                [self.collectionView setContentOffset:targetContentOffset];
            }
        });
    }
    self.viewFirstOpened = NO;
}

- (void) setNavBar
{
    //set background clear
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    //opaque navbar
    self.navigationController.navigationBar.translucent = NO;
    
    //set navbar title
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width/2, self.navigationController.navigationBar.frame.size.height);
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:frame];
    titleLabel.font = [UIFont fontWithName:@"Intro" size:22];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = @"Folder";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.navigationItem.titleView = titleLabel;
    
    //cancel button
    UIImage *cancelIcon = [UIImage imageNamed:@"cancel.png"];
    UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithImage:cancelIcon style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = cancelBarButtonItem;
}

- (void) setFooterText
{
    NSString *amountOfPhotos;
    if (self.arrayThumbnails.count == 1)
    {
        amountOfPhotos = @"%ld Photo";
    }
    else
    {
        amountOfPhotos = @"%ld Photos";
    }
    self.labelPhotoCount.text = nil;
    self.labelPhotoCount = [[UILabel alloc] initWithFrame:CGRectZero];
    self.labelPhotoCount.font = [UIFont systemFontOfSize:17];
    self.labelPhotoCount.textColor = [UIColor blackColor];
    self.labelPhotoCount.textAlignment = NSTextAlignmentCenter;
    self.labelPhotoCount.frame = CGRectMake(0, 29 / 2.0, self.view.frame.size.width, 21.0);
    self.labelPhotoCount.text = [NSString stringWithFormat:amountOfPhotos, self.arrayThumbnails.count];
}

- (NSMutableArray *) arrayOfThumbnails
{
    int count;
    NSMutableArray *array = [NSMutableArray array];
    for (count = 0; count < 500; count++) //assuming no more than 500 items saved. Show most recent items first
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *fileName = [NSString stringWithFormat:@"thm%d", count];
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
        UIImage *checkImage = [[UIImage alloc] initWithContentsOfFile:filePath];
        
        if (checkImage != nil) //if there is an image there, add it to array
        {
            if (array.count == 0)
            {
                self.lowestNumber = count;
            }
            self.highestNumber = count;
            [array addObject:fileName];
        }
    }
    [self.collectionView reloadData];
    return array;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.arrayThumbnails.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    //get image at path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *fileName = [self.arrayThumbnails objectAtIndex:indexPath.row];
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    NSString *cacheKey = self.arrayThumbnails[indexPath.item]; //try row if this doesn't work
    cell.backgroundColor = [UIColor colorWithPatternImage:[self.cacheThumbnailImage objectForKey:cacheKey]];
    if (cell.backgroundColor == nil)
    {
        cell.backgroundColor = [UIColor lightGrayColor];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *imageAtPath = [[UIImage alloc] initWithContentsOfFile:filePath];
            int squareSize = 78; //the square is this width and height
            CGSize size = CGSizeMake(squareSize, squareSize);
                
            UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
                
            [imageAtPath drawInRect:CGRectMake(0, 0, squareSize, squareSize)];
                
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            [self.cacheThumbnailImage setObject:image forKey:cacheKey];
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.backgroundColor = [UIColor colorWithPatternImage:image];
            });
        });
    }
    
    return cell;
}

- (void) collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath //on click highlight the cell
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor blackColor];
    [cell.contentView setAlpha:0.3f];
}

- (void) collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath //on release, unhighlight the cell
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor clearColor];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableView;
    
    if (kind == UICollectionElementKindSectionFooter) {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"AlbumFooterView" forIndexPath:indexPath];
        
        [reusableView addSubview:self.labelPhotoCount];
    }
    
    return reusableView;
}

- (int) getFileNumber:(int)row
{
    //get the file name
    NSString *fileName = [self.arrayThumbnails objectAtIndex:row];
    NSArray *components = [fileName componentsSeparatedByString:@"thm"];
    NSString *numberString = [components objectAtIndex:1];
    int fileNumber = (int)[numberString integerValue];
    
    //return the int
    return fileNumber;
}

- (void) cancel:(id)sender
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide]; //slide out status bar
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"FullImageThumbSegue"]) //title of the segue in storyboard
    {
        FullImageViewController *controller = [segue destinationViewController]; //load the controller
        NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:0]; //get index of clicked cell
        
        controller.fileName = [NSString stringWithFormat:@"img%d", [self getFileNumber:(int)indexPath.row]];
        controller.highestNumber = self.highestNumber;
        controller.lowestNumber = self.lowestNumber;
        controller.imageCount = (int)self.arrayThumbnails.count;
        controller.delegate = self;
    }
}

- (void) addItemViewController:(FullImageViewController *)controller viewShouldRefresh:(BOOL)refresh
{
    if (refresh)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.arrayThumbnails = [self arrayOfThumbnails]; //refresh array in case file was deleted to move cells down
            [self setFooterText];
        });
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
