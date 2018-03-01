



//
//  CustomTxtView.m
//  MOA_IOS
//
//  Created by zxjk on 16/4/15.
//  Copyright © 2016年 韩昶东. All rights reserved.
//

#import "CustomTxtView.h"

@implementation CustomTxtView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    
    return self;
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    
    //points are falling 10 pixels below where they should be, this adjust the point to where it needs to be.
    touchPoint.y -= 10;
    
    NSInteger characterIndex = [self.layoutManager characterIndexForPoint:touchPoint inTextContainer:self.textContainer fractionOfDistanceBetweenInsertionPoints:0];
    
    if(characterIndex != 0)
    {
        //calculate the start and stop of the word
        NSRange start = [self.text rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] options:NSBackwardsSearch range:NSMakeRange(0, characterIndex)];
        NSRange stop = [self.text rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] options:NSCaseInsensitiveSearch range:NSMakeRange(characterIndex, self.text.length-characterIndex)];
        
        int length =  (int)(stop.location - start.location);
        if (length>=0) {
            self.editable = YES;
            
            [self becomeFirstResponder];
        }else{
            self.editable=NO;
        }
        
        
    }else{
        self.editable = YES;
        [self becomeFirstResponder];
    }
    
    [super touchesBegan: touches withEvent: event];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
