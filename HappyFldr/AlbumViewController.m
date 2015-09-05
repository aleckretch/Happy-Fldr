//
//  AlbumViewController.m
//  HappyFldr
//
//  Created by Alec Kretch on 6/29/14.
//  Copyright (c) 2014 Alec Kretch. All rights reserved.
//

#import "AlbumViewController.h"

@interface AlbumViewController ()
{
    NSArray *allFiles;
}

@end

@implementation AlbumViewController

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
    //allFiles = [NSArray arrayWithObjects:@"dummy_main_image.png", @"options.png", @"dummy_main_image.png", nil];
}

- (void) setNavBar
{
    //set background clear
    self.view.backgroundColor = [UIColor clearColor];
    
    //set navbar title
    CGRect frame = CGRectMake(0, 0, 160, 44);
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:frame];
    titleLabel.font = [UIFont fontWithName:@"Intro" size:22];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = @"Folder";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.navigationItem.titleView = titleLabel;
    
    //custom button (logo) to send from Album to Main
    self.backToMainBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backToMainBtn addTarget:self action:@selector(onTapBackToMainButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.backToMainBtn setImage:[UIImage imageNamed:@"bar_logo.png"] forState:UIControlStateNormal];
    [self.backToMainBtn setImage:[UIImage imageNamed:@"bar_logo_highlighted.png"] forState:UIControlStateHighlighted];
    [self.backToMainBtn sizeToFit];
    UIBarButtonItem* customBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.backToMainBtn];
    self.navigationItem.leftBarButtonItem = customBarButtonItem;
    self.navigationItem.rightBarButtonItem = nil;
}

/*

- (NSMutableArray *)arrayOfImages
{
    int count;
    NSMutableArray *array = [NSMutableArray array];
    for (count = 0; count < 500; count++) //assuming no more than 500 items saved.
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *fileName = [NSString stringWithFormat:@"img%d", count]; //images are called img0.png, img1.png, etc
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
        UIImage *checkImage = [[UIImage alloc] initWithContentsOfFile:filePath];
        
        if (checkImage != nil) //if there is an image there, add it to array
        {
            [array addObject:checkImage];
        }
    }
    return array;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return allFiles.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];
    imageView.image = [UIImage imageNamed:[allFiles objectAtIndex:indexPath.row]];
    
    return cell;
}
 
*/

- (IBAction) onTapBackToMainButton:(id)sender
{
    //make the logo highlighted still on transition
    [self.backToMainBtn setImage:[UIImage imageNamed:@"bar_logo_highlighted.png"] forState:UIControlStateNormal];
    //and go back (to main view)
    
    [self.navigationController popViewControllerAnimated:YES];
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
