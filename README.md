Flashing ESPHome devices
==========

Preamble
----------

Many off-the-shelf devices are powered with ESP8285 or ESP8266 chips, in devices with white-label
firmware provided by a company called Tuya. The project [tuya-convert](https://github.com/ct-Open-Source/tuya-convert)
exists to hack these devices and enable us to load custom firmware.

Firmware options include:

 * Tasmota - the original; many devices are known and pin configurations [listed here](https://templates.blakadder.com/)
 * Espurna - an alternative which has a nice Web UI and is easily configurable with custom builds
 * **ESP Home** - a versetile firmware which supports a lot of different chips in practice, and has many
   great features for the advanced user

I use [ESP Home](https://esphome.io/) both for NodeMCU type ESP8266 boards, and for off-the-shelf
devices running Tuya.


My Devices
----------

|ID|Type|Manufacturer|Model|Source|
|--|----|------------|-----|------|
|ea9c90|Plug Switch|Kogan SmarterHome|Smart Plug with Energy Meter|kogan.com|
|040cab|Plug Switch|Kogan SmarterHome|Smart Plug with Energy Meter|kogan.com|
|047c60|Plug Switch|Kogan SmarterHome|Smart Plug with Energy Meter|kogan.com|
|6c7fe7|Light|Kogan SmarterHome|RGBWW|kogan.com|
|6c8595|Light|Kogan SmarterHome|RGBWW|kogan.com|
|c05775|Plug Switch|Smart Connect|PC189HA|Bunnings|
|92d0f9|Plug Switch|Smart Connect|PC189HA|Bunnings|
|f58f91|4x Plug Switch|Smart Connect|PB89HA|Bunnings|
|10945b|ESP8622|Generic|NodeMCUv2|Aliexpress|
|774ba4|ESP8622|Generic|NodeMCUv2|Aliexpress|
|707a3c|ESP32|Wemos|LOLIN D32|Aliexpress|


Process
----------

 0. Extract the ID for the above table using `esptool.py`, as specified [below](#id-field)
 1. [Configure a custom image using the esphome templates](#template)
 2. [Build the custom image](#build)
 3. For store-bought devices, use [`tuya-convert`](#tuya-convert) to do the initial hack, flashing the binary built previously
 4. Ensure device appears on wifi network
 5. Update "My Devices" table in this `README.md`
 6. Setup esphome config and re-flash to esphome


### ID Field

The `id` for a given device is the last 6 chars of its MAC address. One can retrieve the MAC by
attaching the device via USB and running:

```
esptool.py flash_id | grep MAC | cut -d : -f 5-7
```

ESP Home
----------

### Template

Templates for different devices are in the [`templates`](./templates) directory. These can be
composed together when multiple I/O devices are attached to a single ESP. It's trivial to create
new templates from the [ESP Home docs](https://esphome.io/index.html).

The `render` script outputs a file to feed `esphome`:

```
render 774ba4 192.168.20.52  esp8266 'ESP8622 2' dht22 temt6000 --room 'Baby Bedroom'
```

CLI options are as follows:

```
Usage: render [OPTIONS] DEVICE_ID DEVICE_IP DEVICE_TYPE NAME [TEMPLATES]...

  Render a set of templates as an ESPHome configuration.

  DEVICE_ID  Unique identifier for this ESP
  DEVICE_IP  Static IP on your LAN for this ESP
  DEVICE_TYPE  PlatformIO platform/board combination. One of lolin,lolin_pro,esp32,esp8266,esp8285
  NAME         Friendly device name, which will show in HA
  TEMPLATES    List of templates to render

Options:
  --room TEXT     Name of the room for this sensor
  --address TEXT  Sensor address
  --help          Show this message and exit.
```


### Build

A `Makefile` is included to simplify usage across many ESPs.

Render the template configured for device `c0a4ba`, and build the firmware binary:

    DEVICE=c0a4ba make compile

Under the hood, this calls esphome `compile` command:

    esphome compile build/device_10945b.yaml


### Initial flash with esptool


```
> esptool.py --before default_reset --after hard_reset --baud 460800 --chip esp8266 write_flash 0x0 774ba4/.pioenvs/774ba4/firmware.bin
esptool.py v2.8
Serial port /dev/ttyUSB0
Connecting....
Detecting chip type... ESP8266
Chip is ESP8266EX
Features: WiFi
Crystal is 26MHz
MAC: 84:f3:eb:c0:a4:b4
Uploading stub...
Running stub...
Stub running...
Configuring flash size...
Compressed 433552 bytes to 315828...
Wrote 433552 bytes (315828 compressed) at 0x00000000 in 28.8 seconds (effective 120.5 kbit/s)...
Hash of data verified.

Leaving...
Hard resetting via RTS pin...
```

### OTA flash

Once a device has been flashed to ESP Home, one can update directly from the CLI via OTA on the
network. If that is failing, switch to flash via USB.

    DEVICE=c0a4ba make upload


## Templates

Notes on the templates and their respective components. Mostly everything comes from Aliexpress.


### DS18B20

_[`ds18b20.tmpl`](./templates/ds18b20.tmpl)_

[Dallas](https://esphome.io/components/sensor/dallas.html) 1-wire protocol temperature sensors, such
as the DS18B20.

These are fast to read, and are fully enclosed and therefore safe for outdoors.

Many sensors can be put on the same data line (hence "1-wire protocol"); each device is identified
by a hexidecimal address, which esphome will print on startup when it scans the Dallas bus. 

For indoors usage, the DHT22 is preferred as no circuit is required - the DHT22 pins attach directly
the ESP board. The exception is the Raspberry Pi - DHT22 support is terrible (the Adafruit
libraries), so preference is to use the [`w1thermsensor`](https://github.com/timofurrer/w1thermsensor)
project as in [mafrosis/w1therm](https://github.com/mafrosis/w1therm).

```
┌──────────────────┐
│ DS18B20          │
│                  │
│ RED YELLOW BLACK │
└──────────────────┘
   │    │     │
   │    │     │
   │    │     │
┌─────────┐   │
│ 2.2k R  │   └┐
└─────────┘    │
   │    │      │
   │    │      │
   │    │      │

  3V    D5    GND
```


## Tuya Convert

The [tuya-convert](https://github.com/ct-Open-Source/tuya-convert) project exists to do OTA hacks
on whitelabelled ESP devices.


TODO how to use tuya convert


### Note on Newer Firmwares

A more recent tuya-based firmware was released which cannot be hacked over-the-air. At time of
writing, this [github thread](https://github.com/ct-Open-Source/tuya-convert/issues/483) has a lot
of people discussing the topic, but no concrete results.

My suggestion is to buy devices from places you can return - if tuya OTA flashes don't work, return
them and try a different brand.
