//
//  LAVAudioPlayerManager.m
//  Recorder
//
//  Created by Alan on 2020/11/6.
//

#import "LAVAudioPlayerManager.h"
#import <AVFoundation/AVFoundation.h>
@interface LAVAudioPlayerManager ()<AVAudioPlayerDelegate>

@property(nonatomic, strong) AVAudioPlayer *avAudioPalyer;

@end

static LAVAudioPlayerManager *_audioPlayerManager;
@implementation LAVAudioPlayerManager

+ (instancetype)shareAudioPalyerManager
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _audioPlayerManager = [[LAVAudioPlayerManager alloc] init];
    });
    return _audioPlayerManager;
}

- (void)setUp
{
    if (!self.playFilePath || self.playFilePath.length == 0) {
        return;
    }
    
    NSError *error = nil;
    [self stop];
    //每个文件都需要创建个播放器
    self.avAudioPalyer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:self.playFilePath] error:&error];

    if (error) {
        self.avAudioPalyer = nil;
        return;
    }
    
    self.avAudioPalyer.delegate = self;
    if ([self.avAudioPalyer prepareToPlay]) {
        
        if ([self.avAudioPalyer play]) {
            NSLog(@"===============开始播放");
        }else{
            NSLog(@"===============播放失败");
        }
    }
}

- (void)play
{
    [self setUp];
}

- (void)playWithPlayFileData:(NSData *)data
{
    NSString *temPath = NSTemporaryDirectory();
    NSString *time = [NSString stringWithFormat:@"%0.f",[[NSDate date] timeIntervalSince1970]];
    self.playFilePath = [temPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.wav",time]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [data writeToFile:self.playFilePath atomically:YES];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setUp];
        });
    });
}

- (void)stop
{
    if (self.avAudioPalyer && [self.avAudioPalyer isPlaying]) {
        [self.avAudioPalyer stop];
        self.avAudioPalyer = nil;
    }
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"=========播放结束");
    //player = nil;
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"=========解码失败");
}

@end
