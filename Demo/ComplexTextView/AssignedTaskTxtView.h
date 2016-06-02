//
//  ComplexTextEditeView.h
//  MOA_IOS
//
//  Created by zxjk on 16/4/13.
//  Copyright © 2016年 韩昶东. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmojiTextAttachment.h"
@protocol  AssignedTaskTxtViewDelegate<NSObject>
/**
 *  代理用来获取textView中图片被点击的方法
 *
 *  @param model 返回一个图片对象的模型
 */
-(void)InViewDidClick:(EmojiTextAttachment *)model;

@end

@interface AssignedTaskTxtView : UIView
@property(nonatomic,copy)void(^myBlock)(CGFloat height);
@property(nonatomic,weak)id<AssignedTaskTxtViewDelegate>delegate;
/**
 *  textView的编辑高度
 */
@property(nonatomic,assign)CGFloat TextEditeViewHeight;
/**
 *  获取textView中的全部字符串，内部包含图片以及录音的替代字符串
 */
-(NSString *)getString;
/**
 *  获取用来存储图片对象的数组
 */
-(NSArray *)getDataArray;
/**
 *  向textView中插入一段字符串
 */
-(void)insertNSString:(NSString *)string;
/**
 *  向textView中插入一张图片
 *
 *  @param InView   要插入的图片
 *  @param type     图片的类型  （图片  或者  录音图片）
 *  @param filePath 录音文件的路径
 */
-(void)insertView:(UIImage *)InView type:(NSString *)type filePath:(NSString *)filePath;
/**
 *  录音完成之后要替换的图片
 *
 *  @param newImage 录音完成图片
 */
-(void)replaceViewInNowRange:(UIImage *)newImage;
/**
 *  返回当前textView的高度
 *
 *  @param block 用来回传textView的高度
 */
-(void)returnCellHeight:(void(^)(CGFloat height))block;
/**
 *  得到textView中全部的 图片对象
 */
-(NSArray<EmojiTextAttachment *>*)getAttachments;
@end
