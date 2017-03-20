//
//  ViewController.m
//  ALAutoLayout
//
//  Created by iVermisseDich on 2017/3/16.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "ViewController.h"
#import "ALRotateVC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    ALRotateVC *rotateVC = [[ALRotateVC alloc] init];
    [self presentViewController:rotateVC animated:YES completion:nil];
}

- (BOOL)shouldAutorotate{
    return YES;
}

@end
