//
//  RTTemplate.h
//  PDFRenderTemplateExample
//
//  Created by Oleg Bogatenko on 5/5/15.
//  Copyright (c) 2015 Oleg Bogatenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RTTemplate : NSObject
{
    void (^_completion)(BOOL status, NSString *content);
}

- (instancetype)initWithName:(NSString *)name
                        data:(NSDictionary *)dict
                      images:(NSDictionary *)images;

- (void)parseTemplateWithCompletion:(void (^)(BOOL status, NSString *content))completion;

@end
