//
//  ViewController.m
//  Recorder
//
//  Created by Alan on 2020/11/5.
//

#import "ViewController.h"

#import "LAVAudioRecordManager.h"
#import "LAVAudioPlayerManager.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   

    UIButton *recordButton = [[UIButton alloc] initWithFrame:CGRectMake(150, 100, 100, 100)];
    [recordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    recordButton.backgroundColor = [UIColor redColor];
    [recordButton setTitle:@"录音" forState:UIControlStateNormal];
    [recordButton addTarget:self action:@selector(startRecode:) forControlEvents:UIControlEventTouchDown];
    [recordButton addTarget:self action:@selector(stopRecode:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:recordButton];
    
    UIButton *playButton = [[UIButton alloc] initWithFrame:CGRectMake(150, 260, 100, 100)];
    [playButton setTitle:@"播放" forState:UIControlStateNormal];
    [playButton setTitle:@"停止" forState:UIControlStateSelected];
    [playButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    playButton.backgroundColor = [UIColor greenColor];
    [playButton addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playButton];
    
    
    
    //需要检测会话被其他app打断通知
    NSNotificationCenter *nsnc = [NSNotificationCenter defaultCenter];
            [nsnc addObserver:self selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];

}

//处理回调
- (void)handleInterruption: (NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    AVAudioSessionInterruptionType type = [info[AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    
    if (type == AVAudioSessionInterruptionTypeBegan) {
        NSLog(@"           被中断");
        //可以做停止采集操作
    }else if (type == AVAudioSessionInterruptionTypeEnded) {
        NSLog(@"    中断已结束");
            
    } else {
       // Handle
        AVAudioSessionInterruptionOptions options = [info[AVAudioSessionInterruptionOptionKey] unsignedIntegerValue];
        if (options == AVAudioSessionInterruptionOptionShouldResume) {//:表示此时也应该恢复继续播放和采集。
           
        }
    }
}


- (void)startRecode:(UIButton *)button
{
    [button setTitle:@"录音中" forState:UIControlStateNormal];
    [LAVAudioRecordManager shareAVRecorder].recordSuccessBlock = ^(NSString * _Nonnull filePath, double timeLength) {
        NSLog(@"====录音成功   路径：%@ 时间：%0.f",filePath,timeLength);
    };
    
    [LAVAudioRecordManager shareAVRecorder].recordFailBlock = ^{
        NSLog(@"=====录音失败");
    };
    
    [[LAVAudioRecordManager shareAVRecorder] start];
}

- (void)stopRecode:(UIButton *)button
{
    [button setTitle:@"录音" forState:UIControlStateNormal];
    NSLog(@"离开录音按钮");
    [[LAVAudioRecordManager shareAVRecorder] stop];
}

- (void)play:(UIButton *)button
{
    button.selected = !button.selected;
 
    if (button.selected) {
       
        [LAVAudioPlayerManager shareAudioPalyerManager].playFilePath = [LAVAudioRecordManager shareAVRecorder].resourcePath;
        
        //NSData *data = [[LAVAudioRecordManager shareAVRecorder] getRecordData];
        
        [[LAVAudioPlayerManager shareAudioPalyerManager] play];
    }else{
        [[LAVAudioPlayerManager shareAudioPalyerManager] stop];
    }
}

@end
