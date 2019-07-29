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

#import "THGenreMetadataConverter.h"
#import "THGenre.h"

@implementation THGenreMetadataConverter

- (id)displayValueFromMetadataItem:(AVMetadataItem *)item {
    
    // Listing 3.15
    THGenre* genre;
    if ([item.value isKindOfClass:[NSString class]]) {
        if ([item.keySpace isEqualToString:AVMetadataKeySpaceID3]) {
            if (item.numberValue) {
                genre = [THGenre id3GenreWithIndex:[item.numberValue integerValue]];
            }else{
                genre = [THGenre id3GenreWithName:(NSString*)item.value];
            }
        }else{
            genre = [THGenre videoGenreWithName:(NSString*)item.value];
        }
    }else if ([item.value isKindOfClass:[NSData class]]){
        NSData* data = (NSData*)item.value;
        if (data.length ==2) {
            uint16_t *value = (uint16_t *)[data bytes];
            genre = [THGenre iTunesGenreWithIndex:CFSwapInt16BigToHost(value[0])];
        }
    }
    return genre;
}

- (AVMetadataItem *)metadataItemFromDisplayValue:(id)value
                                withMetadataItem:(AVMetadataItem *)item {
    
    // Listing 3.15
    THGenre* genre = (THGenre*)value;
    AVMutableMetadataItem* mutableItem = [item mutableCopy];
    if ([item.value isKindOfClass:[NSString class]]) {
        mutableItem.value = genre.name;
    }else if ([item.value isKindOfClass:[NSData class]]){
        NSData* data = (NSData*)item.value;
        if (data.length ==2) {
            uint16_t index = CFSwapInt16HostToBig(genre.index + 1);;
            size_t len = sizeof(index);
            mutableItem.value = [NSData dataWithBytes:&index length:len];
        }
    }
    return [mutableItem copy];
}

@end
