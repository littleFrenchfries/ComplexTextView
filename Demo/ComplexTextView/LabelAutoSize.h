//
//  LabelAutoSize.h
//  MOA_IOS
//
//  Created by zxjk on 16/3/10.
//  Copyright © 2016年 韩昶东. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface LabelAutoSize : NSObject
/**
 *  自适应高度
 *
 *  @param text  文字内容
 *  @param frame label的frame
 *  @param font  字体大小
 *
 *  @return 高度
 */
+(CGRect)returnLabelHeightWithText:(NSString *)text frame:(CGRect)frame font:(UIFont *)font;
/**
 *  自适应宽度
 *
 *  @param text  文字内容
 *  @param frame label的frame
 *  @param font  字体大小
 *
 *  @return 宽度
 */
+(CGRect)returnLabelWidthWithText:(NSString *)text frame:(CGRect)frame font:(UIFont *)font;

+(float)heightForString:(NSString *)value fontSize:(float)fontSize andWidth:(float)width;//根据字符串的的长度来计算UITextView的高度
@end
