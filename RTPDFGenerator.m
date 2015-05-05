//
//  RTPDFGenerator.m
//  PDFRenderTemplateExample
//
//  Created by Oleg Bogatenko on 5/5/15.
//  Copyright (c) 2015 Oleg Bogatenko. All rights reserved.
//

#import "RTPDFGenerator.h"
#import "RTTemplate.h"


@interface RTPDFGenerator () <UIWebViewDelegate>
{
    RTTemplate *template;
    
    NSData *pdfData;
    CGSize pageSize;
    
    NSDictionary *contentData;
    NSDictionary *imagesData;
}

@property (nonatomic, strong) UIWebView *theWebView;

@end

@interface UIPrintPageRenderer (PDF)

- (NSData *)printToPDF;

@end

@implementation RTPDFGenerator

@synthesize theWebView;
@synthesize templateName;
@synthesize completionBlock;

+ (instancetype)createPDFWithTemplate:(NSString *)name
                             pageSize:(CGSize)pageSize
                          contentData:(NSDictionary *)content
                           imagesData:(NSDictionary *)images
                           completion:(RTPDFGeneratorCompletionBlock)completion
{
    RTPDFGenerator *generator = [[RTPDFGenerator alloc] initWithTemplate:name
                                                                pageSize:pageSize
                                                             contentData:content
                                                              imagesData:images];
    generator.completionBlock = completion;
    generator.templateName = name;
    
    return generator;
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        pdfData = nil;
    }
    
    return self;
}

- (instancetype)initWithTemplate:(NSString *)name
                        pageSize:(CGSize)size
                     contentData:(NSDictionary *)content
                      imagesData:(NSDictionary *)images
{
    if (self = [super init])
    {
        pageSize = size;
        
        if (name)
            templateName = name;
        
        if (content)
            contentData = content;
        
        if (images)
            imagesData = images;
        
        [self startLoadView];
    }
    
    return self;
}

- (void)startLoadView
{
    [[UIApplication sharedApplication].delegate.window addSubview:self.view];
    
    self.view.frame = CGRectMake(0, 0, 1.f, 1.f);
    self.view.alpha = 1.f;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    theWebView = [[UIWebView alloc] initWithFrame:self.view.frame];
    theWebView.delegate = self;

    [self.view addSubview:theWebView];
    
    template = [[RTTemplate alloc] initWithName:templateName
                                           data:contentData
                                         images:imagesData];
    
    [template parseTemplateWithCompletion:^(BOOL status, NSString *content) {
        
        if (status)
            [theWebView loadHTMLString:content baseURL:nil];
        else
        {
            if (completionBlock)
                completionBlock(NO, nil);
        }
    }];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (webView.isLoading)
        return;
    
    UIPrintPageRenderer *render = [UIPrintPageRenderer new];
    
    [render addPrintFormatter:webView.viewPrintFormatter startingAtPageAtIndex:0];
    
    CGRect printableRect = CGRectMake(kPageMargin,
                                      kPageMargin,
                                      pageSize.width - kPageMargin * 2,
                                      pageSize.height - kPageMargin * 2);
    
    CGRect paperRect = CGRectMake(0, 0, pageSize.width, pageSize.height);
    
    [render setValue:[NSValue valueWithCGRect:paperRect] forKey:@"paperRect"];
    [render setValue:[NSValue valueWithCGRect:printableRect] forKey:@"printableRect"];
    
    pdfData = [render printToPDF];
    
    [self stopLoad];

    if (completionBlock)
        completionBlock(YES, pdfData);
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (webView.isLoading)
        return;
    
    [self stopLoad];
    
    if (completionBlock)
        completionBlock(NO, nil);
}

- (void)stopLoad
{
    [theWebView stopLoading];
    
    theWebView.delegate = nil;
    
    [theWebView removeFromSuperview];
    
    [self.view removeFromSuperview];
    
    theWebView = nil;
    
    template = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

@implementation UIPrintPageRenderer (PDF)

- (NSData *)printToPDF
{
    NSMutableData *pdfData = [NSMutableData data];
    
    UIGraphicsBeginPDFContextToData(pdfData, self.paperRect, nil);
    
    [self prepareForDrawingPages: NSMakeRange(0, self.numberOfPages)];
    
    CGRect bounds = UIGraphicsGetPDFContextBounds();
    
    for (int i = 0; i < self.numberOfPages; i++)
    {
        UIGraphicsBeginPDFPage();
        
        [self drawPageAtIndex:i inRect:bounds];
    }
    
    UIGraphicsEndPDFContext();
    
    return pdfData;
}

@end
