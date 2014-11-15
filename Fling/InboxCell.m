//
//  InboxCell.m
//  Fling
//
//  Created by Ryo.x on 14/11/7.
//  Copyright (c) 2014年 Ryo.x. All rights reserved.
//

#import "InboxCell.h"
#import "UIImageView+WebCache.h"

@interface InboxCell() {
    UIImageView *avatarImageView;
    UILabel *nameLabel;
    UILabel *lastReplyLabel;
    UILabel *distanceLabel;
    UILabel *superscriptLabel;
}

@end

@implementation InboxCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 15, 82, 82)];
        avatarImageView.backgroundColor = [UIColor orangeColor];
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.size.width / 2.0f;
        avatarImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:avatarImageView];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 15, SCREEN_WIDTH - 120 - 50, 15)];
        nameLabel.font = [UIFont systemFontOfSize:15.0f];
        [self.contentView addSubview:nameLabel];
        
        lastReplyLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 33, SCREEN_WIDTH - 120, 36)];
        lastReplyLabel.textColor = [UIColor lightGrayColor];
        lastReplyLabel.font = [UIFont systemFontOfSize:14.0f];
        lastReplyLabel.numberOfLines = 0;
        lastReplyLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.contentView addSubview:lastReplyLabel];
        
        distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 84, 50, 15)];
        distanceLabel.backgroundColor = [UIColor lightGrayColor];
        distanceLabel.layer.cornerRadius = 3.0f;
        distanceLabel.layer.masksToBounds = YES;
        distanceLabel.textColor = [UIColor whiteColor];
        distanceLabel.font = [UIFont systemFontOfSize:12.0f];
        [self.contentView addSubview:distanceLabel];
        
#warning 添加新fling和新回复的角标label及相应方法
        superscriptLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 45, 15, 33, 18)];
        superscriptLabel.backgroundColor = [UIColor orangeColor];
        superscriptLabel.layer.cornerRadius = 9.0f;
        superscriptLabel.layer.masksToBounds = YES;
        superscriptLabel.text = @"New";
        superscriptLabel.textColor = [UIColor whiteColor];
        superscriptLabel.font = [UIFont systemFontOfSize:12.0f];
        [self.contentView addSubview:superscriptLabel];
    }
    
    return self;
}

- (void)setFling:(CFling *)fling {
    _fling = fling;
    
    [avatarImageView sd_setImageWithURL:[NSURL URLWithString:_fling.avatar]];
    nameLabel.text = _fling.nickname;
    distanceLabel.text = _fling.distance;
    
    NSString *lastReply = _fling.lastReply;
    
    if (lastReply && lastReply.length > 0) {
        lastReplyLabel.text = lastReply;
    } else {
        lastReplyLabel.text = _fling.note;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
