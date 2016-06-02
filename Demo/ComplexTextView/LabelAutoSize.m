//
//  LabelAutoSize.m
//  MOA_IOS
//
//  Created by zxjk on 16/3/10.
//  Copyright © 2016年 韩昶东. All rights reserved.
//

#import "LabelAutoSize.h"

@implementation LabelAutoSize
+(CGRect)returnLabelHeightWithText:(NSString *)text frame:(CGRect)frame font:(UIFont *)font{
    CGSize size = CGSizeMake(frame.size.width, 20000);
    if (text == nil || [text isEqual:[NSNull null]]) {
        text = @"";
    }
    CGSize labelSize = [text sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByCharWrapping];
    return CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, labelSize.height);
}
+(CGRect)returnLabelWidthWithText:(NSString *)text frame:(CGRect)frame font:(UIFont *)font{
    CGSize size = CGSizeMake(200000, frame.size.height);
    if (text == nil || [text isEqual:[NSNull null]]) {
        text = @"";
    }
    CGSize labelSize = [text sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByCharWrapping];
    return CGRectMake(frame.origin.x, frame.origin.y, labelSize.width, frame.size.height);
}
+(float)heightForString:(NSString *)value fontSize:(float)fontSize andWidth:(float)width//根据字符串的的长度来计算UITextView的高度
{
    float height = [[NSString stringWithFormat:@"%@\n ",value] boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:fontSize],NSFontAttributeName, nil] context:nil].size.height;
    
    return height;
}
@end
