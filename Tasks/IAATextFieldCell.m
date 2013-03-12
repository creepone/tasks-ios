//
//  IAATextFieldCell.m
//  Tasks
//
//  Created by Tomas Vana on 3/12/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import "IAATextFieldCell.h"

@interface IAATextFieldCell() <UITextFieldDelegate> {
    UITextField *_textField;
}

- (void)setupTextField;
- (CGRect)paddedFrameForTextField;

@end

@implementation IAATextFieldCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupTextField];
    }
    return self;
}

- (void)setupTextField
{
    if(_textField != nil)
        return;
    
    _textField = [[UITextField alloc] initWithFrame:CGRectZero];
    _textField.textAlignment = NSTextAlignmentLeft;
    _textField.borderStyle = UITextBorderStyleNone;
    _textField.clearButtonMode = UITextFieldViewModeNever;
    _textField.font = [UIFont boldSystemFontOfSize:17.0];
    _textField.backgroundColor = [UIColor clearColor];
    _textField.frame = [self paddedFrameForTextField];
    _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _textField.delegate = self;
    
    [self.contentView addSubview:_textField];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _textField.frame = [self paddedFrameForTextField];
}

- (CGRect)paddedFrameForTextField
{
    CGRect frame = self.contentView.frame;
    frame.origin.x = 9.0;
    frame.origin.y = 10.0;
    frame.size.width = frame.size.width - 9.0;
    frame.size.height = 23.0;
    return frame;
}

- (UITextField *)textField
{
    return _textField;
}

#pragma mark -- Text field delegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(self.commitBlock != nil) {
        NSString *newText = self.commitBlock(textField.text);
        if(newText != nil)
            textField.text = newText;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(self.startedEditingBlock != nil) {
        self.startedEditingBlock();
    }
}

- (void)dealloc
{
    if (_textField != nil) {
        _textField.delegate = nil;
    }
}



@end
