//
//  RTPDFGenerator.h
//  PDFRenderTemplateExample
//
//  Created by Oleg Bogatenko on 5/5/15.
//  Copyright (c) 2015 Oleg Bogatenko. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kPageMargin 20.f

#define kPaperSizeA4 CGSizeMake(595.2f, 841.8f)

typedef void (^RTPDFGeneratorCompletionBlock)(BOOL, NSData*);

@interface RTPDFGenerator : UIViewController

@property (nonatomic, copy) RTPDFGeneratorCompletionBlock completionBlock;

@property (nonatomic, strong) NSString *templateName;

+ (instancetype)createPDFWithTemplate:(NSString *)name
                             pageSize:(CGSize)pageSize
                          contentData:(NSDictionary *)content
                           imagesData:(NSDictionary *)images
                           completion:(RTPDFGeneratorCompletionBlock)completion;

@end
