//
//  RTTemplate.m
//  PDFRenderTemplateExample
//
//  Created by Oleg Bogatenko on 5/5/15.
//  Copyright (c) 2015 Oleg Bogatenko. All rights reserved.
//

#import "RTTemplate.h"
#import <UIKit/UIKit.h>

typedef NS_ENUM (NSInteger, RTDataType) {
    RTDataTypeData,
    RTDataTypeImage
};

@interface RTTemplate ()
{
    NSString *templateName;
    NSDictionary *contentData;
    NSDictionary *imageData;
    
    NSMutableArray *fileURLs;
}

@end

@implementation RTTemplate

const NSString *TEMPLATE_EXT = @"html";

- (instancetype)initWithName:(NSString *)name
                        data:(NSDictionary *)dict
                      images:(NSDictionary *)images
{
    self = [super init];
    
    if (self)
    {
        if ([self stringIsNotNil:name])
            templateName = name;
        
        if (dict)
            contentData = dict;
        
        if (images)
        {
            imageData = images;
            
            fileURLs = [NSMutableArray new];
        }
    }
    
    return self;
}

#pragma mark - Parse Template

- (void)parseTemplateWithCompletion:(void (^)(BOOL, NSString *))completion
{
    _completion = [completion copy];
    
    NSString *content = [self getFileContent];
    
    if (!content)
    {
        _completion(NO, nil);
        
        return;
    }
    
    if (contentData)
    {
        for (NSString *key in contentData.allKeys)
        {
            content = [content stringByReplacingOccurrencesOfString:[self keyWithDelimiters:key type:RTDataTypeData]
                                                         withString:contentData[key]];
        }
    }
    
    if (imageData)
    {
        for (NSString *key in imageData.allKeys)
        {
            NSURL *url = [self saveImageThenGetURL:imageData[key]];
            
            if (url)
            {
                [fileURLs addObject:url];
                
                content = [content stringByReplacingOccurrencesOfString:[self keyWithDelimiters:key type:RTDataTypeImage]
                                                             withString:[url absoluteString]];
            }
        }
    }
    
    _completion(YES, content);
}

#pragma mark - Common

- (BOOL)stringIsNotNil:(NSString *)string
{
    return [string stringByReplacingOccurrencesOfString:@" " withString:@""].length;
}

- (NSString *)keyWithDelimiters:(NSString *)key type:(RTDataType)type
{
    switch (type) {
        case RTDataTypeData:
            return [NSString stringWithFormat:@"{{%@}}", key];
            break;
        case RTDataTypeImage:
            return [NSString stringWithFormat:@"[[%@]]", key];
            break;
    }
}

- (NSString *)getFileContent
{
    NSError *err = nil;
    
    return [NSString stringWithContentsOfURL:[self getFileURLForName:templateName]
                                    encoding:NSStringEncodingConversionAllowLossy
                                       error:&err];
}

- (NSURL *)getFileURLForName:(NSString *)name
{
    if (name)
    {
        return  [[NSBundle mainBundle] URLForResource:name withExtension:(NSString *)TEMPLATE_EXT];
    }
    
    return nil;
}

- (NSURL *)saveImageThenGetURL:(UIImage *)img
{
    NSURL *fileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[self tempFileName]]];
    
    if (img)
    {
        NSData *data = UIImagePNGRepresentation(img);
        
        NSError *error = nil;
        
        [data writeToURL:fileURL options:NSDataWritingAtomic error:&error];
        
        if (!error)
        {
            return fileURL;
        }
    }
    
    return nil;
}

- (NSString *)tempFileName
{
    return [NSString stringWithFormat:@"%@.png", [[NSUUID UUID] UUIDString]];
}

#pragma mark - Dealloc

- (void)dealloc
{
    for (NSURL *url in fileURLs)
    {
        NSError *error = nil;
        
        [[NSFileManager defaultManager] removeItemAtURL:url error:&error];
    }
    
    fileURLs = nil;
}

@end
