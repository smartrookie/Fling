//
//  MessageCell.m
//  Fling
//
//  Created by Ryo.x on 14/11/8.
//  Copyright (c) 2014年 Ryo.x. All rights reserved.
//

#import "MessageCell.h"

@interface MessageCell() {
    UILabel *textLabel;
}

@end

#define MARGIN 10

@implementation MessageCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        textLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN, MARGIN * 2.0f, SCREEN_WIDTH - MARGIN * 2.0f, 30.0f)];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.textColor = [UIColor whiteColor];
        textLabel.font = [UIFont systemFontOfSize:22.0f];
        textLabel.numberOfLines = 0;
        textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.contentView addSubview:textLabel];
    }
    
    return self;
}

- (void)setMessageFrame:(MessageFrame *)messageFrame {
    _messageFrame = messageFrame;
    
    if (_messageFrame.message.type == MessageTypeMe) {
        self.contentView.backgroundColor = [UIColor colorWithRed:131 / 255.0f
                                                           green:175 / 255.0f
                                                            blue:155 / 255.0f
                                                           alpha:0.95f];
    } else {
        self.contentView.backgroundColor = [UIColor colorWithRed:254 / 255.0f
                                                           green:67 / 255.0f
                                                            blue:101 / 255.0f
                                                           alpha:0.95f];
    }
    
    textLabel.frame = CGRectMake(textLabel.frame.origin.x,
                                 textLabel.frame.origin.y,
                                 textLabel.bounds.size.width,
                                 _messageFrame.cellHeight - MARGIN * 4.0f);

    textLabel.text = _messageFrame.message.text;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
