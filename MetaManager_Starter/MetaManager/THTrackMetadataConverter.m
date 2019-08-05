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

#import "THTrackMetadataConverter.h"
#import "THMetadataKeys.h"

@implementation THTrackMetadataConverter

- (id)displayValueFromMetadataItem:(AVMetadataItem *)item {
    
    // Listing 3.13
    NSNumber* number, *count;
    if ([item.value isKindOfClass:[NSString class]]) {
        NSArray* components = [(NSString*)item.value componentsSeparatedByString:@"/"];
        number = @([components[0] integerValue]);
        count = @([components[1] integerValue]);
    }else if ([item.value isKindOfClass:[NSData class]]){
        NSData* data = (NSData*)item.value;
        if (data.length == 8) {
            uint16_t *values = (uint16_t *)[data bytes];
            if (values[1]>0) {
                number = @(CFSwapInt16BigToHost(values[1]));
            }
            if (values[2]>0) {
                count = @(CFSwapInt16BigToHost(values[2]));
            }
        }
    }
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:number?:[NSNull null] forKey:THMetadataKeyTrackNumber];
    [dict setObject:count?:[NSNull null] forKey:THMetadataKeyTrackCount];
    return [dict copy];
}

- (AVMetadataItem *)metadataItemFromDisplayValue:(id)value
                                withMetadataItem:(AVMetadataItem *)item {
    
    // Listing 3.13
    AVMutableMetadataItem* mutableItem = [item mutableCopy];
    
    NSNumber* trackNumber = [value objectForKey:THMetadataKeyTrackNumber];
    NSNumber* trackCount = [value objectForKey:THMetadataKeyTrackCount];
    
    uint16_t data[4] = {0};
    if (trackNumber && ![trackNumber isKindOfClass:[NSNull class]]) {
        data[1] = CFSwapInt16HostToBig([trackNumber unsignedShortValue]);
    }
    if (trackCount && ![trackCount isKindOfClass:[NSNull class]]) {
        data[2] = CFSwapInt16HostToBig([trackCount unsignedShortValue]);
    }
    size_t length = sizeof(data);
    mutableItem.value = [NSData dataWithBytes:data length:length];
//    NSAssert(mutableItem != nil, @"catcha in Track Converter!");
    return [mutableItem copy];
}

@end
