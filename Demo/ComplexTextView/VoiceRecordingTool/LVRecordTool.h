//
//  LVRecordTool.h
//  RecordAndPlayVoice
//
//  Created by PBOC CS on 15/3/14.
//  Copyright (c) 2015年 liuchunlao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
typedef enum : NSUInteger {
    STOP,
    PLAY,
} PLAYERTYPE;

@class LVRecordTool;
@protocol LVRecordToolDelegate <NSObject>

@optional
- (void)recordTool:(LVRecordTool *)recordTool didstartRecoring:(int)no;
- (void)returnPlayerStatues:(PLAYERTYPE)statues;

@end

@interface LVRecordTool : NSObject

/** 录音工具的单例 */
+ (instancetype)sharedRecordTool;

/** 开始录音 */
- (void)startRecording;

/** 停止录音 */
- (void)stopRecording;

/** 播放录音文件 会生成进度条 */
- (void)playRecordingFileInView:(UIView *)view;

/**
 *  单单播放录音文件
 */
- (void)onlyPlayRecordingFile;


/** 停止播放录音文件 */
- (void)stopPlaying;

/** 销毁录音文件 */
- (void)destructionRecordingFile;


/**
 *  停止播放并删除播放显示器
 *
 *  @param btn 参数请传nil
 */
-(void)finishClick:(UIButton *)btn;

/** 录音对象 */
@property (nonatomic, strong) AVAudioRecorder *recorder;

/** 播放器对象 */
@property (nonatomic, strong) AVAudioPlayer *player;

/** 录音文件地址 url*/
/**
 *  请设置该路径   （如果要用其默认路径，请将其置nil）
 */
@property (nonatomic, strong) NSURL *recordFileUrl;
/**
 *  录音文件地址
 *
 */
@property(nonatomic,copy)NSString * recordFile;
/**
 *  MP3录音文件地址
 */
@property(nonatomic,strong)NSURL * mp3FilePath;
/** 更新图片的代理 */
@property (nonatomic, assign) id<LVRecordToolDelegate> delegate;

@end
