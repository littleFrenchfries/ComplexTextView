//
//  LVRecordTool.m
//  RecordAndPlayVoice
//
//  Created by PBOC CS on 15/3/14.
//  Copyright (c) 2015年 liuchunlao. All rights reserved.
//

#define LVRecordFielName @"lvRecord.wav"
#define INIMAGEVIEWWITH (SCREENWIDTH-10*4)
#import "LVRecordTool.h"
#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
@interface LVRecordTool () <AVAudioRecorderDelegate,AVAudioPlayerDelegate>
{
    UISlider *progressV;      //播放进度
}



/** 定时器 */
@property (nonatomic, strong) NSTimer *timer;

@property(nonatomic,strong)UIView * soundPlayTool;

@property(nonatomic,strong)UIButton * stopBtn;


@property(nonatomic,strong)UILabel * currentTime;

@property(nonatomic,strong)UILabel * allTime;
@end

@implementation LVRecordTool

- (void)startRecording {
    // 录音时停止播放 删除曾经生成的文件
    [self stopPlaying];
//    [self destructionRecordingFile];
    
    //准备录音
    if ([self.recorder prepareToRecord]){
        
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        
        //开始录音
        [self.recorder record];
    }

    NSTimer *timer = [NSTimer timerWithTimeInterval:0.01 target:self selector:@selector(updateImage) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    [timer fire];
    self.timer = timer;
    
}

- (void)updateImage {
    
    [self.recorder updateMeters];
    double lowPassResults = pow(10, (0.05 * [self.recorder peakPowerForChannel:0]));
    float result  = 10 * (float)lowPassResults;
    NSLog(@"%f", result);
    int no = 0;
    if (result > 0 && result <= 1.3) {
        no = 1;
    } else if (result > 1.3 && result <= 2) {
        no = 2;
    } else if (result > 2 && result <= 3.0) {
        no = 3;
    } else if (result > 3.0 && result <= 3.0) {
        no = 4;
    } else if (result > 5.0 && result <= 10) {
        no = 5;
    } else if (result > 10 && result <= 40) {
        no = 6;
    } else if (result > 40) {
        no = 7;
    }
    
    if ([self.delegate respondsToSelector:@selector(recordTool:didstartRecoring:)]) {
        [self.delegate recordTool:self didstartRecoring: no];
    }
}

- (void)stopRecording {
    [self.recorder stop];
    [self.timer invalidate];
}

- (void)playRecordingFileInView:(UIView *)view {
    // 播放时停止录音
//    [self.recorder stop];
    
    // 正在播放就返回
    if ([self.player isPlaying]) return;
    //初始化播放器的时候如下设置
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                            sizeof(sessionCategory),
                            &sessionCategory);
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                             sizeof (audioRouteOverride),
                             &audioRouteOverride);
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //默认情况下扬声器播放
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recordFileUrl error:nil];
    self.player.delegate = self;
    //预播放
    self.player.volume=40;
    //添加近距离事件监听，添加前先设置为YES，如果设置完后还是NO的读话，说明当前设备没有近距离传感器
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    if ([UIDevice currentDevice].proximityMonitoringEnabled == YES) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:)name:UIDeviceProximityStateDidChangeNotification object:nil];
    }
    [self.player play];
    if (view) {
        [view addSubview:self.soundPlayTool];
    }
    [self.timer invalidate];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(playProgress) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    self.timer = timer;
}
//播放进度条
- (void)playProgress
{
    //通过音频播放时长的百分比,给progressview进行赋值;
    progressV.value = self.player.currentTime;
    self.currentTime.text = [NSString stringWithFormat:@"%.2d :%.2d",[self getMinutes:(int)floorf(self.player.currentTime)],[self getSecond:(int)floorf(self.player.currentTime)]];
}

//播放完成时调用的方法  (代理里的方法),需要设置代理才可以调用
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self.timer setFireDate:[NSDate distantFuture]];//NSTimer暂停   invalidate  使...无效;
    //删除近距离事件监听
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    if ([UIDevice currentDevice].proximityMonitoringEnabled == YES) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
    }
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    self.stopBtn.selected = YES;
    progressV.value = 0;
    if (self.delegate) {
        [self.delegate returnPlayerStatues:STOP];
    }
}

-(void)onlyPlayRecordingFile{
    // 播放时停止录音
//    [self.recorder stop];
    
    // 正在播放就返回
    if ([self.player isPlaying]) return;
//    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:nil];
//    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    //初始化播放器的时候如下设置
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                            sizeof(sessionCategory),
                            &sessionCategory);
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                             sizeof (audioRouteOverride),
                             &audioRouteOverride);
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //默认情况下扬声器播放
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recordFileUrl error:NULL];
    self.player.delegate = self;
    self.player.volume=60;
//    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
//    
//    //添加监听
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//     
//                                             selector:@selector(sensorStateChange:)
//     
//                                                 name:@"UIDeviceProximityStateDidChangeNotification"
//     
//                                               object:nil];
    //添加近距离事件监听，添加前先设置为YES，如果设置完后还是NO的读话，说明当前设备没有近距离传感器
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    if ([UIDevice currentDevice].proximityMonitoringEnabled == YES) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:)name:UIDeviceProximityStateDidChangeNotification object:nil];
    }
    [self.player play];
    if (self.delegate&&[self.delegate respondsToSelector:@selector(returnPlayerStatues:)]) {
        [self.delegate returnPlayerStatues:PLAY];
    }
}
- (void)stopPlaying {
    [self.player pause];
    
//    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
//    
//    //删除监听
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
    //删除近距离事件监听
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    if ([UIDevice currentDevice].proximityMonitoringEnabled == YES) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
    }
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    self.stopBtn.selected = YES;
    [self.timer setFireDate:[NSDate distantFuture]];
    if (self.delegate) {
        [self.delegate returnPlayerStatues:STOP];
    }
}

//处理监听触发事件

-(void)sensorStateChange:(NSNotificationCenter *)notification;

{
    
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    
    if ([[UIDevice currentDevice] proximityState] == YES)
        
    {
        self.player.volume = 10;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
    
    else
        
    {
        self.player.volume = 50;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
    
}

static id instance;
#pragma mark - 单例
+ (instancetype)sharedRecordTool {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[self alloc] init];
        }
    });
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [super allocWithZone:zone];
        }
    });
    return instance;
}

#pragma mark - 懒加载
- (AVAudioRecorder *)recorder {
    if (!_recorder) {
        
        // 真机环境下需要的代码
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *sessionError;
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
        
        if(session == nil)
            NSLog(@"Error creating session: %@", [sessionError description]);
        else
            [session setActive:YES error:nil];
        
        if (!self.recordFileUrl) {
            // 1.获取沙盒地址
            NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            NSString *filePath = [path stringByAppendingPathComponent:LVRecordFielName];
            self.recordFileUrl = [NSURL fileURLWithPath:filePath];
            
        }
        _recorder = [[AVAudioRecorder alloc] initWithURL:self.recordFileUrl settings:[LVRecordTool GetAudioRecorderSettingDict] error:NULL];
        _recorder.delegate = self;
        _recorder.meteringEnabled = YES;
        
        
    }
    return _recorder;
}

- (void)destructionRecordingFile {

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (self.recordFileUrl) {
        [fileManager removeItemAtURL:self.recordFileUrl error:NULL];
    }
}

#pragma mark - AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    if (flag) {
    }else{
    }
}
-(UIView *)soundPlayTool{
    if (!_soundPlayTool) {
        _soundPlayTool = [[UIView alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-44-64, SCREENWIDTH, 44)];
        UIView * lineView= [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 0.5)];
        lineView.backgroundColor = [UIColor colorWithWhite:0.816 alpha:1.000];
        [_soundPlayTool addSubview:lineView];

        _soundPlayTool.backgroundColor = [UIColor whiteColor];
        self.stopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.stopBtn setImage:[UIImage imageNamed:@"059-暂停键"] forState:UIControlStateNormal];
        [self.stopBtn setImage:[UIImage imageNamed:@"059-暂停键"] forState:UIControlStateHighlighted];
        [self.stopBtn setImage:[UIImage imageNamed:@"060-播放键"] forState:UIControlStateSelected];
        [self.stopBtn setImage:[UIImage imageNamed:@"060-播放键"] forState:UIControlStateSelected|UIControlStateHighlighted];
        [self.stopBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        self.stopBtn.frame = CGRectMake(0, 0, 44, 44);
        [self.stopBtn addTarget:self action:@selector(stopPlayed:) forControlEvents:UIControlEventTouchUpInside];
        [_soundPlayTool addSubview:self.stopBtn];
        
        self.currentTime = [[UILabel alloc]initWithFrame:CGRectMake(self.stopBtn.frame.origin.x+self.stopBtn.frame.size.width, 0, 50,44)];
        self.currentTime.font = [UIFont systemFontOfSize:14];
        self.currentTime.textColor = [UIColor grayColor];
        [_soundPlayTool addSubview:self.currentTime];
        //初始化一个播放进度条
        progressV = [[UISlider alloc] initWithFrame:CGRectMake(self.currentTime.frame.origin.x+self.currentTime.frame.size.width, (44-20)/2.0, INIMAGEVIEWWITH-204, 20)];
        [progressV addTarget:self action:@selector(changeProgressValue:) forControlEvents:UIControlEventValueChanged];
        [_soundPlayTool addSubview:progressV];
        
        self.allTime = [[UILabel alloc]initWithFrame:CGRectMake(progressV.frame.origin.x+progressV.frame.size.width, 0, 50, 44)];
        self.allTime.font = [UIFont systemFontOfSize:14];
        self.allTime.textColor = [UIColor grayColor];
        [_soundPlayTool addSubview:self.allTime];
    }
    self.stopBtn.selected = NO;
    progressV.minimumValue = 0;
    progressV.maximumValue = self.player.duration;
    self.currentTime.text = @"00:00";
    self.allTime.text = [NSString stringWithFormat:@"%.2d :%.2d",[self getMinutes:(int)floorf(self.player.duration)],[self getSecond:(int)floorf(self.player.duration)]];
    [_soundPlayTool removeFromSuperview];
  
    UIButton * finishBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [finishBtn setTitle:@"取消" forState:UIControlStateNormal];
    [finishBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    finishBtn.titleLabel.font= [UIFont systemFontOfSize:14];
    [finishBtn addTarget:self action:@selector(finishClick:) forControlEvents:UIControlEventTouchUpInside];
    finishBtn.frame = CGRectMake(self.allTime.frame.origin.x+self.allTime.frame.size.width, 0, 44, 44);
    [_soundPlayTool addSubview:finishBtn];
    return _soundPlayTool;
}
-(void)changeProgressValue:(UISlider *)slider{
    [self.player pause];
    [self.timer setFireDate:[NSDate distantFuture]];
    self.player.currentTime = slider.value;
    self.currentTime.text = [NSString stringWithFormat:@"%.2d :%.2d",[self getMinutes:(int)floorf(self.player.currentTime)],[self getSecond:(int)floorf(self.player.currentTime)]];
    if (self.stopBtn.selected == YES) {
        
    }else{
        [self.player play];
        [self.timer setFireDate:[NSDate distantPast]];
    }
}
-(int)getSecond:(int)second{
    return second%60;
}
-(int)getMinutes:(int)second{
    return second/60;
}
-(void)finishClick:(UIButton *)btn{
    [self stopPlaying];
    [self.timer invalidate];
    [self.soundPlayTool removeFromSuperview];
}
-(void)stopPlayed:(UIButton *)btn{
    
    btn.selected = !btn.selected;
    if (!btn.selected) {
        if (self.player.currentTime == self.player.duration) {
            [self playRecordingFileInView:nil];
        }
        [self.player play];
        [self.timer setFireDate:[NSDate distantPast]];
    }else{
       [self stopPlaying];
    }
}
-(void)setRecordFileUrl:(NSURL *)recordFileUrl{
    if (_recordFileUrl ==recordFileUrl) {
        
    }else
    {
        self.recorder = nil;
    }
    _recordFileUrl = recordFileUrl;
    
}
//获取录音设置
+ (NSDictionary*)GetAudioRecorderSettingDict{
    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   [NSNumber numberWithFloat: 8000.0],AVSampleRateKey, //采样率
                                   [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                   [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,//采样位数 默认 16
                                   [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,//通道的数目
                                   nil];
    return recordSetting;
}
@end
