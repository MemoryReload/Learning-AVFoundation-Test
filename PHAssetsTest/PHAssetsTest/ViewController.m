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
            [self loadCollections];
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

-(void)loadCollections
{
    
}
@end
