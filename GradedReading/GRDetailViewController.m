//
//  GRDetailViewController.m
//  GradedReading
//
//  Created by XiaoYin Wang on 12-5-20.
//  Copyright (c) 2012年 HackFisher. All rights reserved.
//

#import "GRDetailViewController.h"

@interface GRDetailViewController ()
- (void)configureView;
@end

@implementation GRDetailViewController

@synthesize lessonWebView = _lessonWebView;
@synthesize levelSlider = _levelSlider;
@synthesize levelLabel = _levelLabel;
@synthesize levelSwitch = _levelSwitch;
@synthesize detailItem = _detailItem;
@synthesize level = _level;
@synthesize text = _text;
@synthesize dictionary = _dictionary;
@synthesize showLevel = _showLevel;

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        NSURL* url = [[NSBundle mainBundle] URLForResource:[self.detailItem description] withExtension:@"txt"];
        
        self.title = [self.detailItem description];
        
        // NSLog(@"The path is : %@", url);
        
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        self.text = [[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding];
        
        [self changeLevel];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self.levelSlider setValue:1];
    [self.levelSwitch setOn:YES];
    
    NSURL* url = [[NSBundle mainBundle] URLForResource:@"nce4_words" withExtension:@"txt"];
    
    if (!self.dictionary) {
        NSError *error = nil;
        
        NSString *wordsString = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error: &error];
        
        NSArray *words = [wordsString componentsSeparatedByString:NSLocalizedString(@"\n", nil)];
        
        self.dictionary = [[NSMutableDictionary alloc] init];
        
        for (NSString * word_level in words) {
            NSArray * w_l = [word_level componentsSeparatedByString:NSLocalizedString(@"\t", nil)];
            
            if ([w_l count] >=2 ) {
                [self.dictionary setObject:[w_l objectAtIndex:1] forKey:[w_l objectAtIndex:0]];
            }
        }
        
        //NSLog(@"The dictionary is  %@", self.dictionary);
    }
    
    [self configureView];
}

- (void)viewDidUnload
{
    [self setLevelLabel:nil];
    [self setLevelSlider:nil];
    [self setLessonWebView:nil];
    [self setLevelSwitch:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // self.lessonTextView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)changeHighLightWords:(id)sender {
    [self changeLevel];
}

- (void)changeLevel {
    int level = (int)self.levelSlider.value;
    BOOL show = self.levelSwitch.isOn;
    
    if (level != self.level || show != self.showLevel) {
        self.level = level;
        self.showLevel = show;
        
        //NSLog(@"The Level changed to %d", self.level);
        
        self.levelLabel.text = [[NSString alloc] initWithFormat:@"Level %d", level];
        
        NSURL* url = [[NSBundle mainBundle] URLForResource:[self.detailItem description] withExtension:@"txt"];
        
        NSString * showText = [self.text stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
        
        if (show) {
            NSMutableSet *values = [[NSMutableSet alloc] init];
            
            GRDetailViewController *view = self;
            
            [showText enumerateSubstringsInRange:NSMakeRange(0, [showText length]) options:NSStringEnumerationByWords usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                NSString *value = [view.dictionary objectForKey:substring];
                if (value && [value intValue] <= view.level) {
                    [values addObject:substring];
                }
            }];
            
            for (NSString *word in values) {
                showText = [showText stringByReplacingOccurrencesOfString:word withString:
                            [NSString stringWithFormat:@"<font color='red'>%@</font>", word]];
            }
        }
        
        [self.lessonWebView loadHTMLString:showText baseURL:url];
    }
}
@end
