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
//  THE SOFTWARE.
//

#import "THPlayerController.h"
#import "THThumbnail.h"
#import <AVFoundation/AVFoundation.h>
#import "THTransport.h"
#import "THPlayerView.h"
#import "AVAsset+THAdditions.h"
#import "UIAlertView+THAdditions.h"
#import "THThumbnail.h"
#import "THNotifications.h"

// AVPlayerItem's status property
#define STATUS_KEYPATH @"status"

// Refresh interval for timed observations of AVPlayer
#define REFRESH_INTERVAL 0.5f

// Define this constant for the key-value observation context.
static const NSString *PlayerItemStatusContext;


@interface THPlayerController () <THTransportDelegate>
{
    id _timeObserverToken;
}

@property (strong, nonatomic) THPlayerView *playerView;
@property (strong, nonatomic) id<THTransport> transport;

// Listing 4.4
@property (nonatomic,strong) AVAsset*             asset;
@property (nonatomic,strong) AVPlayerItem*        playerItem;
@property (nonatomic,strong) AVPlayer*            player;

@property (nonatomic,assign) CGFloat lastPlaybackRate;
@property (nonatomic,strong) AVAssetImageGenerator* imageGenerator;

@end

@implementation THPlayerController

#pragma mark - Setup

- (id)initWithURL:(NSURL *)assetURL {
    self = [super init];
    if (self) {
        
        // Listing 4.6
        
        _asset = [AVAsset assetWithURL:assetURL];
        [self prepareToPlay];
    }
    return self;
}

- (void)prepareToPlay {
    
    // Listing 4.6
    NSArray* keys = @[@"tracks",@"commonMetadata",@"duration"];
    _playerItem = [[AVPlayerItem alloc]initWithAsset:_asset automaticallyLoadedAssetKeys:keys];
    [_playerItem addObserver:self forKeyPath:STATUS_KEYPATH options: NSKeyValueObservingOptionNew context:&PlayerItemStatusContext];
    
    _player = [[AVPlayer alloc]initWithPlayerItem:_playerItem];
    
    _playerView = [[THPlayerView alloc]initWithPlayer:_player];
    _transport = _playerView.transport;
    _transport.delegate = self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerView];
    [_player removeTimeObserver:_timeObserverToken];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    // Listing 4.7
    if (context == &PlayerItemStatusContext) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.playerItem removeObserver:self forKeyPath:STATUS_KEYPATH context:&PlayerItemStatusContext];
            AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey] integerValue];
            if (status == AVPlayerItemStatusReadyToPlay) {
                [self addPlayerItemTimeObserver];
                [self addItemEndObserverForPlayerItem];
                
                [self.transport setTitle:self.asset.title];
                [self.transport setCurrentTime:CMTimeGetSeconds(self.player.currentTime) duration:CMTimeGetSeconds(self.playerItem.duration)];
                [self.player play];
                
                //create thumnails
                [self generateThumbnails];
            }else{
                NSLog(@"AVPlayerItem: play failed!");
            }
        });
    }
}

#pragma mark - Time Observers

- (void)addPlayerItemTimeObserver {
    
    // Listing 4.8
    typeof(self) __weak wSelf = self;
    _timeObserverToken = [_player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        [wSelf.transport setCurrentTime:CMTimeGetSeconds(wSelf.player.currentTime) duration:CMTimeGetSeconds(wSelf.playerItem.duration)];
    }];
}

- (void)addItemEndObserverForPlayerItem {
    
    // Listing 4.9
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackComplete) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
}

- (void)playbackComplete
{
    typeof(self) __weak wSelf = self;
    [_player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        [wSelf.transport playbackComplete];
    }];
}
#pragma mark - THTransportDelegate Methods

- (void)play {
    
    // Listing 4.10
    [_player play];
}

- (void)pause {
    // Listing 4.10
    _lastPlaybackRate = self.player.rate;
    [_player pause];
}

- (void)stop {
    
    // Listing 4.10
    _player.rate = 0;
    [_transport playbackComplete];
}

- (void)jumpedToTime:(NSTimeInterval)time {
    
    // Listing 4.10
    [_player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (void)scrubbingDidStart {
    
    // Listing 4.11
    _lastPlaybackRate = _player.rate;
    [_player pause];
    [_player removeTimeObserver:_timeObserverToken];
}

- (void)scrubbedToTime:(NSTimeInterval)time {
    
    // Listing 4.11
    [_playerItem cancelPendingSeeks];
    [_player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (void)scrubbingDidEnd {
    
    // Listing 4.11
    [self addPlayerItemTimeObserver];
    if (_lastPlaybackRate >0) {
        [_player play];
    }
    NSLog(@">>>>>>>>>>>scrubbing end");
}


#pragma mark - Thumbnail Generation

- (void)generateThumbnails {
    
    // Listing 4.14
    _imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:_asset];
    _imageGenerator.maximumSize = CGSizeMake(200, 0);
//    //This makes accurate image generation, but may incur decoding problem.
//    _imageGenerator.requestedTimeToleranceBefore = _imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    
    CMTime duration = _asset.duration;
    NSMutableArray* times = [[NSMutableArray alloc]init];
//    CMTimeValue increment = duration.value / 20; // one 20th of duration
    CMTimeValue increment = duration.timescale*5;//every 5 seconds
    
    for (CMTimeValue currentTime = kCMTimeZero.value; currentTime <= duration.value ; currentTime += increment) {
        CMTime time = CMTimeMake(currentTime, duration.timescale);
        [times addObject:[NSValue valueWithCMTime:time]];
    }
    
    NSMutableArray* thumnails = [[NSMutableArray alloc]initWithCapacity:times.count];
    __block NSInteger counts = times.count;
    
    __weak typeof(self)wSelf = self;
    [_imageGenerator generateCGImagesAsynchronouslyForTimes:times completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        UIImage* img;
        if (AVAssetImageGeneratorSucceeded == result) {
            img = [UIImage imageWithCGImage:image scale:2 orientation:UIImageOrientationUp];
            NSLog(@"generate image succeeded for requested time: %@, actual time: %@",[NSValue valueWithCMTime:requestedTime],[NSValue valueWithCMTime:actualTime]);
        }else{
            img = [[UIImage alloc]init];
        }
        if (error) {
            NSLog(@"generate image failed for time: %@", [NSValue valueWithCMTime:actualTime]);
        }
        
        THThumbnail* thumnail = [THThumbnail thumbnailWithImage:img time:actualTime];
        [thumnails addObject:thumnail];
        counts--;
        
        if (0 == counts) {
            typeof(self) sSelf =wSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:THThumbnailsGeneratedNotification object:sSelf userInfo:@{ThumbnailsGeneratedNotificationThumbnailsKey:thumnails,ThumbnailsGeneratedNotificationObjectKey:sSelf}];
            });
        }
    }];
}


- (void)loadMediaOptions {
    
    // Listing 4.16
    
}

- (void)subtitleSelected:(NSString *)subtitle {
    
    // Listing 4.17
    
}


#pragma mark - Housekeeping

- (UIView *)view {
    return self.playerView;
}

@end
