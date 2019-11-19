//
//  ViewController.m
//  faceID
//
//  Created by dd luo on 2019/11/7.
//  Copyright © 2019 dd luo. All rights reserved.
//

#import "ViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "PUSHViewController.h"

@interface ViewController ()
//@property(nonatomic,strong)   LAContext * context  ;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor redColor];
    
    UIButton * button = [UIButton buttonWithType:0];
    button.backgroundColor =[UIColor greenColor];
    button.frame = CGRectMake(100, 100, 100, 100);
    [button addTarget:self action:@selector(unlockButtonCLick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
}

-(void)unlockButtonCLick{
    

    
    NSLog(@"点击");
    //  跟相机一样需要在info.plist文件中添加配置,否则会闪退
//   字段: NSFaceIDUsageDescription

    
//    LAPolicy 有两种方式
//    区别
//    . LAPolicyDeviceOwnerAuthenticationWithBiometrics iOS8.0以上支持，只有指纹验证功能
//    . LAPolicyDeviceOwnerAuthentication iOS 9.0以上支持，包含指纹验证与输入密码的验证方式 类似支付宝
    
 LAContext *    context = [[LAContext alloc]init];
          context.localizedFallbackTitle = @"ddd";

          context.localizedCancelTitle = @"ccc";

    
    NSError * error = nil;
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        // 支持指纹
        NSLog(@"可以验证");
        [self unlock];
      
    }else{
        NSLog(@"不能验证");
        [self recoveryLock];
       
    }
}

-(void)unlock{
    
      
    LAContext *    context = [[LAContext alloc]init];
             context.localizedFallbackTitle = @"ddd";

             context.localizedCancelTitle = @"ccc";
    NSString * reason = @"999999 ";
    
      [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:reason reply:^(BOOL success, NSError * _Nullable error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    NSLog(@"验证成功");
                    
                        [self.navigationController pushViewController:[PUSHViewController new]  animated:YES];

                   
                }else{
                    NSLog(@"验证失败");

    //                 NSLog(@"不支持指纹");
                            switch (error.code) {
                                case LAErrorTouchIDNotEnrolled:
                                    NSLog(@"设备没有注册touchID");
                                    break;
                                case LAErrorUserCancel:
                                        NSLog(@"点击了取消按钮");
                                        break;
                                    case LAErrorAuthenticationFailed:
                    //                 LAPolicyDeviceOwnerAuthentication 可以支持输入密码,进行验证
                                            NSLog(@"LAErrorAuthenticationFailed,连续三次输入错误,支付宝弹出指纹不匹配");
                                            break;
                                    case LAErrorPasscodeNotSet:
                    //                 LAPolicyDeviceOwnerAuthentication 可以支持输入密码,但是用户没有设置密码
                                            NSLog(@"用户没有设置密码");
                                            break;

                                    case LAErrorTouchIDNotAvailable:
                                            NSLog(@"不支持指纹,可能手机版本低");
                                            break;

                                case LAErrorUserFallback:
                                        NSLog(@"点击输入密码按钮,可以处理点击事件");
                                        break;
                                    
                                    case LAErrorTouchIDLockout:
                    //  类似支付宝,多次输入错误的话,锁定touchID,用密码接触锁定以后重新,重新支持touchID
                                {
                                    
                                    NSLog(@"错误次数超过上限，需要手动输入密码");
                                    [self recoveryLock];
                                }
                                    break;

                                default:
                                    break;
                            }
                        
                }
                         });
            }];
}

-(void)recoveryLock{
    NSLog(@"弹出输入密码");
       
    LAContext *    context = [[LAContext alloc]init];
             context.localizedFallbackTitle = @"ddd";

             context.localizedCancelTitle = @"ccc";
    
    [context evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:@"22222" reply:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            NSLog(@"输入密码验证成功");
            [self unlock];
        }else{
            NSLog(@"输入密码验证失败");

        }
    }];
    
}

@end
