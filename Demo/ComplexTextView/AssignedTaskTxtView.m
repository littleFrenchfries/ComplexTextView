//
//  ComplexTextEditeView.m
//  MOA_IOS
//
//  Created by zxjk on 16/4/13.
//  Copyright © 2016年 韩昶东. All rights reserved.
//

#import "AssignedTaskTxtView.h"
#import "LabelAutoSize.h"
#import "EmojiTextAttachment.h"
#import "NSAttributedString+EmojiExtension.h"
#import "LVRecordTool.h"
#define FIELURL @"[fileUrl=]photo%ld[fileUrl=]"
#import "CustomTxtView.h"

#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width

@interface AssignedTaskTxtView()<UITextViewDelegate>
{
    int urlLength;
    CGFloat txt_height;
}
@property(nonatomic,strong)CustomTxtView * textView;
@property(nonatomic,strong)UITextView * placeHodler;
@property(nonatomic,assign)NSRange range;
@property(nonatomic,strong)NSMutableArray * dataSource;
@end

@implementation AssignedTaskTxtView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        self.textView = [[CustomTxtView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        txt_height = self.frame.size.height;
        self.textView.delegate = self;
        //        self.textView.scrollEnabled = NO;
        [self.textView setEditable:YES];
        self.textView.backgroundColor = [UIColor clearColor];
        self.textView.text = @"";
        self.textView.font = [UIFont systemFontOfSize:14];
        //        self.textView.autoresizingMask = UIViewAutoresizingFlexibleHeight;//自适应高度
        self.placeHodler = [[UITextView alloc]initWithFrame:self.textView.frame];
        self.TextEditeViewHeight = frame.size.height;
        self.placeHodler.text = @"请输入...";
        [self addSubview:self.placeHodler];
        [self addSubview:self.textView];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        //增加监听，当键退出时收出消息
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
    return self;
}
//当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat height = keyboardRect.size.height;
    CGRect origleRect = self.textView.frame;
    
    self.textView.frame = CGRectMake(origleRect.origin.x, origleRect.origin.y, origleRect.size.width, txt_height-height);
    
    CGRect origleRect1 = self.frame;
    self.frame = CGRectMake(origleRect1.origin.x, origleRect1.origin.y, origleRect1.size.width, txt_height-height);
    self.TextEditeViewHeight = origleRect1.size.height-height;
    
}

//当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification
{
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat height = keyboardRect.size.height;
    CGRect origleRect = self.textView.frame;
    
    
    self.textView.frame = CGRectMake(origleRect.origin.x, origleRect.origin.y, origleRect.size.width, origleRect.size.height+height);
    CGRect origleRect1 = self.frame;
    self.frame = CGRectMake(origleRect1.origin.x, origleRect1.origin.y, origleRect1.size.width, origleRect1.size.height+height);
    self.TextEditeViewHeight = origleRect1.size.height+height;
    
}
-(void)insertNSString:(NSString *)string{
    self.placeHodler.hidden = YES;
    [self.textView.text stringByReplacingCharactersInRange:self.textView.selectedRange withString:string];
    NSMutableString *plainString = [NSMutableString stringWithString:self.textView.textStorage.string];
    [plainString appendString:string];
    self.textView.text = plainString;
    for (EmojiTextAttachment * model in self.dataSource) {
        [self.textView.textStorage insertAttributedString:[NSAttributedString attributedStringWithAttachment:model] atIndex:model.selectedRange.location];
    }
    
    self.textView.font = [UIFont systemFontOfSize:14];
}
-(void)insertView:(UIImage *)InView type:(NSString *)type filePath:(NSString *)filePath{
    EmojiTextAttachment *emojiTextAttachment = [EmojiTextAttachment new];
    
    //Set tag and image
    if ([type isEqualToString:@"aac"]&&(filePath!=nil)) {
        emojiTextAttachment.emojiTag = [NSString stringWithFormat:@"[fileUrl=]%@[fileUrl=]",filePath];
    }else{
        emojiTextAttachment.emojiTag = [NSString stringWithFormat:FIELURL,self.dataSource.count];
    }
    
    emojiTextAttachment.image = InView;
    emojiTextAttachment.type = type;
    emojiTextAttachment.selectedRange = self.textView.selectedRange;
    //Set emoji size
    emojiTextAttachment.emojiSize = CGSizeMake(SCREENWIDTH-10*4, InView.size.height);
    [self.dataSource addObject:emojiTextAttachment];
    [self.textView.textStorage insertAttributedString:[NSAttributedString attributedStringWithAttachment:emojiTextAttachment] atIndex:self.textView.selectedRange.location];
    
    NSRange range = self.textView.selectedRange;
    self.textView.selectedRange = NSMakeRange(range.location+1000000000000000, emojiTextAttachment.emojiSize.width);
    self.placeHodler.hidden = YES;
    self.textView.backgroundColor = [UIColor whiteColor];
    
    [self resetTextStyle];
    self.textView.font = [UIFont systemFontOfSize:14];
}
-(void)replaceViewInNowRange:(UIImage *)newImage{
    
    for (NSInteger i = self.dataSource.count-1; i>=0; i--) {
        EmojiTextAttachment * attachment1 = self.dataSource[i];
        if ([attachment1.type isEqualToString:@"aac"]) {
            attachment1.image = newImage;
            attachment1.emojiTag = [NSString stringWithFormat:@"[fileUrl=]%@[fileUrl=]",[LVRecordTool sharedRecordTool].recordFile];
            break;
        }
    }
    [self.textView replaceRange:self.textView.selectedTextRange withText:@""];
}
/**
 *  点击图片触发代理事件
 */
- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange
{
    for (EmojiTextAttachment * attachment in self.dataSource) {
        if (attachment==textAttachment) {
            if (self.delegate) {
                [self.delegate InViewDidClick:attachment];
            }
        }
    }
    return NO;
}

-(void)returnCellHeight:(void (^)(CGFloat))block{
    if (block) {
        self.myBlock = [block copy];
    }
}

-(NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc]init];
    }
    return _dataSource;
}
- (void)resetTextStyle {
    //After changing text selection, should reset style.
    NSRange wholeRange = NSMakeRange(0, _textView.textStorage.length);
    
    [_textView.textStorage removeAttribute:NSFontAttributeName range:wholeRange];
    
    [_textView.textStorage addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:22.0f] range:wholeRange];
}
-(NSString *)getString{
    return [self.textView.textStorage getPlainString];
}
-(NSArray *)getDataArray{
    return self.dataSource;
}



#pragma mark -----textViewDelegate
-(void)textViewDidChange:(UITextView *)textView{
    if (textView.text.length==0) {
        self.placeHodler.hidden = NO;
        self.textView.backgroundColor = [UIColor clearColor];
    }else{
        self.placeHodler.hidden = YES;
        self.textView.backgroundColor = [UIColor whiteColor];
    }
}
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    if (self.myBlock) {
        self.myBlock(self.TextEditeViewHeight);
    }
    return YES;
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    return YES;
}
-(void)textViewDidEndEditing:(UITextView *)textView{
    if (self.myBlock) {
        self.myBlock(self.TextEditeViewHeight);
    }
    textView.editable = NO;
}
-(NSArray<EmojiTextAttachment *>*)getAttachments{
    return [self.textView.textStorage getAllAttachments];
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
