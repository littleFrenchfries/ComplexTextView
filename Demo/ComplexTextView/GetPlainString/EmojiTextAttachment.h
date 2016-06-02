//
//  EmojiTextAttachment.h
//  InputEmojiExample
//
//  Created by zorro on 15/3/7.
//  Copyright (c) 2015年 tutuge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmojiTextAttachment : NSTextAttachment
@property(strong, nonatomic) NSString *emojiTag;
@property(nonatomic,copy)NSString * type;
@property(assign, nonatomic) CGSize emojiSize;  //For emoji image size
@property(nonatomic,assign)NSRange selectedRange;
@end
