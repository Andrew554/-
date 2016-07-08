//
//  ViewController.m
//  QiniuDemo
//
//  Created by Andrew554 on 16/7/8.
//  Copyright © 2016年 Andrew554. All rights reserved.
//

#import "ViewController.h"
#import <AFNetworking.h>
#import <QiniuSDK.h>
#import <SVProgressHUD.h>

static NSString * const TokenAPI = @"http://leero.cqitca.com:3001/api/homes/get_token"; // 获取tokenAPI

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

/**
 *  图片选择器
 */
@property (nonatomic, strong) UIImagePickerController *pic;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIButton *uploadBtn;

/**
 *  图片数据
 */
@property (nonatomic, strong) NSData *imageData;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageView.layer.borderColor = [UIColor grayColor].CGColor;
    self.imageView.layer.borderWidth = 2;
    self.imageView.layer.cornerRadius = 5;
}

/**
 *  图片选取
 */
- (IBAction)selectImage:(UIButton *)sender {
    
    self.pic = [[UIImagePickerController alloc] init];
    
    self.pic.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    self.pic.allowsEditing = YES;
    
    self.pic.delegate = self;
    
    [self presentViewController:self.pic animated:YES completion:nil];
}

/**
 *  上传七牛
 */
- (IBAction)uploadQiniu:(UIButton *)sender {
    
    __block NSString *token = @"";  // token字符串
    
    // 获取token
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager GET:TokenAPI parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
       
        token = responseObject[@"uptoken"];
        
        // 配置上传回调, 主要用于获取进度
        QNUploadOption *opt = [[QNUploadOption alloc] initWithProgressHandler:^(NSString *key, float percent) {
            
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
            [SVProgressHUD showProgress:percent];
            
        }];
        
        // 七牛上传
        QNUploadManager *upManager = [[QNUploadManager alloc] init];
        
        // 参数key: 对应上图片保存名, 如果上传过一次相同key的图片, 返回info中会提示已经存在并且不会覆盖, 所以尽量保证key唯一, 若key填写nil,则会使用hash值作为图片名
        [upManager putData:self.imageData key:nil token:token
                  complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                      
                      NSLog(@"info-%@", info);
                      NSLog(@"resp-%@", resp);
                      
                      [SVProgressHUD showSuccessWithStatus:@"上传成功"];
                      
                  } option:opt];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"error--%@", error);
    }];
    
}


#pragma mark - <UIImagePickerControllerDelegate>

/**
 *  3.0
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    // 数据类型
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:@"public.image"]){   // 如果选择的是图片
        
//        UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"]; // 原始图片
        
        UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];   // 编辑之后的图片
        
        self.imageView.image = image;
        
        self.imageData = UIImageJPEGRepresentation(image, 0.5);
       
    } else if ([mediaType isEqualToString:@"public.movie"]) {   // 选择视频
       
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        self.uploadBtn.enabled = YES;
        
    }];
}


/**
 *  2.0
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary<NSString *,id> *)editingInfo{
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
