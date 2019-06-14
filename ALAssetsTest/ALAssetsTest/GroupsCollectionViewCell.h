//
//  GroupsCollectionViewCell.h
//  ALAssetsTest
//
//  Created by HePing on 2019/6/14.
//  Copyright © 2019 何平. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GroupsCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *groupCoverImageView;
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupCountLabel;
@end

NS_ASSUME_NONNULL_END
