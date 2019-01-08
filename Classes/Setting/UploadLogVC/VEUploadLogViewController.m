//
//  VEUploadLogViewController.m
//  voiceexpress
//
//  Created by Yaning Fan on 13-10-8.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#import "VEUploadLogViewController.h"
#import <MessageUI/MessageUI.h>

@interface VEUploadLogViewController () <MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) NSMutableArray *listData;
@property (strong, nonatomic) NSMutableArray *selectedList;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)back;
- (IBAction)doUploadLogFiles;

@end

@implementation VEUploadLogViewController

- (NSMutableArray *)listData
{
    if (_listData == nil)
    {
        _listData = [[NSMutableArray alloc] init];
    }
    return _listData;
}

- (NSMutableArray *)selectedList
{
    if (_selectedList == nil)
    {
        _selectedList = [[NSMutableArray alloc] init];
    }
    return _selectedList;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupNav];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError  *error = nil;
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *logsFolderPath = [documentsDirectory stringByAppendingPathComponent:@"Logs"];
    NSArray *dirArray = [fileManager contentsOfDirectoryAtPath:logsFolderPath error:&error];
    [self.listData addObjectsFromArray:dirArray];
}
/**
 *  初始化导航
 */
-(void)setupNav
{
    self.title = self.config[Upload_Log];
    UIBarButtonItem *more =[UIBarButtonItem itemWithTarget:self action:@selector(doUploadLogFiles) image:self.config[Icon_Upload] highImage:@""];
    self.navigationItem.rightBarButtonItem = more;
}

#pragma mark - IBAction

- (IBAction)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doUploadLogFiles
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        mailViewController.navigationBar.tintColor = [UIColor blackColor];
        
        [mailViewController setSubject:@"舆情快递-IPhone版 日志文件"];
        [mailViewController setToRecipients:[NSArray arrayWithObject:kSupportApproach]];
        
        [mailViewController setMessageBody:[NSString stringWithFormat:@"当前设备系统版本: %@\n", [UIDevice currentDevice].systemVersion]
                                    isHTML:NO];
        
        NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *logsFolderPath = [documentsDirectory stringByAppendingPathComponent:@"Logs"];
        
        for (NSNumber *selectedIndex in self.selectedList)
        {
            NSString *logFileName = [self.listData objectAtIndex:[selectedIndex integerValue]];
            NSString *logFilePath = [logsFolderPath stringByAppendingPathComponent:logFileName];
            
            [mailViewController addAttachmentData:[NSData dataWithContentsOfFile:logFilePath]
                                         mimeType:@"text"
                                         fileName:logFileName];
        }
        [self presentViewController:mailViewController animated:YES completion:NULL];
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"当前设备不支持发送邮件"
                                                       delegate:nil
                                              cancelButtonTitle:@"好的"
                                              otherButtonTitles:nil];
        [alert show];
        
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error
{
    if (result == MFMailComposeResultSent)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"邮件已发出"
                                                       delegate:nil
                                              cancelButtonTitle:@"好的"
                                              otherButtonTitles:nil];
        [alert show];
    }

    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.listData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellUpLoadLogFile";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    
    cell.backgroundView = [[UIImageView alloc] initWithImage:[QCZipImageTool imageNamed:kWhiteBK]];
    cell.textLabel.text = [self.listData objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
    cell.textLabel.textColor = unreadFontColor;
    cell.textLabel.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    if (indexPath.row == (self.listData.count - 1))
    {
        NSNumber *numRow = [NSNumber numberWithInteger:indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectedList removeObject:numRow];
        [self.selectedList addObject:numRow];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == (self.listData.count - 1))
    {
        return;
    }
    
    NSNumber *numRow = [NSNumber numberWithInteger:indexPath.row];
    [self.selectedList removeObject:numRow];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryNone)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectedList addObject:numRow];
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 8;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc] init];
    [headView setBackgroundColor:selectedBackgroundColor];
    
    return headView;
}

@end
