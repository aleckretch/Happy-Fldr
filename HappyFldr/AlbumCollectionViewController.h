//
//  AlbumCollectionViewController.h
//  HappyFldr
//
//  Created by Alec Kretch on 7/8/14.
//  Copyright (c) 2014 Alec Kretch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FullImageViewController.h"

@interface AlbumCollectionViewController : UICollectionViewController <FullImageViewControllerDelegate>

@property (retain, nonatomic) IBOutlet UILabel *labelPhotoCount;
@property (nonatomic, strong) NSCache *cacheThumbnailImage;
@property (retain, nonatomic) NSArray *arrayThumbnails;
@property (nonatomic, assign) BOOL viewFirstOpened;
@property (nonatomic, assign) int highestNumber;
@property (nonatomic, assign) int lowestNumber;
@property (nonatomic, assign) int imageCount;

@end
