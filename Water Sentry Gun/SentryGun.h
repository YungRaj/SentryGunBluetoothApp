
#ifndef SentryGun_h
#define SentryGun_h

#define SENTRY_GUN_MAGIC 0xdeadbeef

#define RPI4_UUID @"11223344-5566-7788-9900-aabbccddeeff"
#define RPI4_SentryGun_UUID @"11223344-5566-7788-9900-deeaadbeeeff"

enum
{
    SentryGunInit = 0,
    SentryGunMoveForward,
    SentryGunMoveBackward,
    SentryGunTurnRight,
    SentryGunTurnLeft,
    SentryGunStop,
    SentryGunShoot,
    SentryGunAuto,
};

typedef struct
{
    uint32_t cmd;
    uint32_t duration;
} SentryGunCommand;

typedef struct
{
    uint32_t magic;
    char action[16];
    
    SentryGunCommand command;
} SentryGunBluetoothData;


#endif
