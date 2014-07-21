//
//  ViewController.m
//  CollectNumber
//
//  Created by Chie AHAREN on 2014/07/20.
//  Copyright (c) 2014年 Chie AHAREN. All rights reserved.
//

#import "ViewController.h"
#import "Formatter.h"

#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic) CLLocationManager *locationManager;

@end

@implementation ViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0];
    
    //GPS機能の使用可否を判定
    if ([CLLocationManager locationServicesEnabled]) {
        
        self.locationManager = [[CLLocationManager alloc] init];
        [self.locationManager startUpdatingLocation];//GPS使用の開始
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//カメラ撮影
- (IBAction)openCamera:(id)sender {
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:imagePickerController animated:YES completion:nil];
    
}

//撮影した写真の処理
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
     UIImage *image = info[UIImagePickerControllerOriginalImage];

     NSMutableDictionary *metadata = info[UIImagePickerControllerMediaMetadata];
    
    //位置情報を保存
    if (self.locationManager) {
        metadata[(NSString *)kCGImagePropertyGPSDictionary] = [self GPSDictionaryForLocation:self.locationManager.location];
    }

    
    /*写真に情報を付加する*/
    NSData *imageData = [self createImageDataFromImage:image metaData:metadata];
    
    [self send:imageData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

//写真に情報を付加する
- (NSData *)createImageDataFromImage:(UIImage *)image metaData:(NSDictionary *)metadata
{
    NSMutableData *imageData = [NSMutableData new];
    
    /*画像ファイルの書き込み*/
    
    //(初期設定)
    CGImageDestinationRef dest = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)imageData, kUTTypeJPEG, 1, NULL);
    
    //(dest:格納する場所,image.CGImage:追加対象の画像,matadata:追加する情報)
    CGImageDestinationAddImage(dest, image.CGImage, (__bridge CFDictionaryRef)metadata);
    
    //実際に画像ファイルの書き込みを実行する?
    CGImageDestinationFinalize(dest);
    
    //メモリの解放
    CFRelease(dest);
    
    //情報を付加した画像を戻す
    return imageData;
}

//位置情報の取得？
- (NSDictionary *)GPSDictionaryForLocation:(CLLocation *)location
{
    //可変ディクショナリgpsを生成する。
    NSMutableDictionary *gps = [NSMutableDictionary new];
    
    
    //日付
    gps[(NSString *)kCGImagePropertyGPSDateStamp] = [[Formatter GPSDateFormatter] stringFromDate:location.timestamp];
    
    //タイムスタンプ
    gps[(NSString *)kCGImagePropertyGPSTimeStamp] = [[Formatter GPSTimeFormatter] stringFromDate:location.timestamp];
    
    // 緯度
    CGFloat latitude = location.coordinate.latitude;//緯度を取得できる 南 < 0 <= 北
    
    NSString *gpsLatitudeRef;
    if (latitude < 0) {
        latitude = -latitude;
        gpsLatitudeRef = @"S";
    } else {
        gpsLatitudeRef = @"N";
    }
    
    gps[(NSString *)kCGImagePropertyGPSLatitudeRef] = gpsLatitudeRef;//南 or 北
    gps[(NSString *)kCGImagePropertyGPSLatitude] = @(latitude);//正の数の座標
    
    // 経度
    CGFloat longitude = location.coordinate.longitude;//経度を取得できる 西 < 0 <= 東
    
    NSString *gpsLongitudeRef;
    if (longitude < 0) {
        longitude = -longitude;
        gpsLongitudeRef = @"W";
    } else {
        gpsLongitudeRef = @"E";
    }
    gps[(NSString *)kCGImagePropertyGPSLongitudeRef] = gpsLongitudeRef;//西 or 東
    gps[(NSString *)kCGImagePropertyGPSLongitude] = @(longitude);//正の数の座標
    
    
    //位置情報(緯度、経度)を格納した可変ディクショナリを返す。
    return gps;
}


// Send image
- (void)send:(NSData*)matadata{
    
    NSLog(@"作業開始");
    
    NSURL* url = [NSURL URLWithString:URL];
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    
    NSString* boundary = @"---------------------------102852708831426";
    
    [urlRequest setHTTPMethod:@"POST"]; // Method type
    [urlRequest setTimeoutInterval:120]; // Timeout
    [urlRequest setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary]
      forHTTPHeaderField:@"Content-Type"];
    
    // Create POST DATA
    NSMutableData *postData = [[NSMutableData alloc] init];
    
    [postData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"upload_file\";filename=\"%@\" \r\n", @"IMG.jpg"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[[NSString stringWithFormat:@"Content-Type: image/jpeg\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Convert UIImage to post into NSData
    NSData* imageData = matadata;
    
    
    [postData appendData:imageData];
    [postData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [urlRequest setHTTPBody:postData];
    
    
    NSLog(@"作業中");
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        //label.text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //[self.view addSubview:label];
    }];
    
    NSLog(@"作業終了");
    
}


@end
