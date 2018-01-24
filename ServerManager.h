//
//  ServerManager.h
//
//  Created by David Grigoryan on 28/09/2016.
//  Copyright © 2016 David Grigoryan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SuccessBlock)(id response);
typedef void (^FailureBlock)(NSError *error);

@protocol ServerProtocol

@property (copy, nonatomic, readonly) NSString *baseURLString;

- (void)performPOSTRequestWithParams:(id)parameters withURL:(NSString *)urlString onSuccess:(SuccessBlock)success onFailure:(FailureBlock)failure;

- (void)performGETRequestWithParams:(id)parameters withURL:(NSString *)urlString onSuccess:(SuccessBlock)success onFailure:(FailureBlock)failure;

@end

@interface ServerManager : NSObject <ServerProtocol>


@end
