export USBDEV

.PHONY: flash_id
flash_id:
	esptool.py flash_id | grep MAC | cut -d : -f 5-7 | sed 's/://g'

.PHONY: clean
clean:
	rm -rf templates/.esphome

.PHONY: compile
compile:
	esphome compile templates/$(DEVICE).yaml

.PHONY: upload run
upload run: compile
ifdef USBDEV
	esphome $@ --device /dev/$(USBDEV) templates/$(DEVICE).yaml
else
	esphome $@ templates/$(DEVICE).yaml
endif

.PHONY: logs
logs:
	esphome logs templates/$(DEVICE).yaml
