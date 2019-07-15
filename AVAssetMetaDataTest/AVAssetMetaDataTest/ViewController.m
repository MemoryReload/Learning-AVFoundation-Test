//
//  ViewController.m
//  AVAssetMetaDataTest
//
//  Created by HePing on 2019/7/14.
//  Copyright © 2019 何平. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()
@property (nonatomic,strong) NSArray<AVAsset*>* assets;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self getResources];
    [self getAllResourceMetaData];
}

- (void)getResources
{
    NSArray* fileNames = @[@"SampleVideo0.MOV",@"SampleVideo1.mp4",@"SampleVideo2.3gp"];
    NSMutableArray* assets = [NSMutableArray arrayWithCapacity:fileNames.count];
    for (int i=0; i<fileNames.count; i++) {
        NSString* fileName = fileNames[i];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:[fileName stringByDeletingPathExtension] ofType:[fileName pathExtension]];
        NSURL* url = [NSURL fileURLWithPath:filePath];
        AVAsset* asset = [AVAsset assetWithURL:url];
        [assets addObject:asset];
    }
    self.assets = [assets copy];
}

- (void)getAllResourceMetaData
{
    for (AVAsset* asset in self.assets) {
        [self getMetaDataWithAsset:asset];
    }
}

- (void)getMetaDataWithAsset:(AVAsset*)asset
{
    [asset loadValuesAsynchronouslyForKeys:@[@"availableMetadataFormats",@"tracks"] completionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([asset statusOfValueForKey:@"availableMetadataFormats" error:nil] == AVKeyValueStatusLoaded) {
                NSLog(@"availableMetadataFormats = %@",asset.availableMetadataFormats);
            }
            if ([asset statusOfValueForKey:@"tracks" error:nil] == AVKeyValueStatusLoaded) {
                NSLog(@"tracks = %@",asset.tracks);
            }
            NSLog(@"--------------------------------");
        });
    }];
}
@end