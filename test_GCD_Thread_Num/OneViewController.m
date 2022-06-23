//
//  OneViewController.m
//  test_GCD_Thread_Num
//
//  Created by yestin ✨ on 2022/6/23.
//  Copyright © 2022 Yestin. All rights reserved.
//

#import "OneViewController.h"


@interface ZYExcutor : NSObject
@property(nonatomic, assign)NSInteger num;
@end
@implementation ZYExcutor
- (instancetype)initWithNum:(NSInteger)num
{
  self = [super init];
  if (self) {
    self.num = num;
  }
  return self;
}
- (void)doSth {
  NSLog(@"%s begin no.%@", __func__, @(self.num));
  dispatch_async(dispatch_get_global_queue(0, 0), ^{
    NSLog(@"%s async begin no.%@", __func__, @(self.num));
    sleep(3);
    NSLog(@"%s async done  no.%@", __func__, @(self.num));
  });
  NSLog(@"%s done  no.%@", __func__, @(self.num));
}
-(void)dealloc {
  NSLog(@"%s no.%@", __func__, @(self.num));
}
@end



@interface OneViewController ()
@property(nonatomic, strong)NSOperationQueue *queue;
@end

@implementation OneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  self.view.backgroundColor = [UIColor blueColor];
  self.title = @"n任务 m并发数，任务内主对象销毁";
  
  NSOperationQueue *queue = [[NSOperationQueue alloc] init];
  [queue setMaxConcurrentOperationCount:3];
  self.queue = queue;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
  
  [self test_NSOperationQueue];
}

//  NSOperationQueue
- (void)test_NSOperationQueue {
    
    NSLog(@"begin: %@",[NSThread currentThread]);
    for (NSInteger i = 0; i < 10; i++) {
        
        __block NSInteger index = i;
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^(){
          NSLog(@"task i_%@ begin", @(i));
          [[[ZYExcutor alloc]initWithNum:index] doSth]; //根据打印结果看，任务内的ZYExcutor对象，生命周期被管理的妥妥的，ZYExcutor里的异步任务执行完毕，才会销毁
          NSLog(@"执行第%zd次操作，线程：%@",index, [NSThread currentThread]);
          NSLog(@"task i_%@ end", @(i));
        }];
        
        [self.queue addOperation:operation];
    }

}





@end


/*
2022-06-23 17:15:56.397929+0800 test_GCD_Thread_Num[9681:3018960] begin: <_NSMainThread: 0x600002a28140>{number = 1, name = main}
2022-06-23 17:15:56.398258+0800 test_GCD_Thread_Num[9681:3019512] task i_0 begin
2022-06-23 17:15:56.398258+0800 test_GCD_Thread_Num[9681:3019513] task i_1 begin
2022-06-23 17:15:56.398343+0800 test_GCD_Thread_Num[9681:3019504] task i_2 begin
2022-06-23 17:15:56.398460+0800 test_GCD_Thread_Num[9681:3019512] -[ZYExcutor doSth] begin no.0
2022-06-23 17:15:56.398459+0800 test_GCD_Thread_Num[9681:3019513] -[ZYExcutor doSth] begin no.1
2022-06-23 17:15:56.398488+0800 test_GCD_Thread_Num[9681:3019504] -[ZYExcutor doSth] begin no.2
2022-06-23 17:15:56.398566+0800 test_GCD_Thread_Num[9681:3019512] -[ZYExcutor doSth] done  no.0
2022-06-23 17:15:56.398579+0800 test_GCD_Thread_Num[9681:3019513] -[ZYExcutor doSth] done  no.1
2022-06-23 17:15:56.398599+0800 test_GCD_Thread_Num[9681:3019504] -[ZYExcutor doSth] done  no.2
2022-06-23 17:15:56.398599+0800 test_GCD_Thread_Num[9681:3019506] -[ZYExcut2022-06-23 17:15:56.398664+0800 test_GCD_Thread_Num[9681:3019510] -[ZYExcutor doSth]_block_invoke async begin no.1
or doSth]_block_invoke async begin no.0
2022-06-23 17:15:56.398691+0800 test_GCD_Thread_Num[9681:3019509] -[ZYExcutor doSth]_block_invoke async begin no.2
2022-06-23 17:15:56.398699+0800 test_GCD_Thread_Num[9681:3019512] 执行第0次操作，线程：<NSThread: 0x600002a5c480>{number = 14, name = (null)}
2022-06-23 17:15:56.399333+0800 test_GCD_Thread_Num[9681:3019512] task i_0 end
2022-06-23 17:15:56.399514+0800 test_GCD_Thread_Num[9681:3019513] 执行第1次操作，线程：<NSThread: 0x600002a4fc80>{number = 15, name = (null)}
2022-06-23 17:15:56.399590+0800 test_GCD_Thread_Num[9681:3019512] task i_3 begin
2022-06-23 17:15:56.399704+0800 test_GCD_Thread_Num[9681:3019504] 执行第2次操作，线程：<NSThread: 0x600002a2be40>{number = 12, name = (null)}
2022-06-23 17:15:56.399845+0800 test_GCD_Thread_Num[9681:3019513] task i_1 end
2022-06-23 17:15:56.399953+0800 test_GCD_Thread_Num[9681:3019504] task i_2 end
2022-06-23 17:15:56.400030+0800 test_GCD_Thread_Num[9681:3019512] -[ZYExcutor doSth] begin no.3
2022-06-23 17:15:56.400128+0800 test_GCD_Thread_Num[9681:3019513] task i_4 begin
2022-06-23 17:15:56.409803+0800 test_GCD_Thread_Num[9681:3019513] -[ZYExcutor doSth] begin no.4
2022-06-23 17:15:56.409875+0800 test_GCD_Thread_Num[9681:3019504] task i_5 begin
2022-06-23 17:15:56.409972+0800 test_GCD_Thread_Num[9681:3019512] -[ZYExcutor doSth] done  no.3
2022-06-23 17:15:56.409925+0800 test_GCD_Thread_Num[9681:3019513] -[ZYExcutor doSth] done  no.4
2022-06-23 17:15:56.409956+0800 test_GCD_Thread_Num[9681:3019511] -[ZYExcutor doSth]_block_invoke async begin no.4
2022-06-23 17:15:56.409986+0800 test_GCD_Thread_Num[9681:3019504] -[ZYExcutor doSth] begin no.5
2022-06-23 17:15:56.409992+0800 test_GCD_Thread_Num[9681:3019505] -[ZYExcutor doSth]_block_invoke async begin no.3
2022-06-23 17:15:56.410062+0800 test_GCD_Thread_Num[9681:3019512] 执行第3次操作，线程：<NSThread: 0x600002a5c480>{number = 14, name = (null)}
2022-06-23 17:15:56.410107+0800 test_GCD_Thread_Num[9681:3019513] 执行第4次操作，线程：<NSThread: 0x600002a4fc80>{number = 15, name = (null)}
2022-06-23 17:15:56.410232022-06-23 17:15:56.410319+0800 test_GCD_Thread_Num[9681:3019513] task i_4 end
4+0800 test_GCD_Thread_Num[9681:3019512] task i_3 end
2022-06-23 17:15:56.410381+0800 test_GCD_Thread_Num[9681:3019504] -[ZYExcutor doSth] done  no.5
2022-06-23 17:15:56.410409+0800 test_GCD_Thread_Num[9681:3019507] -[ZYExcutor doSth]_block_invoke async begin no.5
2022-06-23 17:15:56.429732+0800 test_GCD_Thread_Num[9681:3019504] 执行第5次操作，线程：<NSThread: 0x600002a2be40>{number = 12, name = (null)}
2022-06-23 17:15:56.429745+0800 test_GCD_Thread_Num[9681:3019513] task i_6 begin
2022-06-23 17:15:56.429759+0800 test_GCD_Thread_Num[9681:3019508] task i_7 begin
2022-06-23 17:15:56.429838+0800 test_GCD_Thread_Num[9681:3019504] task i_5 end
2022-06-23 17:15:56.429837+0800 test_GCD_Thread_Num[9681:3019513] -[ZYExcutor doSth] begin no.6
2022-06-23 17:15:56.429890+0800 test_GCD_Thread_Num[9681:3019508] -[ZYExcutor doSth] begin no.7
2022-06-23 17:15:56.429956+0800 test_GCD_Thread_Num[9681:3019504] task i_8 begin
2022-06-23 17:2022-06-23 17:15:56.430104+0800 test_GCD_Thread_Num[9681:3019512] -[ZYExcutor doSth]_block_invoke async begin no.6
2022-06-23 17:15:56.430133+0800 test_GCD_Thread_Num[9681:3019504] -[ZYExcutor doSth] begin no.8
2022-06-23 17:15:56.430303+0800 test_GCD_Thread_Num[9681:3019652] -[ZYExcutor doSth]_block_invoke async begin no.7
15:56.430087+0800 test_GCD_Thread_Num[9681:3019513] -[ZYExcutor doSth] done  no.6
2022-06-23 17:15:56.430230+0800 test_GCD_Thread_Num[9681:3019508] -[ZYExcutor doSth] done  no.7
2022-06-23 17:15:56.430541+0800 test_GCD_Thread_Num[9681:3019504] -[ZYExcutor doSth] done  no.8
2022-06-23 17:15:56.430616+0800 test_GCD_Thread_Num[9681:3019653] -[ZYExcutor doSth]_block_invoke async begin no.8
2022-06-23 17:15:56.430625+0800 test_GCD_Thread_Num[9681:3019513] 执行第6次操作，线程：<NSThread: 0x600002a4fc80>{number = 15, name = (null)}
2022-06-23 17:15:56.430722+0800 test_GCD_Thread_Num[9681:3019504] 执行第8次操作，线程：<NSThread: 0x600002a2be40>{number = 12, name = (null)}
2022-06-23 17:15:56.430773+0800 test_GCD_Thread_Num[9681:3019508] 执行第7次操作，线程：<NSThread: 0x600002a54680>{number = 16, name = (null)}
2022-06-23 17:15:56.430820+0800 test_GCD_Thread_Num[9681:3019513] task i_6 end
2022-06-23 17:15:56.430950+0800 test_GCD_Thread_Num[9681:3019504] task i_8 end
2022-06-23 17:15:56.431003+0800 test_GCD_Thread_Num[9681:3019508] task i_7 end
2022-06-23 17:15:56.431251+0800 test_GCD_Thread_Num[9681:3019513] task i_9 begin
2022-06-23 17:15:56.431435+0800 test_GCD_Thread_Num[9681:3019513] -[ZYExcutor doSth] begin no.9
2022-06-23 17:15:56.431543+0800 test_GCD_Thread_Num[9681:3019513] -[ZYExcutor doSth] done  no.9
2022-06-23 17:15:56.431569+0800 test_GCD_Thread_Num[9681:3019508] -[ZYExcutor doSth]_block_invoke async begin no.9
2022-06-23 17:15:56.431847+0800 test_GCD_Thread_Num[9681:3019513] 执行第9次操作，线程：<NSThread: 0x600002a4fc80>{number = 15, name = (null)}
2022-06-23 17:15:56.432021+0800 test_GCD_Thread_Num[9681:3019513] task i_9 end






2022-06-23 17:15:59.405043+0800 test_GCD_Thread_Num[9681:3019510] -[ZYExcutor doSth]_block_invoke async done  no.1
2022-06-23 17:15:59.405174+0800 test_GCD_Thread_Num[9681:3019509] -[ZYExcutor doSth]_block_invoke async done  no.2
2022-06-23 17:15:59.405142+0800 test_GCD_Thread_Num[9681:3019506] -[ZYExcutor doSth]_block_invoke async done  no.0
2022-06-23 17:15:59.405827+0800 test_GCD_Thread_Num[9681:3019509] -[ZYExcutor dealloc] no.2
2022-06-23 17:15:59.405830+0800 test_GCD_Thread_Num[9681:3019510] -[ZYExcutor dealloc] no.1
2022-06-23 17:15:59.405930+0800 test_GCD_Thread_Num[9681:3019506] -[ZYExcutor dealloc] no.0
2022-06-23 17:15:59.415308+0800 test_GCD_Thread_Num[9681:3019505] -[ZYExcutor doSth]_block_invoke async done  no.3
2022-06-23 17:15:59.415249+0800 test_GCD_Thread_Num[9681:3019511] -[ZYExcutor doSth]_block_invoke async done  no.4
2022-06-23 17:15:59.415776+0800 test_GCD_Thread_Num[9681:3019505] -[ZYExcutor dealloc] no.3
2022-06-23 17:15:59.415883+0800 test_GCD_Thread_Num[9681:3019511] -[ZYExcutor dealloc] no.4
2022-06-23 17:15:59.435145+0800 test_GCD_Thread_Num[9681:3019507] -[ZYExcutor doSth]_block_invoke async done  no.5
2022-06-23 17:15:59.435375+0800 test_GCD_Thread_Num[9681:3019653] -[ZYExcutor doSth]_block_invoke async done  no.8
2022-06-23 17:15:59.435592+0800 test_GCD_Thread_Num[9681:3019512] -[ZYExcutor doSth]_block_invoke async done  no.6
2022-06-23 17:15:59.437258+0800 test_GCD_Thread_Num[9681:3019653] -[ZYExcutor dealloc] no.8
2022-06-23 17:15:59.437316+0800 test_GCD_Thread_Num[9681:3019507] -[ZYExcutor dealloc] no.5
2022-06-23 17:15:59.437454+0800 test_GCD_Thread_Num[9681:3019652] -[ZYExcutor doSth]_block_invoke async done  no.7
2022-06-23 17:15:59.437485+0800 test_GCD_Thread_Num[9681:3019508] -[ZYExcutor doSth]_block_invoke async done  no.9
2022-06-23 17:15:59.437650+0800 test_GCD_Thread_Num[9681:3019512] -[ZYExcutor dealloc] no.6
2022-06-23 17:15:59.437826+0800 test_GCD_Thread_Num[9681:3019652] -[ZYExcutor dealloc] no.7
2022-06-23 17:15:59.438014+0800 test_GCD_Thread_Num[9681:3019508] -[ZYExcutor dealloc] no.9
*/
