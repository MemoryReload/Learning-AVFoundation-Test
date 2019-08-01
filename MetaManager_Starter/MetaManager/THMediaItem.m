//
//  MIT License
//
//  Copyright (c) 2014 Bob McCune http://bobmccune.com/
//  Copyright (c) 2014 TapHarmonic, LLC http://tapharmonic.com/
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//

#import "THMediaItem.h"

#import "AVMetadataItem+THAdditions.h"
#import "NSFileManager+DirectoryLocations.h"

#define COMMON_META_KEY     @"commonMetadata"
#define AVAILABLE_META_KEY  @"availableMetadataFormats"

@interface THMediaItem ()
@property (strong) NSURL *url;
@property (strong) AVAsset *asset;
@property (strong) THMetadata *metadata;
@property (strong) NSArray *acceptedFormats;
@property BOOL prepared;
@end

@implementation THMediaItem

- (id)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        // Listing 3.3
        _url = url;
        _asset = [AVAsset assetWithURL:url];
        _filename = [_url lastPathComponent];
        _filetype = [self fileTypeForURL:_url];
        _editable = ![_filetype isEqualToString:AVFileTypeMPEGLayer3];
        _acceptedFormats = @[
                             AVMetadataFormatQuickTimeMetadata,
                             AVMetadataFormatiTunesMetadata,
                             AVMetadataFormatID3Metadata
                             ];
    }
    return self;
}

- (NSString *)fileTypeForURL:(NSURL *)url {

    // Listing 3.3
    NSString* fileExtension = [url pathExtension];
    NSString* type = nil;
    if ([fileExtension isEqualToString:@"mp4"]) {
        type = AVFileTypeMPEG4;
    }else if ([fileExtension isEqualToString:@"m4a"]){
        type = AVFileTypeAppleM4A;
    }else if ([fileExtension isEqualToString:@"m4v"]){
        type = AVFileTypeAppleM4V;
    }else if ([fileExtension isEqualToString:@"mov"]){
        type = AVFileTypeQuickTimeMovie;
    }else{
        type = AVFileTypeMPEGLayer3;
    }
    return type;
}

static NSString * const CommnMatadataKey = @"commonMetadata";
static NSString * const AvailableMatadataFormatKey = @"availableMetadataFormats";

- (void)prepareWithCompletionHandler:(THCompletionHandler)completionHandler {
    // Listing 3.4
    if (_prepared) {
        completionHandler(YES);
        return;
    }
    _metadata = [[THMetadata alloc]init];
    NSArray*  loadKeys = @[CommnMatadataKey,AvailableMatadataFormatKey];
    [_asset loadValuesAsynchronouslyForKeys:loadKeys completionHandler:^{
        AVKeyValueStatus  commonMatadataStatus = [_asset statusOfValueForKey:CommnMatadataKey error:nil];
        AVKeyValueStatus  availableFormatStatus = [_asset statusOfValueForKey:AvailableMatadataFormatKey error:nil];
        _prepared = commonMatadataStatus == AVKeyValueStatusLoaded && availableFormatStatus == AVKeyValueStatusLoaded;
        NSMutableArray<AVMetadataItem*>*  items = [[NSMutableArray alloc]init];
        [items addObjectsFromArray:_asset.commonMetadata];
        for (AVMetadataFormat format in _asset.availableMetadataFormats) {
            if ([self.acceptedFormats containsObject:format]) {
                [items addObjectsFromArray:[_asset metadataForFormat:format]];
            }
        }
        for (AVMetadataItem* item in items) {
            [_metadata addMetadataItem:item withKey:item.keyString];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(_prepared);
        });
    }];
}

- (void)saveWithCompletionHandler:(THCompletionHandler)handler {

    // Listing 3.17
    AVAssetExportSession* exportSession = [[AVAssetExportSession alloc]initWithAsset:_asset presetName:AVAssetExportPresetPassthrough];
}

@end
