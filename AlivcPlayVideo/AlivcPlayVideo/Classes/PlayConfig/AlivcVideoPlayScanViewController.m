//
//  AlivcVideoPlayScanViewController.m
//  AlivcBasicVideo
//
//  Created by ToT on 2020/3/18.
//

#import "AlivcVideoPlayScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "NSString+AlivcHelper.h"

@interface AlivcVideoPlayScanViewController ()<AVCaptureMetadataOutputObjectsDelegate>

@property (strong,nonatomic)AVCaptureSession *session;

@end

@implementation AlivcVideoPlayScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = [@"扫码" localString];
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc]init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    self.session = [[AVCaptureSession alloc]init];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([self.session canAddInput:input]) { [self.session addInput:input]; }
    if ([self.session canAddOutput:output]) { [self.session addOutput:output]; }
    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    AVCaptureVideoPreviewLayer *preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    preview.frame = self.view.bounds;
    [self.view.layer insertSublayer:preview atIndex:0];
    [self.session startRunning];
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if ([metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        NSString *text = metadataObject.stringValue;
        [self.session stopRunning];
        if (self.scanedTextCallBack) {
            self.scanedTextCallBack(text);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
