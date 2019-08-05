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

#import "THMetadata.h"
#import "THMetadataConverterFactory.h"
#import "THMetadataKeys.h"

@interface THMetadata ()
@property (strong) NSDictionary *keyMapping;
@property (strong) NSMutableDictionary *metadata;
@property (strong) THMetadataConverterFactory *converterFactory;
@end

@implementation THMetadata

- (id)init {
    self = [super init];
    if (self) {
        // Listing 3.6
        _keyMapping = [self buildKeyMapping];
        _metadata = [[NSMutableDictionary alloc]init];
        _converterFactory = [[THMetadataConverterFactory alloc]init];
    }
    return self;
}

- (NSDictionary *)buildKeyMapping {

    return @{
        // Name Mapping
        AVMetadataCommonKeyTitle : THMetadataKeyName,
        AVMetadataIdentifierQuickTimeMetadataDisplayName:THMetadataKeyName,
        @"@nam":THMetadataKeyName,
        @"com.apple.quicktime.displayname":THMetadataKeyName,
        @"TIT2":THMetadataKeyName,

        // Artist Mapping
        AVMetadataCommonKeyArtist : THMetadataKeyArtist,
        AVMetadataQuickTimeMetadataKeyProducer : THMetadataKeyArtist,
        @"@ART":THMetadataKeyArtist,

        // Album Artist Mapping
        AVMetadataID3MetadataKeyBand : THMetadataKeyAlbumArtist,
        AVMetadataiTunesMetadataKeyAlbumArtist : THMetadataKeyAlbumArtist,
        @"TP2" : THMetadataKeyAlbumArtist,

        // Album Mapping
        AVMetadataCommonKeyAlbumName : THMetadataKeyAlbum,
        AVMetadataQuickTimeMetadataKeyAlbum: THMetadataKeyAlbum,
        @"@alb":THMetadataKeyAlbum,
        @"TALB":THMetadataKeyAlbum,

        // Artwork Mapping
        AVMetadataCommonKeyArtwork : THMetadataKeyArtwork,
        AVMetadataQuickTimeMetadataKeyArtwork:THMetadataKeyArtwork,
        @"covr":THMetadataKeyArtwork,

        // Year Mapping
        AVMetadataCommonKeyCreationDate : THMetadataKeyYear,
        AVMetadataID3MetadataKeyYear : THMetadataKeyYear,
        AVMetadataQuickTimeMetadataKeyYear : THMetadataKeyYear,
        AVMetadataID3MetadataKeyRecordingTime : THMetadataKeyYear,
        @"TYE" : THMetadataKeyYear,
        @"@day":THMetadataKeyYear,

        // BPM Mapping
        AVMetadataiTunesMetadataKeyBeatsPerMin : THMetadataKeyBPM,
        AVMetadataID3MetadataKeyBeatsPerMinute : THMetadataKeyBPM,
        @"TBP" : THMetadataKeyBPM,

        // Grouping Mapping
        AVMetadataiTunesMetadataKeyGrouping : THMetadataKeyGrouping,
        AVMetadataCommonKeySubject : THMetadataKeyGrouping,
        @"@grp" : THMetadataKeyGrouping,

        // Track Number Mapping
        AVMetadataiTunesMetadataKeyTrackNumber : THMetadataKeyTrackNumber,
        AVMetadataID3MetadataKeyTrackNumber : THMetadataKeyTrackNumber,
        @"TRK" : THMetadataKeyTrackNumber,

        // Composer Mapping
        AVMetadataQuickTimeMetadataKeyDirector : THMetadataKeyComposer,
        AVMetadataiTunesMetadataKeyComposer : THMetadataKeyComposer,
        AVMetadataCommonKeyCreator : THMetadataKeyComposer,

        // Disc Number Mapping
        AVMetadataiTunesMetadataKeyDiscNumber : THMetadataKeyDiscNumber,
        AVMetadataID3MetadataKeyPartOfASet : THMetadataKeyDiscNumber,
        @"TPA" : THMetadataKeyDiscNumber,

        // Comments Mapping
        AVMetadataQuickTimeMetadataKeyDescription:THMetadataKeyComments,
        AVMetadataCommonKeyDescription : THMetadataKeyComments,
        AVMetadataiTunesMetadataKeyUserComment : THMetadataKeyComments,
        AVMetadataID3MetadataKeyComments : THMetadataKeyComments,
        @"COM" : THMetadataKeyComments,
        @"ldes" : THMetadataKeyComments,

        // Genre Mapping
        AVMetadataQuickTimeMetadataKeyGenre : THMetadataKeyGenre,
        AVMetadataiTunesMetadataKeyUserGenre : THMetadataKeyGenre,
        AVMetadataCommonKeyType : THMetadataKeyGenre,
        @"gnre":THMetadataKeyGenre
    };
}


- (void)addMetadataItem:(AVMetadataItem *)item withKey:(id)key {

    // Listing 3.7
    NSString* mappedKey =[_keyMapping objectForKey:key];
    if (!mappedKey) {
        return;
    }
    [_metadata setObject:item forKey:mappedKey];
    id<THMetadataConverter> converter = [_converterFactory converterForKey:mappedKey];
    id value = [converter displayValueFromMetadataItem:item];
    if ([value isKindOfClass:[NSDictionary class]]) {
        for (NSString* currentKey in (NSDictionary*)value) {
            [self setValue:value[currentKey] forKey:currentKey];
        }
    }else{
        [self setValue:value forKey:mappedKey];
    }
}

- (void)addMetadataItemForNumber:(NSNumber*)number count:(NSNumber*)count numberKey:(NSString*)numberKey countKey:(NSString*)countKey toArray:(NSMutableArray*)items
{
    id<THMetadataConverter> converter = [_converterFactory converterForKey:numberKey];
    NSDictionary* value = @{
                            numberKey:number?:[NSNull null],
                            countKey:count?:[NSNull null]
                            };
    AVMetadataItem* item = self.metadata[numberKey];
    AVMutableMetadataItem* mutableItem = [item mutableCopy];
    mutableItem.value = [converter metadataItemFromDisplayValue:value withMetadataItem:item];
//    NSAssert(mutableItem != nil, @"catcha!");
    if (mutableItem) [items addObject:[mutableItem copy]];
}

- (NSArray *)metadataItems {

    // Listing 3.16
    NSMutableArray* items = [NSMutableArray array];
    
    [self addMetadataItemForNumber:self.trackNumber count:self.trackCount numberKey:THMetadataKeyTrackNumber countKey:THMetadataKeyTrackCount toArray:items];
    
    [self addMetadataItemForNumber:self.discNumber count:self.discCount numberKey:THMetadataKeyDiscNumber countKey:THMetadataKeyDiscCount toArray:items];
    
    NSMutableDictionary* metadata = [self.metadata mutableCopy];
    [metadata removeObjectForKey:THMetadataKeyTrackNumber];
    [metadata removeObjectForKey:THMetadataKeyDiscNumber];
    for (NSString* key in metadata) {
        AVMetadataItem* item = [metadata valueForKey:key];
        id<THMetadataConverter> converter = [_converterFactory converterForKey:key];
        id value = [self valueForKey:key];
        item = [converter metadataItemFromDisplayValue:value withMetadataItem:item];
        [items addObject:item];
    }
    return [items copy];
}
@end
