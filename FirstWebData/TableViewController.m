//
//  TableViewController.m
//  FirstWebData
//
//  Created by Frank Smieja on 22/12/2013.
//  Copyright (c) 2013 Smartatech. All rights reserved.
//

#import "TableViewController.h"
#import "UPGrabData.h"
#import "ViewController.h"
#import "ASIHTTPRequest.h"

UPGrabData *grabData;

@interface TableViewController ()
{
    NSMutableArray *tableData;
    NSMutableArray *tableDetail;
    NSMutableArray *tableImage;
}
@end

@implementation TableViewController


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Initialize table data
    /*
    tableData = [NSMutableArray arrayWithObjects:@"Egg Benedict", @"Mushroom Risotto", @"Full Breakfast", @"Hamburger", @"Ham and Egg Sandwich", @"Creme Brelee", @"White Chocolate Donut", @"Starbucks Coffee", nil];
     */
   // myTableView.delegate = self;
    tableData = [[NSMutableArray alloc] init];
    tableDetail = [[NSMutableArray alloc] init];
    tableImage = [[NSMutableArray alloc] init];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]
                                        init];
    refreshControl.tintColor = [UIColor brownColor];
    [refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    [self updateTable];
}


-(void)reloadData {

    [self performSelector:@selector(updateTable) withObject:nil];
 
}

- (void)changeSorting
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:nil ascending:self.ascending];
    NSArray *sortDescriptors = @[sortDescriptor];
    
//    _objects = [_objects sortedArrayUsingDescriptors:sortDescriptors];
    
    _ascending = !_ascending;
    
    [self performSelector:@selector(updateTable) withObject:nil  afterDelay:1];
}

- (void)updateTable
{
    
    [self GetUrlData:self];
    
    //[self.tableView reloadData];
    
    //[self.refreshControl endRefreshing];
}

-(IBAction)GetUrlData:(id)sender{
    grabData = [[UPGrabData alloc] init];
    [grabData setDelegate:self];
    [grabData GetUrlListForUser];
}

-(IBAction)Logout:(id)sender{
    [tableData removeAllObjects];
    [self.tableView reloadData];
  //  [ASIHTTPRequest removeCredentialsForHost:@"orion" port:0 protocol:@"http" realm:nil];
    [ASIHTTPRequest clearSession];
    NSURLCredentialStorage *store = [NSURLCredentialStorage sharedCredentialStorage];
    for (NSURLProtectionSpace *space in [store allCredentials]) {
        NSDictionary *userCredentialMap = [store credentialsForProtectionSpace:space];
        for (NSString *user in userCredentialMap) {
            NSURLCredential *credential = [userCredentialMap objectForKey:user];
            [store removeCredential:credential forProtectionSpace:space];
        }
    }
    
    // clear keychain
    /*
    NSURL *url = [NSURL URLWithString:kConnectorUrlString];
    [ASIHTTPRequest removeCredentialsForHost:[url host] port:[[url port] intValue] protocol:[url scheme] realm:kConnectorRealm];
     */
    NSLog(@"logged out");
    [self viewDidLoad];

}

-(void)populateUrlList:(NSArray *)urlList {
    [tableData removeAllObjects];
    int i=0;
    for (NSDictionary *thisUrl in urlList) {
        NSString *urlName = [thisUrl objectForKey:@"url"];
        NSString *urlAverage = [thisUrl objectForKey:@"average"];
        NSString *isDown = [thisUrl objectForKey:@"is_down"] ;
        NSString *isOverThreshold = [thisUrl objectForKey:@"is_over_threshold"];
        [tableData insertObject:urlName atIndex:i];
        [tableDetail insertObject:urlAverage atIndex:i];
        
        if ([isDown boolValue])
            [tableImage insertObject:@"alert.png" atIndex:i];
        else if ([isOverThreshold boolValue])
            [tableImage insertObject:@"slow.jpg" atIndex:i];
        else
            [tableImage insertObject:@"ok2.png" atIndex:i];
         
        i++;
    }
}

-(void)reportError:(NSString *)alertMessage {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

-(void)downloadSuccessful:(BOOL)success withData:(UPGrabData *)grabData {
  //  [myActivityIndicator stopAnimating];
    if (success) {
        [self populateUrlList:grabData.urlList];
        [self.tableView reloadData];
    }
    else {
        [self reportError:@"Unexpected error"];
    }
    
    [self.refreshControl endRefreshing];

    NSLog(@"Finished request");
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [tableData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"idUrlList";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    
    /*
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MyIdentifier"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSDictionary *item = (NSDictionary *)[self.content objectAtIndex:indexPath.row];
    cell.textLabel.text = [item objectForKey:@"mainTitleKey"];
    cell.detailTextLabel.text = [item objectForKey:@"secondaryTitleKey"];
    NSString *path = [[NSBundle mainBundle] pathForResource:[item objectForKey:@"imageKey"] ofType:@"png"];
    UIImage *theImage = [UIImage imageWithContentsOfFile:path];
    cell.imageView.image = theImage;
    return cell;
    */
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [tableData objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Current average: %@ms", [tableDetail objectAtIndex:indexPath.row]];
    cell.imageView.image = [UIImage imageNamed:[tableImage objectAtIndex:indexPath.row]];
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];

    /*
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"You selected %@", url] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    */
    
    UIStoryboard *sboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                     bundle:nil];
    ViewController *urlView = [sboard instantiateViewControllerWithIdentifier:@"idUrlDetail"];

    [self.navigationController pushViewController:urlView animated:YES];
    [urlView populateUrlDetails:[grabData GetUrlDetails:indexPath.row]];
    
}

@end
