//
//  ViewController.m
//  PDFRenderTemplateExample
//
//  Created by Oleg Bogatenko on 5/5/15.
//  Copyright (c) 2015 Oleg Bogatenko. All rights reserved.
//

#import "ViewController.h"
#import "RTPDFGenerator.h"
#import <MessageUI/MessageUI.h>

@interface ViewController () <MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) RTPDFGenerator *generator;

- (IBAction)createPDF:(UIButton *)sender;

@end

@implementation ViewController

@synthesize generator;

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions

- (void)createPDF:(UIButton *)sender
{
    UIImage *image = [UIImage imageNamed:@"sample.jpg"];
    
    generator = [RTPDFGenerator createPDFWithTemplate:@"index"
                                             pageSize:kPaperSizeA4
                                          contentData:@{ @"name" : @"John", @"age" : @"25" }
                                           imagesData:@{ @"main" : image }
                                           completion:^(BOOL success, NSData *data) {
                                               
                                               if (success)
                                                   [self sendPDFViaEmail:data];
                                               else
                                                   NSLog(@"Error!");
                                           }];
}

- (void)sendPDFViaEmail:(NSData *)pdf
{
    MFMailComposeViewController *picker = [MFMailComposeViewController new];
    
    picker.mailComposeDelegate = self;
    
    [picker setSubject:NSLocalizedString(@"Message subject", @"")];
        
    if (pdf)
        [picker addAttachmentData:pdf mimeType:@"application" fileName:@"document.pdf"];
    
    @try {
        [self presentViewController:picker animated:YES completion:nil];
    }
    @catch (NSException *exception) {
        //
    }
    @finally {
        //
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
