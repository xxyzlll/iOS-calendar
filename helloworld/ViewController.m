//
//  ViewController.m
//  helloworld
//
//  Created by H on 2021/10/9.
//

#import "ViewController.h"
#import <EventKit/EventKit.h>

#import <MobileCoreServices/MobileCoreServices.h>



static NSString *const E_DOCUMENT_PICKER_CANCELED = @"DOCUMENT_PICKER_CANCELED";
static NSString *const E_INVALID_DATA_RETURNED = @"INVALID_DATA_RETURNED";

static NSString *const OPTION_TYPE = @"type";
static NSString *const OPTION_MULTIPLE = @"allowMultiSelection";

static NSString *const FIELD_URI = @"uri";
static NSString *const FIELD_FILE_COPY_URI = @"fileCopyUri";
static NSString *const FIELD_COPY_ERR = @"copyError";
static NSString *const FIELD_NAME = @"name";
static NSString *const FIELD_TYPE = @"type";
static NSString *const FIELD_SIZE = @"size";

NSString *ju = @"0";
NSString *zi = @"0";
@interface ViewController ()<UIDocumentPickerDelegate, UIDocumentInteractionControllerDelegate>
@property (nonatomic, readonly) EKEventStore *eventStore;
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *button = [NSArray arrayWithObjects:@"新建事件",@"删除",@"none"];
    for (int i = 0; i < 3; i++){
        UIButton *but= [UIButton buttonWithType:UIButtonTypeRoundedRect];
        if(i==1){
            [but addTarget:self action:@selector(removeCalendar:) forControlEvents:UIControlEventTouchUpInside];
        }else if(i==0){
            [but addTarget:self action:@selector(add:) forControlEvents:UIControlEventTouchUpInside];
        }
        else{
        }
        [but setFrame:CGRectMake(100, i*200+100, 215, 40)];
        [but setTitle:button[i] forState:UIControlStateNormal];
        [but setExclusiveTouch:YES];
        
        [self.view addSubview:but];
    }
}

//UNI_EXPORT_METHOD(@selector(add:callback:))
-(void) add:(UIButton*)sender
{
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    __weak typeof(self) weakSelf = self;
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    NSLog(@"EKEntityTypeEvent: %l",EKEntityTypeEvent,status);
    if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
        // 获取访问权限
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (error){
                //报错啦
            }else if (!granted){
                // 被用户拒绝，不允许访问日历
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 用户既然允许事件保存到日历，那就去保存吧
                    [weakSelf saveDataCalendar:eventStore time:@"2020"];
                });
            }
        }];
    }
}

- (void)aMethod:(UIButton*)button
{
    NSLog(@"Button  clicked.");
}


- (void)removeCalendar:(NSString *)calendarId
{
    EKEventStore *store = [EKEventStore new];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (!granted) { return; }
        EKEvent* eventToRemove = [store eventWithIdentifier:@"50DFA4FD-BAF2-456D-8081-2EFA1BAFBD35:3CB54061-1698-407A-9286-730347A6E24A"];
        if (eventToRemove) {
            NSError* error = nil;
            BOOL ok = [store removeEvent:eventToRemove span:EKSpanFutureEvents commit:YES error:&error];
            if (!ok){
                NSLog(@"err: %@", error);
            }else{
                NSLog(@"删除成功");
            }
        }
    }];
}


- (void)saveDataCalendar:(EKEventStore *)eventStore time:(NSString *)time{
    NSLog(@"time %@",time);
    EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
    NSDate *nowDate = [NSDate now];
    event.title  = @"我是标题" ;              //  事件标题
    event.notes = @"sadasdasdasd";
    event.startDate = [nowDate dateByAddingTimeInterval:0];   // 开始时间
    event.endDate   = [nowDate dateByAddingTimeInterval:60 * 5];  // 结束时间
    
    //提醒时间
    [event addAlarm:[EKAlarm alarmWithRelativeOffset:-10*60]];
    [event addAlarm:[EKAlarm alarmWithRelativeOffset:-120*60]];
    
    
    [NSArray arrayWithObjects:[EKRecurrenceDayOfWeek dayOfWeek:2],[EKRecurrenceDayOfWeek dayOfWeek:3],[EKRecurrenceDayOfWeek dayOfWeek:4],[EKRecurrenceDayOfWeek dayOfWeek:5],[EKRecurrenceDayOfWeek dayOfWeek:6],nil];
    
    EKRecurrenceRule *rule = [self createRecurrenceRule:@"weekly" interval:1 occurrence:0 endDate:nil days:nil weekPositionInMonth: 0];
    
    /* EKRecurrenceRule *rule = [[EKRecurrenceRule alloc]initRecurrenceWithFrequency:EKRecurrenceFrequencyWeekly
     interval:2
     daysOfTheWeek:nil
     daysOfTheMonth:nil
     monthsOfTheYear:nil
     weeksOfTheYear:nil
     daysOfTheYear:nil
     setPositions:nil
     end:nil];*/
    
    NSLog(@"%@",rule);
    event.recurrenceRules = [NSArray arrayWithObject:rule];
    NSLog(@"%@", [NSArray arrayWithObject:rule]);
    [event setCalendar:[eventStore defaultCalendarForNewEvents]];
    NSError *err;
    [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
    //新加日历的ID可用于删除操作
    NSLog(@"event %@",event.eventIdentifier);
}


-(EKRecurrenceDayOfWeek *) dayOfTheWeekMatchingName: (NSString *) day
{
    EKRecurrenceDayOfWeek *weekDay = nil;
    
    if ([day isEqualToString:@"MO"]) {
        weekDay = [EKRecurrenceDayOfWeek dayOfWeek:2];
    } else if ([day isEqualToString:@"TU"]) {
        weekDay = [EKRecurrenceDayOfWeek dayOfWeek:3];
    } else if ([day isEqualToString:@"WE"]) {
        weekDay = [EKRecurrenceDayOfWeek dayOfWeek:4];
    } else if ([day isEqualToString:@"TH"]) {
        weekDay = [EKRecurrenceDayOfWeek dayOfWeek:5];
    } else if ([day isEqualToString:@"FR"]) {
        weekDay = [EKRecurrenceDayOfWeek dayOfWeek:6];
    } else if ([day isEqualToString:@"SA"]) {
        weekDay = [EKRecurrenceDayOfWeek dayOfWeek:7];
    } else if ([day isEqualToString:@"SU"]) {
        weekDay = [EKRecurrenceDayOfWeek dayOfWeek:1];
    }
    
    NSLog(@"%s", "dayOfTheWeek");
    NSLog(@"%@", weekDay);
    return weekDay;
}

-(EKRecurrenceFrequency)frequencyMatchingName:(NSString *)name
{
    EKRecurrenceFrequency recurrence = nil;
    if ([name isEqualToString:@"weekly"]) {
        recurrence = EKRecurrenceFrequencyWeekly;
    } else if ([name isEqualToString:@"monthly"]) {
        recurrence = EKRecurrenceFrequencyMonthly;
    } else if ([name isEqualToString:@"yearly"]) {
        recurrence = EKRecurrenceFrequencyYearly;
    } else if ([name isEqualToString:@"daily"]) {
        recurrence = EKRecurrenceFrequencyDaily;
    }
    return recurrence;
}

-(NSMutableArray *) createRecurrenceDaysOfWeek: (NSArray *) days
{
    NSMutableArray *daysOfTheWeek = nil;
    if (days.count) {
        daysOfTheWeek = [[NSMutableArray alloc] init];
        
        for (NSString *day in days) {
            EKRecurrenceDayOfWeek *weekDay = [self dayOfTheWeekMatchingName: day];
            [daysOfTheWeek addObject:weekDay];
            
        }
    }
    //添加重复
    /*NSArray *weekArr = @[@1,@2,@3];//1代表周日以此类推
     //  也可以写成NSArray *weekArr = @[@(EKWeekdaySunday),@(EKWeekdayMonday),@(EKWeekdayTuesday)];
     [weeks enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
     EKRecurrenceDayOfWeek *daysOfWeek = [EKRecurrenceDayOfWeekdayOfWeek:obj.integerValue];
     [weekArr addObject:daysOfWeek];
     }];
     EKRecurrenceRule *rule = [[EKRecurrenceRule alloc]initRecurrenceWithFrequency:EKRecurrenceFrequencyWeekly
     interval:1
     daysOfTheWeek:weekArr
     daysOfTheMonth:nil
     monthsOfTheYear:nil
     weeksOfTheYear:nil
     daysOfTheYear:nil
     setPositions:nil
     end:nil];
     [reminder addRecurrenceRule:rule];*/
    return daysOfTheWeek;
}

-(EKRecurrenceRule *)createRecurrenceRule:(NSString *)frequency interval:(NSInteger)interval occurrence:(NSInteger)occurrence endDate:(NSDate *)endDate days:(NSArray *)days weekPositionInMonth:(NSInteger) weekPositionInMonth
{
    EKRecurrenceRule *rule = nil;
    EKRecurrenceEnd *recurrenceEnd = nil;
    NSInteger recurrenceInterval = 1;
    NSArray *validFrequencyTypes = @[@"daily", @"weekly", @"monthly", @"yearly"];
    
    //------------每周工作日重复规   validFrequencyTypes必须为weekly   ------------//
    NSArray *daysOfTheWeekRecurrence = [NSArray arrayWithObjects:
                                        [EKRecurrenceDayOfWeek dayOfWeek:2],
                                        [EKRecurrenceDayOfWeek dayOfWeek:3],
                                        [EKRecurrenceDayOfWeek dayOfWeek:4],
                                        [EKRecurrenceDayOfWeek dayOfWeek:5],
                                        [EKRecurrenceDayOfWeek dayOfWeek:6],nil];
    
    // NSArray *daysOfTheWeekRecurrence  = @[[EKRecurrenceDayOfWeek dayOfWeek:2],[EKRecurrenceDayOfWeek dayOfWeek:3]];
    
    NSMutableArray *setPositions = nil;
    
    if (frequency && [validFrequencyTypes containsObject:frequency]) {
        
        if (endDate) {
            recurrenceEnd = [EKRecurrenceEnd recurrenceEndWithEndDate:endDate];
        } else if (occurrence && occurrence > 0) {
            recurrenceEnd = [EKRecurrenceEnd recurrenceEndWithOccurrenceCount:occurrence];
        }
        
        if (interval > 1) {
            recurrenceInterval = interval;
        }
        
        if (weekPositionInMonth > 0) {
            setPositions = [NSMutableArray array];
            [setPositions addObject:[NSNumber numberWithInteger: weekPositionInMonth ]];
        }
        rule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:[self frequencyMatchingName:frequency]
                                                            interval:recurrenceInterval
                                                       daysOfTheWeek:daysOfTheWeekRecurrence
                                                      daysOfTheMonth:nil
                                                     monthsOfTheYear:nil
                                                      weeksOfTheYear:nil
                                                       daysOfTheYear:nil
                                                        setPositions:setPositions
                                                                 end:recurrenceEnd];
    }
    NSLog(@"rule %@",rule);
    return rule;
}
@end
