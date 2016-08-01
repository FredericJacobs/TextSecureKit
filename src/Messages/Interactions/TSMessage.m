//  Created by Frederic Jacobs on 12/11/14.
//  Copyright (c) 2014 Open Whisper Systems. All rights reserved.

#import "TSMessage.h"
#import "TSAttachment.h"
#import <YapDatabase/YapDatabaseTransaction.h>

@implementation TSMessage

- (instancetype)initWithTimestamp:(uint64_t)timestamp
                         inThread:(TSThread *)thread
                      messageBody:(NSString *)body
                    attachmentIds:(NSArray<NSString *> *)attachmentIds
{
    self = [super initWithTimestamp:timestamp inThread:thread];

    if (!self) {
        return self;
    }

    _body = body;
    _attachmentIds = [attachmentIds mutableCopy];

    return self;
}

- (BOOL)hasAttachments
{
    return self.attachmentIds ? (self.attachmentIds.count > 0) : false;
}

- (NSString *)debugDescription
{
    if ([self hasAttachments]) {
        NSString *attachmentId = self.attachmentIds[0];
        return [NSString stringWithFormat:@"Media Message with attachmentId:%@", attachmentId];
    } else {
        return [NSString stringWithFormat:@"Message with body:%@", self.body];
    }
}

- (NSString *)description
{
    if ([self hasAttachments]) {
        NSString *attachmentId = self.attachmentIds[0];
        TSAttachment *attachment = [TSAttachment fetchObjectWithUniqueID:attachmentId];
        if (attachment) {
            return attachment.description;
        } else {
            return NSLocalizedString(@"UNKNOWN_ATTACHMENT_LABEL", @"In Inbox view, last message label for thread with corrupted attachment.");
        }
    } else {
        return self.body;
    }
}

- (void)removeWithTransaction:(YapDatabaseReadWriteTransaction *)transaction
{
    [super removeWithTransaction:transaction];
    for (NSString *attachmentId in self.attachmentIds) {
        TSAttachment *attachment = [TSAttachment fetchObjectWithUniqueID:attachmentId transaction:transaction];
        [attachment removeWithTransaction:transaction];
    };
}

@end
