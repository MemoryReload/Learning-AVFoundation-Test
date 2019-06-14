//
//  ViewController.m
//  ALAssetsTest
//
//  Created by HePing on 2019/6/13.
//  Copyright © 2019 何平. All rights reserved.
//

#import "GroupsViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "GroupsCollectionViewCell.h"

@interface GroupsViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic,strong) ALAssetsLibrary* lib;
@property (nonatomic,strong) NSMutableArray<ALAssetsGroup*> *groups;
@property (weak, nonatomic) IBOutlet UICollectionView *groupsCollectionView;
@end

@implementation GroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadGroups];
}

-(NSMutableArray<ALAssetsGroup *> *)groups
{
    if (!_groups) {
        _groups = [[NSMutableArray alloc]init];
    }
    return _groups;
}

- (ALAssetsLibrary *)lib
{
    if (!_lib) {
        _lib = [[ALAssetsLibrary alloc]init];
    }
    return _lib;
}

- (void)loadGroups
{
    [self.lib enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            NSLog(@"Group type: %@, name: %@, Id: %@, url: %@",[group valueForProperty:ALAssetsGroupPropertyType],[group valueForProperty:ALAssetsGroupPropertyName],[group valueForProperty:ALAssetsGroupPropertyPersistentID],[group valueForProperty:ALAssetsGroupPropertyURL]);
            [self.groups addObject:group];
        }else{
            [self.groupsCollectionView reloadData];
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"Access the album groups error! ");
    }];
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.groups count];
}

static NSString* const CellIdentifier = @"GroupCollectionCell";
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GroupsCollectionViewCell* cell = [self.groupsCollectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    ALAssetsGroup* group = [self.groups objectAtIndex:indexPath.row];
    cell.groupNameLabel.text = [group valueForProperty:ALAssetsGroupPropertyName];
    cell.groupCountLabel.text = [@([group numberOfAssets]) stringValue];
    cell.groupCoverImageView.image = [UIImage imageWithCGImage:group.posterImage];
    return cell;
}
@end
