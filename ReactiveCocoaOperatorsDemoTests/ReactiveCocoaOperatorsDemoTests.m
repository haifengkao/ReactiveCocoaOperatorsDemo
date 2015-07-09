//
//  ReactiveCocoaOperatorsDemoTests.m
//  ReactiveCocoaOperatorsDemoTests
//
//  Created by Lono on 2015/7/10.
//  Copyright © 2015年 CocoaSpice. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <ReactiveCocoa.h>

@interface ReactiveCocoaOperatorsDemoTests : XCTestCase

@end

@implementation ReactiveCocoaOperatorsDemoTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testThen
{
    RACSignal *letters = [@"A B C" componentsSeparatedByString:@" "].rac_sequence.signal;
    
    RACSignal *sequenced = [[letters
                             doNext:^(NSString *letter) {
                                 NSLog(@"S1: %@", letter);
                             }]
                            then:^{
                                return [@"1 2 3" componentsSeparatedByString:@" "].rac_sequence.signal;
                            }];
    [sequenced subscribeNext:^(id x) {
        NSLog(@"S2: %@", x);
    }];
    
    // Outputs: S1: A S1: B S1: C
    // Outputs: S2: 1 S2: 2 S2: 3
}

- (void)testDistinct
{
    RACSignal *signal = [@"1 1 2 3 4 5" componentsSeparatedByString:@" "].rac_sequence.signal;
    RACSignal *distinct= [signal distinctUntilChanged];
    
    // Output Nothing
    [distinct subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    
    // Output 1 2 3 4 5
}

- (void)testSkip
{
    RACSignal *signal = [@"1 2 3 4 5 6" componentsSeparatedByString:@" "].rac_sequence.signal;
    RACSignal *taked = [signal skip:2];
    
    // Output Nothing
    [taked subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    
    // Output 3 4 5 6
}

- (void)testTake
{
    RACSignal *signal = [@"1 2 3 4 5 6" componentsSeparatedByString:@" "].rac_sequence.signal;
    RACSignal *taked = [signal take:2];
    
    // Output Nothing
    [taked subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    
    // Output 1 2
}

- (void)testZip {
    RACSubject *letters = [RACSubject subject];
    RACSubject *numbers = [RACSubject subject];
    RACSignal *combined = [RACSignal zip:@[ letters, numbers ]
                                  reduce:^(NSString *letter, NSString *number) {
                                      return [letter stringByAppendingString:number];
                                  }];
    
    // Output Nothing
    [combined subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    
    // Output Nothing ([A] [])
    [letters sendNext:@"A"];
    // Output Nothing ([A, B] [])
    [letters sendNext:@"B"];
    // Output A1 ([A, B] [1])
    [numbers sendNext:@"1"];
    // Output B2 ([A, B] [1, 2])
    [numbers sendNext:@"2"];
    // Output Nothing ([A, B, C] [1, 2])
    [letters sendNext:@"C"];
    // Output C3 ([A, B, C] [1, 2, 3])
    [numbers sendNext:@"3"];
}

- (void)testCombineLatestReduce {
    RACSubject *letters = [RACSubject subject];
    RACSubject *numbers = [RACSubject subject];
    RACSignal *combined = [RACSignal combineLatest:@[ letters, numbers ]
                                            reduce:^(NSString *letter, NSString *number) {
                                                return [letter stringByAppendingString:number];
                                            }];
    
    // Output Nothing
    [combined subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    
    // Output Nothing  [A] []
    [letters sendNext:@"A"];
    // Output Nothing  [A, B] []
    [letters sendNext:@"B"];
    // Output B1       [A, B] [1]
    [numbers sendNext:@"1"];
    // Output B2       [A, B] [1, 2]
    [numbers sendNext:@"2"];
    // Output C2       [A, B, C] [1, 2]
    [letters sendNext:@"C"];
    // Output C3       [A, B, C] [1, 2, 3]
    [numbers sendNext:@"3"];
}

- (void)testMerge {
    RACSignal *signal1 = [@"1 2 3 4" componentsSeparatedByString:@" "].rac_sequence.signal;
    RACSignal *signal2 = [@"5 6 7 8" componentsSeparatedByString:@" "].rac_sequence.signal;
    RACSignal *merged = [RACSignal merge:@[signal1, signal2]];
    
    // Output Nothing
    [merged subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    
    // Output 1 5 2 6 3 7 4 8
}

- (void)testSubject {
    RACSubject *subject = [RACSubject subject];
    
    // Output Nothing
    [subject subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    
    // Outputs: 1
    [subject sendNext:@"1"];
    // Outputs: 2
    [subject sendNext:@"2"];
    // Outputs: 3
    [subject sendNext:@"3"];
    // Outputs: 4
    [subject sendNext:@"4"];
}

- (void)testFilter {
    RACSignal *signal = [@"1 2 3 4 5 6 7 8" componentsSeparatedByString:@" "].rac_sequence.signal;
    RACSignal *filteredSignal = [signal filter:^ BOOL (NSString *value) {
        return (value.intValue % 2) == 0;
    }];
    
    // Output Nothing
    [filteredSignal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    
    // Output 2 4 6 8
}

- (void)testMap {
    RACSignal *signal = [@"1 2 3" componentsSeparatedByString:@" "].rac_sequence.signal;
    RACSignal *mappedSignal = [signal map:^(NSString* value) {
        return [value stringByAppendingString:value];
    }];
    
    // Output Nothing
    [mappedSignal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    
    // Output 11 22 33
}

- (void)testHotSignal {
    RACSignal *signal = [@"1 2 3" componentsSeparatedByString:@" "].rac_sequence.signal;
    
    NSLog(@"Start subscriptions");
    
    // Output Nothing
    [signal subscribeNext:^(id x) {
        NSLog(@"S1: %@", x);
    }];
    
    // Output Nothing
    [signal subscribeNext:^(id x) {
        NSLog(@"S2: %@", x);
    }];
    
    // Output Nothing
    [signal subscribeNext:^(id x) {
        NSLog(@"S3: %@", x);
    }];
    
    // Output S1: 1 S2: 1 S3: 1 S1: 2 S2: 2 S3: 2 S1: 3 S2: 3 S3: 3
}


- (void)testReplayExample2 {
    RACSubject *letters = [RACSubject subject];
    RACSignal *signal = [letters replay];
    
    [signal subscribeNext:^(id x) {
        NSLog(@"S1: %@", x);
    }];
    
    // Outputs: S1: A
    [letters sendNext:@"A"];
    
    // Outputs: S1:B
    [letters sendNext:@"B"];
    
    // Outputs: S2: A S2: B
    [signal subscribeNext:^(id x) {
        NSLog(@"S2: %@", x);
    }];
    
    // Outputs: S1: C S2: C
    [letters sendNext:@"C"];
    
    // Outputs: S1: D S2: D
    [letters sendNext:@"D"];
    
    // Outputs: S3: A S3: B S3: C S3: D
    [signal subscribeNext:^(id x) {
        NSLog(@"S3: %@", x);
    }];
}

- (void)testReplayLastExample2 {
    RACSubject *letters = [RACSubject subject];
    RACSignal *signal = [letters replayLast];
    
    [signal subscribeNext:^(id x) {
        NSLog(@"S1: %@", x);
    }];
    
    // Outputs: S1: A
    [letters sendNext:@"A"];
    
    // Outputs: S1:B
    [letters sendNext:@"B"];
    
    // Outputs: S2: B
    [signal subscribeNext:^(id x) {
        NSLog(@"S2: %@", x);
    }];
    
    // Outputs: S1: C
    // Outputs: S2: C
    [letters sendNext:@"C"];
    
    // Outputs: S1: D
    // Outputs: S2: D
    [letters sendNext:@"D"];
    
    // Outputs: S3: D
    [signal subscribeNext:^(id x) {
        NSLog(@"S3: %@", x);
    }];
}

- (void)testReplayLazily {
    __block int num = 0;
    
    // Outputs Nothing
    RACSignal *signal = [[RACSignal createSignal:^RACDisposable *(id  subscriber) {
        num++;
        NSLog(@"Increment num to: %i", num);
        [subscriber sendNext:@(num)];
        return nil;
    }] replayLazily];
    
    NSLog(@"Start subscriptions");
    
    // Output Increment num to: 1 S1: 1
    [signal subscribeNext:^(id x) {
        NSLog(@"S1: %@", x);
    }];
    
    // Output S2: 1
    [signal subscribeNext:^(id x) {
        NSLog(@"S2: %@", x);
    }];
    
    // Output S3: 1
    [signal subscribeNext:^(id x) {
        NSLog(@"S3: %@", x);
    }];
}

- (void)testReplayLast {
    __block int num = 0;
    
    // Outputs Increment num to: 1
    RACSignal *signal = [[RACSignal createSignal:^RACDisposable *(id  subscriber) {
        num++;
        NSLog(@"Increment num to: %i", num);
        [subscriber sendNext:@(num)];
        return nil;
    }] replayLast];
    
    NSLog(@"Start subscriptions");
    
    // Output S1: 1
    [signal subscribeNext:^(id x) {
        NSLog(@"S1: %@", x);
    }];
    
    // Output S2: 1
    [signal subscribeNext:^(id x) {
        NSLog(@"S2: %@", x);
    }];
    
    // Output S3: 1
    [signal subscribeNext:^(id x) {
        NSLog(@"S3: %@", x);
    }];
}

- (void)testReplay {
    __block int num = 0;
    
    // Outputs Increment num to: 1
    RACSignal *signal = [[RACSignal createSignal:^RACDisposable *(id  subscriber) {
        num++;
        NSLog(@"Increment num to: %i", num);
        [subscriber sendNext:@(num)];
        return nil;
    }] replay];
    
    NSLog(@"Start subscriptions");
    
    // Output S1: 1
    [signal subscribeNext:^(id x) {
        NSLog(@"S1: %@", x);
    }];
    
    // Output S2: 1
    [signal subscribeNext:^(id x) {
        NSLog(@"S2: %@", x);
    }];
    
    // Output S3: 1
    [signal subscribeNext:^(id x) {
        NSLog(@"S3: %@", x);
    }];
}

- (void)testSubscribe {
    __block int num = 0;
    
    // Outputs Nothing
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id  subscriber) {
        num++;
        NSLog(@"Increment num to: %i", num);
        [subscriber sendNext:@(num)];
        return nil;
    }];
    
    NSLog(@"Start subscriptions");
    
    // Output Increment num to: 1 S1: 1
    [signal subscribeNext:^(id x) {
        NSLog(@"S1: %@", x);
    }];
    
    // Output Increment num to: 2 S2: 2
    [signal subscribeNext:^(id x) {
        NSLog(@"S2: %@", x);
    }];
    
    // Output Increment num to: 3 S3: 3
    [signal subscribeNext:^(id x) {
        NSLog(@"S3: %@", x);
    }];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
