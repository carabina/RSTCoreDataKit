//
//  Rosetta Stone
//  http://product.rosettastone.com/news/
//
//
//  Documentation
//  http://cocoadocs.org/docsets/RSTCoreDataKit
//
//
//  GitHub
//  https://github.com/rosettastone/RSTCoreDataKit
//
//
//  License
//  Copyright (c) 2014 Rosetta Stone
//  Released under a BSD license: http://opensource.org/licenses/BSD-3-Clause
//

#import "RSTCoreDataKitTestCase.h"


@interface RSTCoreDataStackTests : RSTCoreDataKitTestCase

@property (nonatomic, strong) RSTCoreDataModel *model;

@end


@implementation RSTCoreDataStackTests

- (void)setUp
{
    [super setUp];
    self.model = [[RSTCoreDataModel alloc] initWithName:@"TestModel" bundle:[NSBundle bundleForClass:[self class]]];
}

- (void)tearDown
{
    [self.model removeExistingModelStore];
    [super tearDown];
}

- (void)testCoreDataStackInit
{
    // GIVEN: a core data model
    RSTCoreDataModel *model = [[RSTCoreDataModel alloc] initWithName:@"TestModel" bundle:[NSBundle bundleForClass:[self class]]];

    // WHEN: we init a core data stack
    RSTCoreDataStack *stack = [[RSTCoreDataStack alloc] initWithStoreURL:model.storeURL
                                                                modelURL:model.modelURL
                                                                 options:nil
                                                         concurrencyType:NSMainQueueConcurrencyType];

    // THEN: init succeeds and the store exists on disk
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:model.storeURL.path]);
    XCTAssertNotNil(stack);
    XCTAssertNotNil(stack.managedObjectContext);
    XCTAssertEqual(stack.managedObjectContext.concurrencyType, NSMainQueueConcurrencyType);
}

- (void)testCoreDataStackInitInMemory
{
    // GIVEN: a core data model
    RSTCoreDataModel *model = [[RSTCoreDataModel alloc] initWithName:@"TestModel" bundle:[NSBundle bundleForClass:[self class]]];

    // WHEN: we init an in-memory core data stack
    RSTCoreDataStack *stack = [RSTCoreDataStack stackWithInMemoryStoreWithModelURL:model.modelURL];

    // THEN: init succeeds and the store does not exist disk
    XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:model.storeURL.path]);
    XCTAssertNotNil(stack);
    XCTAssertNotNil(stack.managedObjectContext);
}

- (void)testCoreDataStackInitPrivateQueue
{
    // GIVEN: a core data model
    RSTCoreDataModel *model = [[RSTCoreDataModel alloc] initWithName:@"TestModel" bundle:[NSBundle bundleForClass:[self class]]];

    // WHEN: we init an in-memory core data stack
    RSTCoreDataStack *stack = [RSTCoreDataStack privateStackWithStoreURL:model.storeURL modelURL:model.modelURL];

    // THEN: init succeeds and the store does not exist disk
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:model.storeURL.path]);
    XCTAssertNotNil(stack);
    XCTAssertNotNil(stack.managedObjectContext);
    XCTAssertEqual(stack.managedObjectContext.concurrencyType, NSPrivateQueueConcurrencyType);
}

- (void)testChildContextCreate
{
    // GIVEN: a core data stack

    // WHEN: we request a child context
    NSManagedObjectContext *childContext = [self.testStack newChildContextWithConcurrencyType:NSPrivateQueueConcurrencyType
                                                                              mergePolicyType:NSMergeByPropertyObjectTrumpMergePolicyType];

    // THEN: a child context is successfully created
    XCTAssertNotNil(childContext);
    XCTAssertEqualObjects(childContext.parentContext, self.testStack.managedObjectContext);
}

@end