Flashing off-the-shelf Tuya devices
===================================

## Preamble

Many off-the-shelf devices are powered with ESP8285 or ESP8286 chips, in devices with white-label
firmware provided by a company called Tuya. The project [tuya-convert](https://github.com/ct-Open-Source/tuya-convert)
exists to hack these devices and enable us to load custom firmware.

Firmware options include:
* Tasmota - the original; many devices are known and pin configurations [listed here](https://templates.blakadder.com/)
* Espurna - an alternative which has a nice Web UI and is easily configurable with custom builds
* ESP Home - a versetile firmware which supports a lot of different chips in practice, and has many
  great features for the advanced user


## My Devices

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


## Process

 0. Build custom Espurna base image, [including wifi SSID and password](#espurna-custom-image-builds)
 1. Use [`tuya-convert`](https://github.com/ct-Open-Source/tuya-convert) to do the initial hack
 2. Install custom Espurna base image as part of tuya-convert process
 3. Ensure device appears on wifi network
 4. Update "My Devices" table :)
 5. Setup esphome config and re-flash to esphome


## Tuya Convert

The [tuya-convert](https://github.com/ct-Open-Source/tuya-convert) project exists to do OTA hacks


### Note on Newer Firmwares

A more recent tuya-based firmware was released which cannot be hacked over-the-air. At time of
writing, this [github thread](https://github.com/ct-Open-Source/tuya-convert/issues/483) has a lot
of people discussing the topic, but no concrete results.

My suggestion is to buy devices from places you can return - if tuya OTA flashes don't work, return
them and try a different brand.


## Espurna custom image builds

f


## Flashing with esptool

```
> esptool.py -p /dev/ttyUSB0 write_flash -fs 1MB -fm dout 0x0 /home/pi/espurna-1.15.0-dev-espurna-core-webui-1MB.bin
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

## ESP Home flashes

ESP Home has a very pleasant YAML configuration, which the tool takes and uses to build a firmware.
Since I have multiples of the same device, I have templated the device configuration using Jinja.
A `Makefile` provides a simple interface to do the magic:

Generate the firmware config YAML files:

    export WIFI_PASSWORD=<secretsquirrel>
    make gen-templates

Compile the firmware, and then [upload via Espurna UI](https://esphome.io/guides/migrate_espurna.html)

    DEVICE=c0a4ba make compile

Once a device has been flashed to ESP Home, one can update directly from the CLI:

    DEVICE=c0a4ba make compile upload
