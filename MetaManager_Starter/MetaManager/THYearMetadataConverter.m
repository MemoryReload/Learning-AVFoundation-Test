//
//  THYearMetadataConverter.m
//  MetaManager
//
//  Created by HePing on 2019/8/5.
//  Copyright © 2019 TapHarmonic, LLC. All rights reserved.
//

#import "THYearMetadataConverter.h"

@implementation THYearMetadataConverter

- (id)displayValueFromMetadataItem:(AVMetadataItem *)item { 
    if ([item.value isKindOfClass:[NSNumber class]]) {
        return item.value;
    }else if ([item.value isKindOfClass:[NSString class]]){
        NSString* strVale = (NSString*)item.value;
        return @([strVale integerValue]);
    }
    return nil;
}

- (AVMetadataItem *)metadataItemFromDisplayValue:(id)value withMetadataItem:(AVMetadataItem *)item {
    AVMutableMetadataItem* mutableItem = [item mutableCopy];
    if (value && [value isKindOfClass:[NSString class]]) {
        mutableItem.value = value;
    }else if (value && [value isKindOfClass:[NSNumber class]]){
        mutableItem.value = [(NSNumber*)value stringValue];
    }
    return [mutableItem copy];
}
@end
