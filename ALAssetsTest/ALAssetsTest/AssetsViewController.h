//
//  CollectionViewController.h
//  ALAssetsTest
//
//  Created by HePing on 2019/6/16.
//  Copyright © 2019 何平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

NS_ASSUME_NONNULL_BEGIN

@interface AssetsViewController : UICollectionViewController
@property (nonatomic,strong) ALAssetsGroup* group;
@end

NS_ASSUME_NONNULL_END
