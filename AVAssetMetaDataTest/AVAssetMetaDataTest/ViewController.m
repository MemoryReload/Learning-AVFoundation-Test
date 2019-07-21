//
//  ViewController.m
//  AVAssetMetaDataTest
//
//  Created by HePing on 2019/7/14.
//  Copyright © 2019 何平. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AVMetadataItem+MetadataKeyString.h"

@interface ViewController ()
@property (nonatomic,strong) NSArray<AVAsset*>* assets;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self getResources];
    [self getAllResourceMetaData];
//    NSLog(@"keys: %@, %@, %@", AVMetadataiTunesMetadataKeySongName, AVMetadataiTunesMetadataKeyArtist, AVMetadataiTunesMetadataKeyEncodingTool);
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
    [assets addObject:[AVAsset assetWithURL:[NSURL URLWithString:@"http://samples.mplayerhq.hu/MPEG-4/CDR-Dinner_LAN_800k.mp4"]]];
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
    [asset loadValuesAsynchronouslyForKeys:@[@"availableMetadataFormats",@"tracks",@"naturalSize",@"URL"] completionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"URL = %@",((AVURLAsset*)asset).URL);
            if ([asset statusOfValueForKey:@"naturalSize" error:nil] == AVKeyValueStatusLoaded) {
                NSLog(@"naturalSize = %@", NSStringFromCGSize(asset.naturalSize));
            }
            if ([asset statusOfValueForKey:@"availableMetadataFormats" error:nil] == AVKeyValueStatusLoaded) {
                NSLog(@"availableMetadataFormats = %@",asset.availableMetadataFormats);
            }
            if ([asset statusOfValueForKey:@"tracks" error:nil] == AVKeyValueStatusLoaded) {
                NSLog(@"tracks = %@",asset.tracks);
            }
            [self printMetadata:asset];
            [asset.availableMetadataFormats enumerateObjectsUsingBlock:^(AVMetadataFormat  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [self printMetadata:asset withFormat:obj];
            }];
            NSLog(@"--------------------------------");
        });
    }];
}

- (void)printMetadata:(AVAsset*)asset
{
    NSError* error;
    AVKeyValueStatus status = [asset statusOfValueForKey:@"metadata" error:&error];
    NSLog(@"===========allMetadata: %ld, error: %@", status, error);
    [[asset metadata] enumerateObjectsUsingBlock:^(AVMetadataItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"item%lu {%@:%@}",(unsigned long)idx,obj.keyString,obj.value);
    }];
}

- (void)printMetadata:(AVAsset*)asset   withFormat:(AVMetadataFormat)format
{
    NSLog(@">>>>>>>>>>>>%@:",format);
    [[asset metadataForFormat:format] enumerateObjectsUsingBlock:^(AVMetadataItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"item%lu {%@:%@}",(unsigned long)idx,obj.keyString,obj.value);
    }];
}
@end
