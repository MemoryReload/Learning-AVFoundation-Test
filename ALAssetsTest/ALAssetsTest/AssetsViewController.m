//
//  CollectionViewController.m
//  ALAssetsTest
//
//  Created by HePing on 2019/6/16.
//  Copyright © 2019 何平. All rights reserved.
//

#import "AssetsViewController.h"

@interface AssetsViewController ()
@property (nonatomic,strong) NSMutableArray<ALAsset*>* assets;
@end

@implementation AssetsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadGroupAssets];
}

- (NSMutableArray<ALAsset *> *)assets
{
    if (!_assets) {
        _assets = [[NSMutableArray alloc]init];
    }
    return _assets;
}

-(void)loadGroupAssets
{
    [self.group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            ALAsset* asset = result;
            NSString* type = [asset valueForProperty:ALAssetPropertyType];
            NSString* date = [asset valueForProperty:ALAssetPropertyDate];
            NSArray* UTIs = [asset valueForProperty:ALAssetPropertyRepresentations];
            NSDictionary* URLs = [asset valueForProperty:ALAssetPropertyURLs];
            if ([type isEqualToString:ALAssetTypePhoto]) {
                NSLog(@"Asset type %@, date %@, UTIs %@, URLs %@",type,date,UTIs,URLs);
            }else if([type isEqualToString:ALAssetTypeVideo]){
                NSString* duration = [asset valueForProperty:ALAssetPropertyDuration];
                NSLog(@"Asset type %@, date %@, duration %@, UTIs %@, URLs %@",type,date,duration,UTIs,URLs);
            }else{
                NSLog(@"Asset type %@", type);
            }
            [self.assets addObject:asset];
        }else{
            [self.collectionView reloadData];
        }
    }];
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assets.count;
}

static NSString * const reuseIdentifier = @"AssetCellIdentifier";
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    cell.backgroundColor = [UIColor blueColor];
    return cell;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
