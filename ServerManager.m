//
//  ServerManager.m
//
//  Created by David Grigoryan on 28/09/2016.
//  Copyright © 2016 David Grigoryan. All rights reserved.
//

#import "ServerManager.h"

static NSURLSession *URLSession;
static NSMutableURLRequest *request;

@implementation ServerManager
@synthesize baseURLString;

- (instancetype)init
{
    self = [super init];
    if (self) {
        [ServerManager configureServerManager];
        baseURLString = @"API-URL";
    }
    return self;
}

+ (void)configureServerManager {
    
    URLSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:nil];
    
    request = [NSMutableURLRequest requestWithURL:nil
                                   cachePolicy:NSURLRequestUseProtocolCachePolicy
                                   timeoutInterval:30.0];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];


}

#pragma mark - ServerProtocol

- (void)performPOSTRequestWithParams:(id)parameters withURL:(NSString *)urlString onSuccess:(SuccessBlock)success onFailure:(FailureBlock)failure {
    [self configureRequestWithParameters:parameters onURL:urlString HTTPMethod:@"POST" onSuccess:success onFailure:failure];
}

- (void)performGETRequestWithParams:(id)parameters withURL:(NSString *)urlString onSuccess:(SuccessBlock)success onFailure:(FailureBlock)failure {
    [self configureRequestWithParameters:parameters onURL:urlString HTTPMethod:@"GET" onSuccess:success onFailure:failure];
}

#pragma mark - Internal Methods
/**************************************************************************************************************/

- (void) configureRequestWithParameters:(id) parameters onURL:(NSString *) URL HTTPMethod:(NSString *) httpMethod onSuccess:(SuccessBlock) success onFailure:(FailureBlock) failure {
    
    NSError *error = nil;
    
    NSURL *baseURL = [NSURL URLWithString:baseURLString];
    
    request.URL = URL.length > 0 ? [baseURL URLByAppendingPathComponent:URL] : baseURL;
    
    if ([httpMethod isEqualToString:@"GET"]) {
        
        NSURLComponents *components = [NSURLComponents componentsWithURL:request.URL resolvingAgainstBaseURL:YES];
        
        NSMutableArray *queryItems = [NSMutableArray array];
        
        for (NSString *key in parameters) {
            
            NSString *parameterValue = parameters[key];
            
            if (![parameterValue isKindOfClass:[NSString class]]) {
                
                parameterValue = [NSString stringWithFormat:@"%@", parameterValue];
            }
            
            [queryItems addObject:[NSURLQueryItem queryItemWithName:key value:parameterValue]];
        }
        
        components.queryItems = queryItems;
        
        [request setURL:[components URL]];
        
        
        
    } else if ([httpMethod isEqualToString:@"POST"] && parameters) {
        
        NSData *postData = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:&error];
        [request setHTTPBody:postData];
    }
    
    [request setHTTPMethod:httpMethod];
    
    [self configureTaskOnSuccess:success onFailure:failure];
    
}

- (void) configureTaskOnSuccess:(SuccessBlock) success onFailure:(FailureBlock) failure {
    
    NSURLSessionDataTask *postDataTask = [URLSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
            });
            
        } else if (data) {
            
            NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                success(jsonResponse);
            });
        }
    }];
    
    [postDataTask resume];
}
/**************************************************************************************************************/

@end
