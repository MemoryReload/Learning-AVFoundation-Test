//
//  ViewController.m
//  PHAssetsTest
//
//  Created by HePing on 2019/7/3.
//  Copyright © 2019 HePing. All rights reserved.
//

#import "ViewController.h"
#import <Photos/Photos.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self authorizeWithCompletionHandler:^(BOOL authorized) {
        if (authorized) {
            //fucking loading data now
//            [self loadAlbums];
            [self loadMoments];
        }
        else{
            //give the fucking alert
            UIAlertController* alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"请xxxx打开相册使用权限" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* action = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil];
            [alertVC addAction:action];
            [self.navigationController pushViewController:alertVC animated:YES];
        }
    }];
}

#pragma mark -  authorize method
- (void)authorizeWithCompletionHandler:(void(^)(BOOL authorized))completionBlock
{
   PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch (status) {
        case PHAuthorizationStatusRestricted:
        case PHAuthorizationStatusDenied:
            !completionBlock?:completionBlock(NO);
            break;
        case PHAuthorizationStatusAuthorized:
            !completionBlock?:completionBlock(YES);
            break;
        case PHAuthorizationStatusNotDetermined:
        {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                [self authorizeWithCompletionHandler:completionBlock];
            }];
        }
            break;
        default:
            break;
    }
}

-(void)loadAlbums
{
//    PHFetchResult<PHCollection *> * topCollections = [PHCollection fetchTopLevelUserCollectionsWithOptions:nil];
//    [topCollections enumerateObjectsUsingBlock:^(PHCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSLog(@"Top collecton %lu: %@",(unsigned long)idx, obj );
//    }];
    
    PHFetchOptions *fetchOpt = [PHFetchOptions new];
    fetchOpt.predicate = [NSPredicate predicateWithFormat:@"estimatedAssetCount > 0"];
    PHFetchResult<PHAssetCollection*>* userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:fetchOpt];
    [userAlbums enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"Collecton %lu: %@, count = %lu",(unsigned long)idx, obj , obj.estimatedAssetCount);
    }];
    
    NSLog(@"------------------------------------------------");

    PHFetchResult<PHAssetCollection*>* smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:fetchOpt];
    [smartAlbums enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"Collecton %lu: %@, count = %lu",(unsigned long)idx, obj , obj.estimatedAssetCount);
    }];
}

-(void)loadMoments
{
    PHFetchResult<PHCollectionList*>* momentLists = [PHCollectionList fetchCollectionListsWithType:PHCollectionListTypeMomentList subtype:PHCollectionListSubtypeMomentListYear options:nil];
    [momentLists enumerateObjectsUsingBlock:^(PHCollectionList * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"Top collecton %lu: %@",(unsigned long)idx, obj );
    }];
}
@end
