//
//  ALLiveVC.m
//  ALRotate
//
//  Created by iVermisseDich on 2017/7/12.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "ALLiveVC.h"
#import <libksygpulive/libksygpulive.h>
#import "KSYGPUStreamerkit.h"

#define kScreenWidth        [UIScreen mainScreen].bounds.size.width
#define kScreenHeight       [UIScreen mainScreen].bounds.size.height

#define kSystemVersion      [[[UIDevice currentDevice] systemVersion] floatValue]
#define IOS8_OR_LATER       (kSystemVersion >= 8)
#define kStreamRUL            @"rtmp://test.uplive.ks-cdn.com/live/abc"

// 是否开启动态旋转
#define kUseAutoRotate NO

@interface ALLiveVC ()
@property (nonatomic) UIView *bgView;
@property (nonatomic) KSYGPUStreamerKit *kit;
@end

@implementation ALLiveVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    _kit = [[KSYGPUStreamerKit alloc] initWithDefaultCfg];
    
    _bgView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_bgView];
    [self.view sendSubviewToBack:_bgView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self layoutUI];
    
    // 开启预览
    [_kit startPreview:_bgView];
    
    [_kit setStreamOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

- (void)layoutUI{
    // size
    CGFloat minLength = MIN(kScreenWidth, kScreenHeight);
    CGFloat maxLength = MAX(kScreenWidth, kScreenHeight);
    CGRect newFrame;
    // frame
    CGAffineTransform newTransform;
    
    UIInterfaceOrientation currentInterfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (currentInterfaceOrientation == UIInterfaceOrientationPortrait) {
        newTransform = CGAffineTransformIdentity;
        newFrame = CGRectMake(0, 0, minLength, maxLength);
    } else {
        newTransform = CGAffineTransformMakeRotation(M_PI_2*(currentInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ? 1 : -1));
        newFrame = CGRectMake(0, 0, maxLength, minLength);
    }
    
    _bgView.transform = newTransform;
    _bgView.frame = newFrame;
}

#pragma mark - Actions
- (IBAction)didClickStreamBtn:(UIButton *)sender {
    // 开始推流
    [_kit.streamerBase startStream:[NSURL URLWithString:kStreamRUL]];
}

- (IBAction)didClickRotateBtn:(UIButton *)sender {
    // 向右旋转
    UIInterfaceOrientation orient = [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait ? UIInterfaceOrientationLandscapeLeft: UIInterfaceOrientationPortrait;
    [[UIApplication sharedApplication] setStatusBarOrientation:orient];
    [_kit rotateStreamTo:orient];
}

#pragma mark - UIViewController Rotation
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    // size
    CGFloat minLength = MIN(kScreenWidth, kScreenHeight);
    CGFloat maxLength = MAX(kScreenWidth, kScreenHeight);
    CGRect newFrame;
    
    // frame
    CGAffineTransform newTransform;
    // need stay frame after animation
    CGAffineTransform newTransformOfStay;
    // whether need to stay
    BOOL needStay;
    
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        newTransform = CGAffineTransformIdentity;
        newFrame = CGRectMake(0, 0, minLength, maxLength);
    } else {
        if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {
            newTransform = CGAffineTransformMakeRotation(M_PI_2*(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ? 1 : -1));
        } else {
            needStay = YES;
            if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
                newTransform = CGAffineTransformRotate(_bgView.transform,M_PI * 1.00001);
                newTransformOfStay = CGAffineTransformRotate(_bgView.transform, M_PI);
            }else{
                newTransform = CGAffineTransformRotate(_bgView.transform,IOS8_OR_LATER ? 1.00001 * M_PI : M_PI * 0.99999);
                newTransformOfStay = CGAffineTransformRotate(_bgView.transform, M_PI);
                
            }
        }
        newFrame = CGRectMake(0, 0, maxLength, minLength);
    }
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:duration animations:^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return ;
        }
        strongSelf.bgView.transform = newTransform;
        strongSelf.bgView.frame = newFrame;
    }completion:^(BOOL finished) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (!strongSelf) {
            return ;
        }
        strongSelf.bgView.frame = strongSelf.bgView.superview.bounds;
    }];
    
    // 旋转推流方向
    [_kit rotateStreamTo:toInterfaceOrientation];
}

#pragma mark - iOS_8_OR_LATER
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    // size
    CGFloat minLength = MIN(kScreenWidth, kScreenHeight);
    CGFloat maxLength = MAX(kScreenWidth, kScreenHeight);
    CGRect newFrame;
    
    // frame
    CGAffineTransform newTransform;
    // need stay frame after animation
    CGAffineTransform newTransformOfStay;
    // whether need to stay
    BOOL needStay;
    
    UIInterfaceOrientation currentInterfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    UIDeviceOrientation toDeviceOrientation = [UIDevice currentDevice].orientation;
    
    if (toDeviceOrientation == UIDeviceOrientationPortrait) {
        newTransform = CGAffineTransformIdentity;
        newFrame = CGRectMake(0, 0, minLength, maxLength);
    } else {
        if (currentInterfaceOrientation == UIInterfaceOrientationPortrait) {
            newTransform = CGAffineTransformMakeRotation(M_PI_2*(toDeviceOrientation == UIDeviceOrientationLandscapeRight ? 1 : -1));
        } else {
            needStay = YES;
            if (currentInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
                newTransform = CGAffineTransformRotate(_bgView.transform, M_PI * 1.00001);
                newTransformOfStay = CGAffineTransformRotate(_bgView.transform, M_PI);
            }else{
                newTransform = CGAffineTransformRotate(_bgView.transform, IOS8_OR_LATER ? 1.00001 * M_PI : M_PI * 0.99999);
                newTransformOfStay = CGAffineTransformRotate(_bgView.transform, M_PI);
            }
        }
        newFrame = CGRectMake(0, 0, maxLength, minLength);
    }
    
    __weak typeof(self) weakSelf = self;
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return ;
        }
        strongSelf.bgView.transform = newTransform;
        strongSelf.bgView.frame =  newFrame;
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (!strongSelf) {
            return ;
        }
        if (needStay) {
            strongSelf.bgView.transform = newTransformOfStay;
        }
        strongSelf.bgView.frame = strongSelf.bgView.superview.bounds;
    }];
    
    // 旋转推流方向
    [_kit rotateStreamTo:(UIInterfaceOrientation)toDeviceOrientation];
}

- (BOOL)shouldAutorotate{
    return kUseAutoRotate;
}

@end
