//
//  ViewController.m
//  ComplexTextView
//
//  Created by zxjk on 16/6/2.
//  Copyright © 2016年 zxjk. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view, typically from a nib.
}


/**
 *  将View转化成Image
 *
 *  @param myView View
 *
 *  @return image
 */
-(UIImage *)ViewToImage:(UIView *)myView{
    UIGraphicsBeginImageContext(myView.bounds.size);
    [myView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return viewImage;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
