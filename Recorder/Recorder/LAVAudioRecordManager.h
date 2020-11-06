//
//  LAVAudioRecordManager.h
//  Recorder
//
//  Created by Alan on 2020/11/5.
//
/**
 Privacy - Microphone Usage Description infoplist一定要加入
 

 */
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LAVAudioRecordManager : NSObject

@property(nonatomic, copy) void(^recordSuccessBlock)(NSString *filePath,double timeLength);

@property(nonatomic, copy) void(^recordFailBlock)(void);

@property(nonatomic, readonly) NSString *resourcePath;

@property(nonatomic, readonly) double recordTime;

+ (instancetype)shareAVRecorder;

- (void)start;

- (void)stop;

- (NSData *)getRecordData;



@end

NS_ASSUME_NONNULL_END
