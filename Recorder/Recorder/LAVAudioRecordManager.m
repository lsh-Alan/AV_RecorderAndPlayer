//
//  LAVAudioRecordManager.m
//  Recorder
//
//  Created by Alan on 2020/11/5.
//

/**
 参考https://github.com/hwp920/hwp920.github.io/blob/17566960a1cb077e55336ab72ad0e322809b47c6/source/_posts/AVFoundation%E5%AD%A6%E4%B9%A0%E7%AC%94%E8%AE%B0%E4%BA%8C-AVAudioSession.md
 
 AVFoundation定义了7种分类（category）来描述应用程序所使用的音频行为。

 7种类别各自的行为总结如下：

 AVAudioSessionCategoryAmbient： 只用于播放音乐时，并且可以和QQ音乐同时播放，比如玩游戏的时候还想听QQ音乐的歌，那么把游戏播放背景音就设置成这种类别。同时，当用户锁屏或者静音时也会随着静音，这种类别基本使用所有App的背景场景。
 AVAudioSessionCategorySoloAmbient(默认)：也是只用于播放,但是和***"AVAudioSessionCategoryAmbient"***不同的是，用了它就别想听QQ音乐了，比如不希望QQ音乐干扰的App，类似节奏大师。同样当用户锁屏或者静音时也会随着静音，锁屏了就玩不了节奏大师了。
 AVAudioSessionCategoryPlayback：如果锁屏了还想听声音怎么办？用这个类别，比如App本身就是播放器，同时当App播放时，其他类似QQ音乐就不能播放了。所以这种类别一般用于播放器类App
 AVAudioSessionCategoryRecord：有了播放器，肯定要录音机，比如微信语音的录制，就要用到这个类别，既然要安静的录音，肯定不希望有QQ音乐了，所以其他播放声音会中断。想想微信语音的场景，就知道什么时候用他了。
 AVAudioSessionCategoryPlayAndRecord：如果既想播放又想录制该用什么模式呢？比如VoIP，打电话这种场景，PlayAndRecord就是专门为这样的场景设计的 。
 AVAudioSessionCategoryMultiRoute：想象一个DJ用的App，手机连着HDMI到扬声器播放当前的音乐，然后耳机里面播放下一曲，这种常人不理解的场景，这个类别可以支持多个设备输入输出。
 AVAudioSessionCategoryAudioProcessing: 主要用于音频格式处理，一般可以配合AudioUnit进行使用
 
 
 AVAudioSessionCategoryOptions
 选项    适用类别    作用
 AVAudioSessionCategoryOptionMixWithOthers    AVAudioSessionCategoryPlayAndRecord, AVAudioSessionCategoryPlayback, and AVAudioSessionCategoryMultiRoute    是否可以和其他后台App进行混音
 AVAudioSessionCategoryOptionDuckOthers    AVAudioSessionCategoryAmbient, AVAudioSessionCategoryPlayAndRecord, AVAudioSessionCategoryPlayback, and AVAudioSessionCategoryMultiRoute    是否压低其他App声音
 AVAudioSessionCategoryOptionAllowBluetooth    AVAudioSessionCategoryRecord and AVAudioSessionCategoryPlayAndRecord    是否支持蓝牙耳机
 AVAudioSessionCategoryOptionDefaultToSpeaker    AVAudioSessionCategoryPlayAndRecord    是否默认用免提声音
 
 来看每个选项的基本作用：

 AVAudioSessionCategoryOptionMixWithOthers ： 如果确实用的AVAudioSessionCategoryPlayback实现的一个背景音，但是呢，又想和QQ音乐并存，那么可以在AVAudioSessionCategoryPlayback类别下在设置这个选项，就可以实现共存了。
 AVAudioSessionCategoryOptionDuckOthers：在实时通话的场景，比如QQ音乐，当进行视频通话的时候，会发现QQ音乐自动声音降低了，此时就是通过设置这个选项来对其他音乐App进行了压制。
 AVAudioSessionCategoryOptionAllowBluetooth：如果要支持蓝牙耳机电话，则需要设置这个选项
 AVAudioSessionCategoryOptionDefaultToSpeaker： 如果在VoIP模式下，希望默认打开免提功能，需要设置这个选项
 
 
 
 mode    适用的类别    场景
 AVAudioSessionModeDefault    所有类别    默认的模式
 AVAudioSessionModeVoiceChat    AVAudioSessionCategoryPlayAndRecord    VoIP
 AVAudioSessionModeGameChat    AVAudioSessionCategoryPlayAndRecord    游戏录制，由GKVoiceChat自动设置，无需手动调用
 AVAudioSessionModeVideoRecording    AVAudioSessionCategoryPlayAndRecord AVAudioSessionCategoryRecord    录制视频时
 AVAudioSessionModeMoviePlayback    AVAudioSessionCategoryPlayback    视频播放
 AVAudioSessionModeMeasurement    AVAudioSessionCategoryPlayAndRecord AVAudioSessionCategoryRecord AVAudioSessionCategoryPlayback    最小系统
 AVAudioSessionModeVideoChat    AVAudioSessionCategoryPlayAndRecord    视频通话
 
 
 录音后还原设置
 //录音结束时，应根据程序需要更改category为AVAudioSessionCategoryAmbient，AVAudioSessionCategorySoloAmbient或AVAudioSessionCategoryPlayback中的一种
 [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error: nil];
 //通知到其他应用
 [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
 
 
 */
#import "LAVAudioRecordManager.h"

@interface LAVAudioRecordManager ()<AVAudioRecorderDelegate>

@property(nonatomic, strong) AVAudioRecorder *avAudioRecorder;

@property(nonatomic, copy) NSString *resourcePath;

@property(nonatomic, assign) double startRecordTime;

@property(nonatomic, assign) double recordTime;


@end

static LAVAudioRecordManager *_audioRecordManager;
@implementation LAVAudioRecordManager

+ (instancetype)shareAVRecorder
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _audioRecordManager = [[LAVAudioRecordManager alloc] init];
    });
    
    return _audioRecordManager;
}

- (void)setUp
{
    
    // 录音会话设置
    NSError *errorSession = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord withOptions:AVAudioSessionCategoryOptionAllowBluetooth  error:&errorSession];
    //[[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];//设置为公放模式
    [[AVAudioSession sharedInstance] setActive:YES error:nil];//本App独占音频通道
    
    NSError *error = nil;
    NSDictionary *recordSetting = @{
        AVFormatIDKey : @(kAudioFormatLinearPCM),// 音频格式
        AVSampleRateKey : @44100.0f,// 录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
        AVNumberOfChannelsKey : @1,// 音频通道数 1 或 2
        AVEncoderBitDepthHintKey : @16,// 线性音频的位深度 8、16、24、32
        AVEncoderAudioQualityKey : @(AVAudioQualityHigh)// 录音的质量
    };
    
    //比特率 ： 采样率 * 量化格式 * 通道数   = 44100 * 16 * 1 = 689.0625 kbps (换算成了kb)

    // 1分钟占用多少存储空间： 689.0625 * 60 / 8 /1024 = 5.04M
    
    self.resourcePath = [self filePath];
    self.avAudioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:self.resourcePath] settings:recordSetting error:&error];

    if (error) {
        self.avAudioRecorder = nil;
        return;
    }

    self.avAudioRecorder.delegate = self;
    //self.avAudioRecorder.meteringEnabled = YES;
    
    // 4.设置录音时长，超过这个时间后，会暂停 单位是 秒
    //[self.avAudioRecorder recordForDuration:10];

    if ([self.avAudioRecorder prepareToRecord]) {
        NSLog(@"创建一个音频文件，并准备系统进行录制");
    }
}

- (void)start
{
    [self setUp];
    [self.avAudioRecorder record];
    self.startRecordTime = [[NSDate date] timeIntervalSince1970];
    
}

- (void)stop
{
    [_avAudioRecorder stop];
    self.recordTime = [[NSDate date] timeIntervalSince1970] - self.startRecordTime;
    
}

- (NSData *)getRecordData
{
    NSData *recordData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:self.resourcePath]];
    return  recordData;
}


- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    //录音结束时，应根据程序需要更改category为AVAudioSessionCategoryAmbient，AVAudioSessionCategorySoloAmbient或AVAudioSessionCategoryPlayback中的一种
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error: nil];
    //通知到其他应用
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    !self.recordSuccessBlock ? : self.recordSuccessBlock(self.resourcePath,self.recordTime);
    NSLog(@"录音结束");
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    //录音结束时，应根据程序需要更改category为AVAudioSessionCategoryAmbient，AVAudioSessionCategorySoloAmbient或AVAudioSessionCategoryPlayback中的一种
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error: nil];
    //通知到其他应用
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    !self.recordFailBlock ? : self.recordFailBlock();
    NSLog(@"编码错误");
}

// 获取沙盒路径
- (NSString *)filePath {
  
    NSString *temPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    NSString *time = [NSString stringWithFormat:@"%0.f",[[NSDate date] timeIntervalSince1970]];
    NSString *filePath = [temPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.wav",time]];//caf
    return filePath;
}


@end
