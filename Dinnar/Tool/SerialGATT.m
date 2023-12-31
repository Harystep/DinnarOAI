//
//  SerialGATT.m
//  BLKSoft
//
//  Created by BLKSofts on 7/13/12.
//  Copyright (c) 2012 jnhuamao.cn. All rights reserved.
//

#import "SerialGATT.h"
//64
NSString *  openChannel3Str = @"#1306413";
NSString *  openChannel2Str = @"#1206412";
NSString *  openChannel1Str = @"#1106411";

NSString *  closeChannel3Str = @"#2302919";
NSString *  closeChannel2Str = @"#2202918";
NSString *  closeChannel1Str = @"#210291B";


@implementation SerialGATT

@synthesize delegate;
@synthesize peripherals;
@synthesize manager;
@synthesize activePeripheral;

+ (SerialGATT*)shareInstance
{
    static SerialGATT *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SerialGATT alloc] init];
    });
    return manager;
}

/*!
 *  @method notification:
 *
 *  @param serviceUUID Service UUID to read from (e.g. 0x2400)
 *  @param characteristicUUID Characteristic UUID to read from (e.g. 0x2401)
 *  @param p CBPeripheral to read from
 *
 *  @discussion Main routine for enabling and disabling notification services. It converts integers
 *  into CBUUID's used by CoreBluetooth. It then searches through the peripherals services to find a
 *  suitable service, it then checks that there is a suitable characteristic on this service.
 *  If this is found, the notfication is set.
 *
 */
-(void) notification:(int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p on:(BOOL)on {
    UInt16 s = [self swap:serviceUUID];
    UInt16 c = [self swap:characteristicUUID];
    NSData *sd = [[NSData alloc] initWithBytes:(char *)&s length:2];
    NSData *cd = [[NSData alloc] initWithBytes:(char *)&c length:2];
    CBUUID *su = [CBUUID UUIDWithData:sd];
    CBUUID *cu = [CBUUID UUIDWithData:cd];
    CBService *service = [self findServiceFromUUIDEx:su p:p];
    if (!service) {
        printf("Could not find service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:su],
              [p.identifier.UUIDString cStringUsingEncoding:(NSUTF8StringEncoding)]);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUIDEx:cu service:service];
    if (!characteristic) {
        printf("Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],[p.identifier.UUIDString cStringUsingEncoding:(NSUTF8StringEncoding)]);
        return;
    }
    [p setNotifyValue:on forCharacteristic:characteristic];
}


/*!
 *  @method swap:
 *
 *  @param s Uint16 value to byteswap
 *
 *  @discussion swap byteswaps a UInt16
 *
 *  @return Byteswapped UInt16
 */

-(UInt16) swap:(UInt16)s {
    UInt16 temp = s << 8;
    temp |= (s >> 8);
    return temp;
}

/*
 * (void) setup
 * enable CoreBluetooth CentralManager and set the delegate for SerialGATT
 *
 */

-(void) setup
{
    manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

/*
 * -(int) findBTSmartPeripherals:(int)timeout
 *
 */

-(int) findBLKSoftPeripherals:(int)timeout
{
    if ([manager state] != CBManagerStatePoweredOn) {
        printf("CoreBluetooth is not correctly initialized !\n");
        return -1;
    }
    
   self.timer =  [NSTimer scheduledTimerWithTimeInterval:(float)timeout target:self selector:@selector(scanTimer:) userInfo:nil repeats:NO];
    
    //[manager scanForPeripheralsWithServices:[NSArray arrayWithObject:serviceUUID] options:0]; // start Scanning
    [manager scanForPeripheralsWithServices:nil options:0];
    return 0;
}

/*
 * scanTimer
 * when findBLKSoftPeripherals is timeout, this function will be called
 *
 */
-(void) scanTimer:(NSTimer *)timer
{
    [self stopScan];
    if (delegate != nil) {
        [self.delegate scanTimeout];
    }
    
}


-(void) stopScan
{
    if (self.timer) {
        [self.timer invalidate];
    }
    [manager stopScan];
}
/*
 *  @method printPeripheralInfo:
 *
 *  @param peripheral Peripheral to print info of
 *
 *  @discussion printPeripheralInfo prints detailed info about peripheral
 *
 */
- (void) printPeripheralInfo:(CBPeripheral*)peripheral {
    
    printf("------------------------------------\r\n");
    printf("Peripheral Info :\r\n");
    NSLog(@"UUID : %@\r\n",peripheral.identifier.UUIDString);
    printf("RSSI : %d\r\n",[peripheral.RSSI intValue]);
    printf("Name : %s\r\n",[peripheral.name cStringUsingEncoding:NSStringEncodingConversionAllowLossy]);
    printf("isConnected : %ld\r\n",(long)peripheral.state);
    printf("-------------------------------------\r\n");
    
}

/*
 * connect
 * connect to a given peripheral
 *
 */
-(void) connect:(CBPeripheral *)peripheral
{
    if (peripheral.state != CBPeripheralStateConnected ) {
        [manager connectPeripheral:peripheral options:nil];
    }
}

/*
 * disconnect
 * disconnect to a given peripheral
 *
 */
-(void) disconnect:(CBPeripheral *)peripheral
{
    [manager cancelPeripheralConnection:peripheral];
}

#pragma mark - basic operations for SerialGATT service
-(void) write:(CBPeripheral *)peripheral data:(NSData *)data
{
    [self writeValue:fileService characteristicUUID:fileSub p:peripheral data:data];
    //[self writeValue:mainService characteristicUUID:mainSub3 p:peripheral data:data];
}

-(void) read:(CBPeripheral *)peripheral
{
    printf("begin reading\n");
    
    printf("now can reading......\n");
    //[peripheral readValueForCharacteristic:dataRecvrCharacteristic];
}

-(void) notify: (CBPeripheral *)peripheral on:(BOOL)on
{
    [self notification:fileService characteristicUUID:fileSub p:peripheral on:YES];

    //[peripheral setNotifyValue:on forCharacteristic:dataNotifyCharacteristic];
}

#pragma mark - Finding CBServices and CBCharacteristics

-(CBService *) findServiceFromUUID:(CBUUID *)UUID p:(CBPeripheral *)peripheral
{//查找的是主服务，找到主服务后再找char
    printf("the services count is %d\n", peripheral.services.count);
    for (CBService *s in peripheral.services) {
        printf("<%s> is found!\n", [[s.UUID.data description] cStringUsingEncoding:NSStringEncodingConversionAllowLossy]);
        // compare s with UUID
        if ([[s.UUID data] isEqualToData:[UUID data]]) {
            return s;
        }
    }
    return  nil;
}

-(CBCharacteristic *) findCharacteristicFromUUID:(CBUUID *)UUID p:(CBPeripheral *)peripheral service:(CBService *)service
{
    for (CBCharacteristic *c in service.characteristics) {
        printf("characteristic <%s> is found!\n", [[UUID.data description] cStringUsingEncoding:NSStringEncodingConversionAllowLossy]);
        if ([[c.UUID data] isEqualToData:[UUID data]]) {
            return c;
        }
    }
    return nil;
}


#pragma mark - CBCentralManager Delegates

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    //TODO: to handle the state updates
    self.peripheralState = central.state;
    switch ([central state])
        {
            case CBManagerStateUnsupported:
                NSLog(@"蓝牙不可用");
                break;
            case CBManagerStateUnauthorized:
                NSLog(@"未授权");
                break;
            case CBManagerStatePoweredOff:
                NSLog(@"蓝牙未打开");
                break;
            case CBManagerStatePoweredOn:
                NSLog(@"蓝牙已打开");
                break;
            case CBManagerStateUnknown:
                NSLog(@"状态未知");
                break;
            default:
                NSLog(@"不明情况了");
                break;
        }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    printf("Now we found device\n");
    if (!peripherals) {
        peripherals = [[NSMutableArray alloc] initWithObjects:peripheral, nil];
        for (int i = 0; i < [peripherals count]; i++) {
            if (delegate != nil) {
                [delegate peripheralFound: peripheral];
            }
            
        }
    }
    
    {
        if(peripheral.identifier == NULL) return;
        // Add the new peripheral to the peripherals array
        for (int i = 0; i < [peripherals count]; i++) {
            CBPeripheral *p = [peripherals objectAtIndex:i];
            if(p.identifier == NULL) continue;
            NSString *b1 = p.identifier.UUIDString;
            NSString *b2 = peripheral.identifier.UUIDString;
            if ([b1 substringToIndex:16] == [b2 substringToIndex:16]) {
                // these are the same, and replace the old peripheral information
                [peripherals replaceObjectAtIndex:i withObject:peripheral];
                printf("Duplicated peripheral is found...\n");
                //[delegate peripheralFound: peripheral];
                return;
            }
        }
        printf("New peripheral is found...\n");
        [peripherals addObject:peripheral];
        if (delegate != nil) {
            [delegate peripheralFound:peripheral];
        }
        
        return;
    }
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    activePeripheral = peripheral;
    activePeripheral.delegate = self;
    
    [activePeripheral discoverServices:nil];
    
    [self printPeripheralInfo:peripheral];
    if (self.delegate != nil) {
        [self.delegate didConnect];
    }
    
    printf("connected to the active peripheral\n");
}

-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    activePeripheral = nil;
    if (self.delegate != nil) {
        [self.delegate didDisconnect];
    }
    
    printf("disconnected to the active peripheral\n");
}

-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (self.delegate != nil) {
        [self.delegate didFailToConnect];
    }
}

#pragma mark - CBPeripheral delegates

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    printf("in updateValueForCharacteristic function\n");
    
    if (error) {
        printf("updateValueForCharacteristic failed\n");
        return;
    }
    if (delegate != nil) {
        [delegate serialGATTCharValueUpdated:@"FFE1" value:characteristic.value];
    }
    


}

//////////////////////////////////////////////////////////////////////////////////////////////

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{

}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    
}

/*
 *  @method getAllCharacteristicsFromKeyfob
 *
 *  @param p Peripheral to scan
 *
 *
 *  @discussion getAllCharacteristicsFromKeyfob starts a characteristics discovery on a peripheral
 *  pointed to by p
 *
 */
-(void) getAllCharacteristicsFromKeyfob:(CBPeripheral *)p{
    
    for (int i=0; i < p.services.count; i++) {
        CBService *s = [p.services objectAtIndex:i];
        printf("Fetching characteristics for service with UUID : %s\r\n",[self CBUUIDToString:s.UUID]);
        [p discoverCharacteristics:nil forService:s];
    }
}

/*
 *  @method didDiscoverServices
 *
 *  @param peripheral Pheripheral that got updated
 *  @error error Error message if something went wrong
 *
 *  @discussion didDiscoverServices is called when CoreBluetooth has discovered services on a
 *  peripheral after the discoverServices routine has been called on the peripheral
 *
 */

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (!error) {
        printf("Services of peripheral with UUID : %s found\r\n",peripheral.identifier.UUIDString);
        [self getAllCharacteristicsFromKeyfob:peripheral];
    }
    else {
        printf("Service discovery was unsuccessfull !\r\n");
    }
}

/*
 *  @method didDiscoverCharacteristicsForService
 *
 *  @param peripheral Pheripheral that got updated
 *  @param service Service that characteristics where found on
 *  @error error Error message if something went wrong
 *
 *  @discussion didDiscoverCharacteristicsForService is called when CoreBluetooth has discovered
 *  characteristics on a service, on a peripheral after the discoverCharacteristics routine has been called on the service
 *
 */

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (!error) {
        printf("Characteristics of service with UUID : %s found\r\n",[self CBUUIDToString:service.UUID]);
        for(int i=0; i < service.characteristics.count; i++) {
            CBCharacteristic *c = [service.characteristics objectAtIndex:i];
            printf("Found characteristic %s\r\n",[ self CBUUIDToString:c.UUID]);
            CBService *s = [peripheral.services objectAtIndex:(peripheral.services.count - 1)];
            if([self compareCBUUID:service.UUID UUID2:s.UUID]) {
                printf("Finished discovering characteristics\n");
                //char data = 0x01;
                //NSData *d = [[NSData alloc] initWithBytes:&data length:1];
                //[self writeValue:mainService characteristicUUID:mainSub p:peripheral data:d];
                //[self writeValue:fileService characteristicUUID:fileSub p:peripheral data:d];
                [self notify:peripheral on:YES];
            }
        }
    }
    else {
        printf("Characteristic discorvery unsuccessfull !\r\n");
    }
}



- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (!error) {
        printf("Updated notification state for characteristic with UUID %s on service with  UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:characteristic.UUID],[self CBUUIDToString:characteristic.service.UUID],peripheral.identifier.UUIDString);
        if (delegate != nil) {
            [delegate setConnect];
        }
    }
    else {
        printf("Error in setting notification state for characteristic with UUID %s on service with  UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:characteristic.UUID],[self CBUUIDToString:characteristic.service.UUID],peripheral.identifier.UUIDString);
        printf("Error code was %s\r\n",[[error description] cStringUsingEncoding:NSStringEncodingConversionAllowLossy]);
    }
}

/*
 *  @method CBUUIDToString
 *
 *  @param UUID UUID to convert to string
 *
 *  @returns Pointer to a character buffer containing UUID in string representation
 *
 *  @discussion CBUUIDToString converts the data of a CBUUID class to a character pointer for easy printout using printf()
 *
 */
-(const char *) CBUUIDToString:(CBUUID *) UUID {
    return [[UUID.data description] cStringUsingEncoding:NSStringEncodingConversionAllowLossy];
}


/*
 *  @method UUIDToString
 *
 *  @param UUID UUID to convert to string
 *
 *  @returns Pointer to a character buffer containing UUID in string representation
 *
 *  @discussion UUIDToString converts the data of a CFUUIDRef class to a character pointer for easy printout using printf()
 *
 */
-(const char *) UUIDToString:(CFUUIDRef)UUID {
    if (!UUID) return "NULL";
    CFStringRef s = CFUUIDCreateString(NULL, UUID);
    return CFStringGetCStringPtr(s, 0);
    
}

/*
 *  @method compareCBUUID
 *
 *  @param UUID1 UUID 1 to compare
 *  @param UUID2 UUID 2 to compare
 *
 *  @returns 1 (equal) 0 (not equal)
 *
 *  @discussion compareCBUUID compares two CBUUID's to each other and returns 1 if they are equal and 0 if they are not
 *
 */

-(int) compareCBUUID:(CBUUID *) UUID1 UUID2:(CBUUID *)UUID2 {
    char b1[16];
    char b2[16];
    [UUID1.data getBytes:b1 length:16];
    [UUID2.data getBytes:b2 length:16];
    if (memcmp(b1, b2, UUID1.data.length) == 0)return 1;
    else return 0;
}

/*
 *  @method compareCBUUIDToInt
 *
 *  @param UUID1 UUID 1 to compare
 *  @param UUID2 UInt16 UUID 2 to compare
 *
 *  @returns 1 (equal) 0 (not equal)
 *
 *  @discussion compareCBUUIDToInt compares a CBUUID to a UInt16 representation of a UUID and returns 1
 *  if they are equal and 0 if they are not
 *
 */
-(int) compareCBUUIDToInt:(CBUUID *)UUID1 UUID2:(UInt16)UUID2 {
    char b1[16];
    [UUID1.data getBytes:b1 length:16];
    UInt16 b2 = [self swap:UUID2];
    if (memcmp(b1, (char *)&b2, 2) == 0) return 1;
    else return 0;
}
/*
 *  @method CBUUIDToInt
 *
 *  @param UUID1 UUID 1 to convert
 *
 *  @returns UInt16 representation of the CBUUID
 *
 *  @discussion CBUUIDToInt converts a CBUUID to a Uint16 representation of the UUID
 *
 */
-(UInt16) CBUUIDToInt:(CBUUID *) UUID {
    char b1[16];
    [UUID.data getBytes:b1 length:16];
    return ((b1[0] << 8) | b1[1]);
}

/*
 *  @method IntToCBUUID
 *
 *  @param UInt16 representation of a UUID
 *
 *  @return The converted CBUUID
 *
 *  @discussion IntToCBUUID converts a UInt16 UUID to a CBUUID
 *
 */
-(CBUUID *) IntToCBUUID:(UInt16)UUID {
    char t[16];
    t[0] = ((UUID >> 8) & 0xff); t[1] = (UUID & 0xff);
    NSData *data = [[NSData alloc] initWithBytes:t length:16];
    return [CBUUID UUIDWithData:data];
}


/*
 *  @method findServiceFromUUID:
 *
 *  @param UUID CBUUID to find in service list
 *  @param p Peripheral to find service on
 *
 *  @return pointer to CBService if found, nil if not
 *
 *  @discussion findServiceFromUUID searches through the services list of a peripheral to find a
 *  service with a specific UUID
 *
 */
-(CBService *) findServiceFromUUIDEx:(CBUUID *)UUID p:(CBPeripheral *)p {
    for(int i = 0; i < p.services.count; i++) {
        CBService *s = [p.services objectAtIndex:i];
        if ([self compareCBUUID:s.UUID UUID2:UUID]) return s;
    }
    return nil; //Service not found on this peripheral
}

/*
 *  @method findCharacteristicFromUUID:
 *
 *  @param UUID CBUUID to find in Characteristic list of service
 *  @param service Pointer to CBService to search for charateristics on
 *
 *  @return pointer to CBCharacteristic if found, nil if not
 *
 *  @discussion findCharacteristicFromUUID searches through the characteristic list of a given service
 *  to find a characteristic with a specific UUID
 *
 */
-(CBCharacteristic *) findCharacteristicFromUUIDEx:(CBUUID *)UUID service:(CBService*)service {
    for(int i=0; i < service.characteristics.count; i++) {
        CBCharacteristic *c = [service.characteristics objectAtIndex:i];
        if ([self compareCBUUID:c.UUID UUID2:UUID]) return c;
    }
    return nil; //Characteristic not found on this service
}


/*!
 *  @method writeValue:
 *
 *  @param serviceUUID Service UUID to write to (e.g. 0x2400)
 *  @param characteristicUUID Characteristic UUID to write to (e.g. 0x2401)
 *  @param data Data to write to peripheral
 *  @param p CBPeripheral to write to
 *
 *  @discussion Main routine for writeValue request, writes without feedback. It converts integer into
 *  CBUUID's used by CoreBluetooth. It then searches through the peripherals services to find a
 *  suitable service, it then checks that there is a suitable characteristic on this service.
 *  If this is found, value is written. If not nothing is done.
 *
 */

-(void) writeValue:(int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p data:(NSData *)data {
    UInt16 s = [self swap:serviceUUID];
    UInt16 c = [self swap:characteristicUUID];
    NSData *sd = [[NSData alloc] initWithBytes:(char *)&s length:2];
    NSData *cd = [[NSData alloc] initWithBytes:(char *)&c length:2];
    CBUUID *su = [CBUUID UUIDWithData:sd];
    CBUUID *cu = [CBUUID UUIDWithData:cd];
    CBService *service = [self findServiceFromUUIDEx:su p:p];
    if (!service) {
        printf("Could not find service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:su],p.identifier.UUIDString);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUIDEx:cu service:service];
    if (!characteristic) {
        printf("Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],p.identifier.UUIDString);
        return;
    }
    if (_isWithOut) {
        [p writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
        NSLog(@"WithOutResponse");
    }
    else {
        [p writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
        NSLog(@"WithResponse");
    }
    
}


/*!
 *  @method readValue:
 *
 *  @param serviceUUID Service UUID to read from (e.g. 0x2400)
 *  @param characteristicUUID Characteristic UUID to read from (e.g. 0x2401)
 *  @param p CBPeripheral to read from
 *
 *  @discussion Main routine for read value request. It converts integers into
 *  CBUUID's used by CoreBluetooth. It then searches through the peripherals services to find a
 *  suitable service, it then checks that there is a suitable characteristic on this service.
 *  If this is found, the read value is started. When value is read the didUpdateValueForCharacteristic
 *  routine is called.
 *
 *  @see didUpdateValueForCharacteristic
 */

-(void) readValue: (int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p {
    printf("In read Value");
    UInt16 s = [self swap:serviceUUID];
    UInt16 c = [self swap:characteristicUUID];
    NSData *sd = [[NSData alloc] initWithBytes:(char *)&s length:2];
    NSData *cd = [[NSData alloc] initWithBytes:(char *)&c length:2];
    CBUUID *su = [CBUUID UUIDWithData:sd];
    CBUUID *cu = [CBUUID UUIDWithData:cd];
    CBService *service = [self findServiceFromUUIDEx:su p:p];
    if (!service) {
        printf("Could not find service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:su],p.identifier.UUIDString);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUIDEx:cu service:service];
    if (!characteristic) {
        printf("Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],p.identifier.UUIDString);
        return;
    }
    [p readValueForCharacteristic:characteristic];
}

/////////////////
- (void)turnOnTheLight {
    
    if (self.lightType == 1) {
        [self turnOnTheRGBLightType];
    } else {
        [self turnOnTheRingLightType];
    }
}
- (void)turnOffTheLight {
    
    if (self.lightType == 1) {
        [self turnOffTheRGBLightType];
    } else {
        [self turnOffTheRingLightType];
    }
}

- (void)setLightNum:(NSString *)lightNum {
    NSString *content = [NSString stringWithFormat:@"%lx", (long)[lightNum integerValue]];
    NSLog(@"num:%@", content);
    _lightNum = content;
}

- (void)setLighColor:(NSString *)lighColor {
    _lighColor = lighColor;
}

- (void)setLightType:(int)lightType {
    _lightType = lightType;
}

-(void)turnOnTheRingLightType {
    if (self.activePeripheral == nil){
        return;
    }
    self.isWithOut = NO;
    NSData *data1 = [openChannel1Str dataUsingEncoding:[NSString defaultCStringEncoding]];
    [self write:self.activePeripheral data:data1];
    NSData *data2 = [openChannel2Str dataUsingEncoding:[NSString defaultCStringEncoding]];
    [self write:self.activePeripheral data:data2];
    NSData *data3 = [openChannel3Str dataUsingEncoding:[NSString defaultCStringEncoding]];
    [self write:self.activePeripheral data:data3];
}

-(void)turnOffTheRingLightType {
    if (self.activePeripheral == nil){
        return;
    }
    self.isWithOut = NO;
    NSData *data1 = [closeChannel1Str dataUsingEncoding:[NSString defaultCStringEncoding]];
    
    NSData *data2 = [closeChannel2Str dataUsingEncoding:[NSString defaultCStringEncoding]];
    [self write:self.activePeripheral data:data2];
    [self write:self.activePeripheral data:data1];
    NSData *data3 = [closeChannel3Str dataUsingEncoding:[NSString defaultCStringEncoding]];
    [self write:self.activePeripheral data:data3];
}

-(void)turnOnTheRGBLightType {
    if (self.activePeripheral == nil){
        return;
    }
    self.isWithOut = NO;
    NSString *dataStr;
    if([self.lighColor isEqualToString:@"01"]) {
        dataStr = [NSString stringWithFormat:@"FE010100%@020000030000040000FF00", self.lightNum];
    } else if ([self.lighColor isEqualToString:@"02"]) {
        dataStr = [NSString stringWithFormat:@"FE010200000200%@030000040000FF00", self.lightNum];
    } else if ([self.lighColor isEqualToString:@"03"]) {
        dataStr = [NSString stringWithFormat:@"FE010300000200000300%@040000FF00", self.lightNum];
    } else {
        dataStr = [NSString stringWithFormat:@"FE010400000200000300000400%@FF00", self.lightNum];
    }
    NSLog(@"dataStr:%@", dataStr);
    [self write:self.activePeripheral data:[self convertHexStrToData:dataStr]];
   
}

-(void)turnOffTheRGBLightType {
    if (self.activePeripheral == nil){
        return;
    }
    self.isWithOut = NO;
    //
    NSString *content = [NSString stringWithFormat:@"FE01%@0000020000030000040000FF00", self.lighColor];
    NSLog(@"off:%@", content);
    [self write:self.activePeripheral data:[self convertHexStrToData:content]];
}

- (void)xorVerify {
      //字符串
      //转data
      //转int运算,得到结果
      NSMutableArray * m_arr = [NSMutableArray array];
    //FF 01 01 00 FF  | 01 A0 7C FF 02
      [m_arr addObjectsFromArray:@[@"A0",@"01",@"7C",@"FF",@"02"]];
      //计算校验码
      NSMutableString * str_m = [NSMutableString string];
      int a[5];
      int j = 0;
    //字符串转成16进制
      for (NSString * hex in m_arr) {
        
          [str_m appendString:hex];
          NSData * data = [self convertHexStrToData:hex];
        
          int i = 0;
          [data getBytes: &i length: sizeof(i)];
            printf("%x\n", i); //按十六进制输出结果
            a[j] = i;
          j++;
      }
      int result = 0;
      //异或计算
      for (int i = 0; i < m_arr.count; i ++) {
          //进行16进制计算
          result = result ^ a[i];
      }
      printf("异或结果 : %x\n", result);
}

// 将十六进制字符串转换成NSData
- (NSData *)convertHexStrToData:(NSString *)str {
    
    if (!str || [str length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    return hexData;
}

- (NSString *)convertStringToHexStr:(NSString *)str {
    if (!str || [str length] == 0) {
        return @"";
    }
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    
    return string;
}

@end
