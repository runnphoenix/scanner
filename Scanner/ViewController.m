//
//  ViewController.m
//  Scanner
//
//  Created by workMac on 15/7/1.
//  Copyright © 2015年 Gree. All rights reserved.
//

#import "ViewController.h"
#import "QRCodeOutlineView.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<AVCaptureMetadataOutputObjectsDelegate>
@end

@implementation ViewController
{
    AVCaptureSession *_session;
    AVCaptureVideoPreviewLayer *_previewLayer;
    QRCodeOutlineView *_QROutline;
    NSTimer *_QROutlineHideTimer;
    
    NSMutableArray *_BarCodeMessages;
    NSMutableArray *_QRCodeMessages;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _session = [[AVCaptureSession alloc]init];
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (input) {
        [_session addInput:input];
    }else{
        NSLog(@"error:%@",[error localizedDescription]);
        return;
    }
    
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer.bounds = self.view.bounds;
    _previewLayer.position = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    [self.view.layer addSublayer:_previewLayer];
    
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc]init];
    [_session addOutput:output];
    [output setMetadataObjectTypes:output.availableMetadataObjectTypes];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    _QROutline = [[QRCodeOutlineView alloc]initWithFrame:self.view.frame];
    _QROutline.backgroundColor = [UIColor clearColor];
    _QROutline.hidden = YES;
    [self.view addSubview:_QROutline];
    
    _BarCodeMessages = [NSMutableArray array];
    _QRCodeMessages = [NSMutableArray array];
}

- (void)viewDidAppear:(BOOL)animated
{
    [_session startRunning];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    AVMetadataMachineReadableCodeObject *transformed;
    
    for (AVMetadataObject *metadata in metadataObjects) {
        
        transformed = (AVMetadataMachineReadableCodeObject*)[_previewLayer transformedMetadataObjectForMetadataObject:metadata];
        
        if ([metadata.type isEqualToString:AVMetadataObjectTypeQRCode]) {
            if (![_QRCodeMessages containsObject:transformed.stringValue]) {
                [_QRCodeMessages addObject:transformed.stringValue];
                NSLog(@"%@",_QRCodeMessages);
            }
        }else{
            if (![_BarCodeMessages containsObject:transformed.stringValue]){
                [_BarCodeMessages addObject:transformed.stringValue];
                NSLog(@"%@",_BarCodeMessages);
            }
        }
    }
    
    //框表示扫描出结果
    _QROutline.frame = transformed.bounds;
    _QROutline.hidden = NO;
    NSArray *transformerdCorners = [self translatePoints:transformed.corners
                                                fromView:self.view
                                                  toView:_QROutline
                                    ];
    _QROutline.corners = transformerdCorners;
    [self startOverlayHideTimer];
}

- (NSArray*)translatePoints:(NSArray*)points fromView:(UIView*)fromView toView:(UIView*)toView
{
    NSMutableArray *translatedPoints = [NSMutableArray array];
    for (NSDictionary *point in points) {
        CGPoint originPoint = CGPointMake([point[@"X"] floatValue], [point[@"Y"] floatValue]);
        CGPoint translatedPoint = [fromView convertPoint:originPoint toView:toView];
        [translatedPoints addObject:[NSValue valueWithCGPoint:translatedPoint]];
    }
    return translatedPoints;
}

- (void)startOverlayHideTimer
{
    if (_QROutlineHideTimer) {
        [_QROutlineHideTimer invalidate];
    }
    
    _QROutlineHideTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                           target:self
                                                         selector:@selector(hideQROutline)
                                                         userInfo:nil
                                                          repeats:NO
                           ];
}

- (void)hideQROutline
{
    _QROutline.hidden = YES;
}

- (void)prepareForSegue:(nonnull UIStoryboardSegue *)segue sender:(nullable id)sender
{
    if ([segue.identifier isEqualToString:@"showResultSegueIdentifier"]) {
        [_session stopRunning];
        if ([self storeData]) {
            NSLog(@"stored");
        }else{
            NSLog(@"store failed");
        }
    }
}

- (BOOL)storeData
{
    NSString *barCodeMessagesFilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"barCodeMessages.archive"];
    BOOL barCodeMessagesStored = [NSKeyedArchiver archiveRootObject:_BarCodeMessages toFile:barCodeMessagesFilePath];
    NSString *QRCodeMessagesFilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"QRCodeMessages.archive"];
    BOOL QRCodeMessagesStored = [NSKeyedArchiver archiveRootObject:_QRCodeMessages toFile:QRCodeMessagesFilePath];
    
    return  barCodeMessagesStored && QRCodeMessagesStored;
}


@end
