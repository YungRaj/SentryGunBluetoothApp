//
//  ViewController.m
//  Water Sentry Gun
//
//  Created by Ilhan Raja on 10/10/20.
//

#import "ViewController.h"


@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *connectButton;

@end

@implementation ViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    
}
-(IBAction)connectButtonPressed:(id)sender
{
    SentryGunBluetoothData *data = calloc(1, sizeof(SentryGunBluetoothData));
    data->magic = SENTRY_GUN_MAGIC;
    data->command = SentryGunInit;
    strlcpy((char*)&data->action, "connect", strlen("connect"));
    
    NSData *value = [NSData dataWithBytes:data length:sizeof(SentryGunBluetoothData)];
    
    [self.rpi4Peripheral writeValue:value forCharacteristic:nil type:CBCharacteristicWriteWithResponse];
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    if([localName length] > 0 )
    {
        [self.centralManager stopScan];
        self.rpi4Peripheral = peripheral;
        peripheral.delegate = self;
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}

-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if([central state] == CBManagerStatePoweredOff)
    {
    NSLog(@"Core Bluetooth BLE hardware powered off");
    }
    else if([central state] == CBManagerStatePoweredOn){
        NSLog(@"Core Bluetooth BLE hardware powered on and ready");
        NSArray *services = @[[CBUUID UUIDWithString:RPI4_UUID],[CBUUID UUIDWithString:RPI4_UUID]];
        [self.centralManager scanForPeripheralsWithServices:services options:nil];
    }
    else if([central state] == CBManagerStateUnauthorized){
        NSLog(@"Core Bluetooth BLE state is unauthorized");
    }
    else if ([central state] == CBManagerStateUnknown){
        NSLog(@"Core Bluetooth BLE state is unknown");
    }
    else if ([central state] == CBManagerStateUnsupported){
        NSLog(@"Core Bluetooth BLE state is unsupported");
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    for(CBService *service in peripheral.services){
        NSLog(@"Discovered Service: %@", service.UUID);
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if([service.UUID isEqual:[CBUUID UUIDWithString:RPI4_UUID]]){
        for(CBCharacteristic *aChar in service.characteristics) {
            if([aChar.UUID isEqual:[CBUUID UUIDWithString:RPI4_UUID]]){
                [peripheral setNotifyValue:YES forCharacteristic:aChar];

            }
        }
    }
    if([service.UUID isEqual:[CBUUID UUIDWithString:RPI4_UUID]]){
        for(CBCharacteristic *aChar in service.characteristics) {
            [peripheral readValueForCharacteristic:aChar];
        }
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"Peripheral State Changed");
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:RPI4_UUID]])
    {
    }
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:RPI4_UUID]])
    {
    }
}


@end
