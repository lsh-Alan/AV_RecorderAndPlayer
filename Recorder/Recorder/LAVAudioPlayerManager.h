//
//  LAVAudioPlayerManager.h
//  Recorder
//
//  Created by Alan on 2020/11/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LAVAudioPlayerManager : NSObject

@property(nonatomic, copy) NSString *playFilePath;

+ (instancetype)shareAudioPalyerManager;

- (void)play;

- (void)playWithPlayFileData:(NSData *)data;

- (void)stop;

@end

NS_ASSUME_NONNULL_END
