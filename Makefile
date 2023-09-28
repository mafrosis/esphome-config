export WIFI_PASSWORD
export WIFI_FALLBACK
export USBDEV

.PHONY: flash_id
flash_id:
	esptool.py flash_id | grep MAC | cut -d : -f 5-7 | sed 's/://g'

.PHONY: clean
clean:
	rm -rf build

.PHONY: gen-templates
gen-templates:
	render 92d0f9 192.168.20.55  esp8285 'Arlec PC190HA 1' arlec_pc190ha
	render c05775 192.168.20.56  esp8285 'Arlec PC190HA 2' arlec_pc190ha
	#
	# Indoor temp sensors
	render 10945b 192.168.20.53  nodemcuv2 'ESP8622 1'     dht22 --room 'Master Bedroom'
	render 774ba4 192.168.20.52  nodemcuv2 'ESP8622 2'     dht22 --room 'Bea Bedroom'
	render 7756f8 192.168.20.51  nodemcuv2 'ESP8622 3'     dht22 --room 'Living Room PS5'
	render 0fe8ed 192.168.20.63  nodemcuv2 'ESP8622 5'     dht22 --room 'Server Closet'
	render 776b6e 192.168.20.64  nodemcuv2 'ESP8622 6'     dht22 --room 'Bread Chamber'
	#
	# TV/audio controller and temp/light monitor
	render abd1b5 192.168.20.58  nodemcuv2 'ESP8622 4'     ir/esp8266 ir/audio ir/dm9 htu21d temt6000 --room 'Living Room'
	#
	# Outdoor battery devices
	render 707a3c 192.168.20.57  lolin_d32 'Lolin D32'     sr04 battery --sleep 2h --room 'Outside'
	render 61ae30 192.168.20.67  nodemcuv2 'D1 Mini Pro'   ds18b20 battery --sleep 15min --room 'Outside' --address '0x2b196a841e64ff28'
	#
	# Inkbird bluetooth BBQ monitor
	render 5c3618 192.168.20.65  lolin_d32_pro 'LOLIN Pro' ibt4xc
	#
	# Lolin D1 Mini (attempts at mitsubishiheatpump)
	render de3341 192.168.20.66  nodemcuv2 'D1 Mini v3'
	render 61bc6f 192.168.20.68  nodemcuv2 'D1 Mini v4'
	render f4accc 192.168.20.69  lolin_s2_mini 'S2 Mini'   mitsubishiheatpump ir/esp32 ir/audio ir/dm9 temt6000 --room 'Living Room'
	render e37b74 192.168.20.70  nodemcuv2 'D1 Mini v1'
	#
	# Lolin S3
	render d6101c 192.168.20.71  lolin_s3_mini 'Lolin S3 Mini'
	render d6101d 192.168.20.72  lolin_s3 'Lolin S3'


.PHONY: compile
compile: gen-templates
	esphome compile build/device_$(DEVICE).yaml

.PHONY: upload run
upload run: compile
ifdef USBDEV
	esphome $@ --device /dev/$(USBDEV) build/device_$(DEVICE).yaml
else
	esphome $@ build/device_$(DEVICE).yaml
endif

.PHONY: logs
logs:
	esphome logs build/device_$(DEVICE).yaml
