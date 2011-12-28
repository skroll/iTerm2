//
//  TmuxSessionsTable.m
//  iTerm
//
//  Created by George Nachman on 12/23/11.
//  Copyright (c) 2011 Georgetech. All rights reserved.
//

#import "TmuxSessionsTable.h"

@interface TmuxSessionsTable (Private)

- (NSString *)newSessionName;
- (NSString *)nameForNewSessionWithNumber:(int)n;
- (void)updateEnabledStateOfButtons;

@end

@implementation TmuxSessionsTable

@synthesize delegate = delegate_;

- (id)init
{
    self = [super init];
    if (self) {
        model_ = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [model_ release];
    [super dealloc];
}

- (void)setDelegate:(NSObject<TmuxSessionsTableProtocol> *)delegate;
{
    delegate_ = delegate;
    [self setSessions:[delegate_ sessions]];
}

- (void)setSessions:(NSArray *)names
{
    [model_ removeAllObjects];
    [model_ addObjectsFromArray:names];
    [tableView_ reloadData];
}

- (void)selectSessionWithName:(NSString *)name
{
    NSUInteger i = [model_ indexOfObject:name];
    if (i != NSNotFound) {
        [tableView_ selectRowIndexes:[NSIndexSet indexSetWithIndex:i]
                byExtendingSelection:NO];
    }
}

- (IBAction)addSession:(id)sender
{
    [delegate_ addSessionWithName:[self newSessionName]];
}

- (IBAction)removeSession:(id)sender
{
    NSString *name = [self selectedSessionName];
    if (name) {
        [delegate_ removeSessionWithName:name];
    }
}

- (IBAction)attach:(id)sender {
    NSString *name = [self selectedSessionName];
    if (name) {
        [delegate_ attachToSessionWithName:name];
    }
}

#pragma mark NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return model_.count;
}

- (id)tableView:(NSTableView *)aTableView
    objectValueForTableColumn:(NSTableColumn *)aTableColumn
            row:(NSInteger)rowIndex
{
    NSString *name = [model_ objectAtIndex:rowIndex];
    if (aTableColumn == checkColumn_) {
        if ([[delegate_ nameOfAttachedSession] isEqualToString:name]) {
            return @"✓";
        } else {
            return @"";
        }
    } else {
        if (rowIndex < model_.count) {
            return name;
        } else {
            return nil;
        }
    }
}

- (void)tableView:(NSTableView *)aTableView
   setObjectValue:(id)anObject
   forTableColumn:(NSTableColumn *)aTableColumn
              row:(NSInteger)rowIndex
{
    [delegate_ renameSessionWithName:[model_ objectAtIndex:rowIndex]
                              toName:(NSString *)anObject];
}

#pragma mark NSTableViewDataSource

- (BOOL)tableView:(NSTableView *)aTableView
               shouldEditTableColumn:(NSTableColumn *)aTableColumn
                                 row:(NSInteger)rowIndex {
    return YES;
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    [self updateEnabledStateOfButtons];
    [delegate_ selectedSessionChangedTo:[self selectedSessionName]];
}

- (NSString *)selectedSessionName
{
    int i = [tableView_ selectedRow];
    if (i >= 0 && i < model_.count) {
        return [model_ objectAtIndex:i];
    } else {
        return nil;
    }
}

@end

@implementation TmuxSessionsTable (Private)

- (NSString *)nameForNewSessionWithNumber:(int)n
{
    if (n == 0) {
        return @"New Session";
    } else {
        return [NSString stringWithFormat:@"New Session %d", n + 1];
    }
}

- (NSString *)newSessionName
{
    int n = 0;
    NSString *candidate = [self nameForNewSessionWithNumber:n];
    while ([model_ indexOfObject:candidate] != NSNotFound) {
        n++;
        candidate = [self nameForNewSessionWithNumber:n];
    }
    return candidate;
}

- (void)updateEnabledStateOfButtons
{
    if ([tableView_ selectedRow] < 0) {
        [attachButton_ setEnabled:NO];
        [detachButton_ setEnabled:NO];
        [removeButton_ setEnabled:NO];
    } else {
        BOOL isAttachedSession = [[delegate_ nameOfAttachedSession] isEqualToString:[self selectedSessionName]];
        [attachButton_ setEnabled:!isAttachedSession];
        [detachButton_ setEnabled:isAttachedSession];
        [removeButton_ setEnabled:YES];
    }
}

@end