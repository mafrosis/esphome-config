export USBDEV

.PHONY: flash_id
flash_id:
	hatch run esptool.py flash_id | grep MAC | cut -d : -f 5-7 | sed 's/://g'

.PHONY: clean
clean:
	hatch run pio system prune -f
	rm -rf templates/.esphome
	hatch env prune

.PHONY: compile
compile:
	hatch run esphome compile templates/$(DEVICE).yaml

.PHONY: upload run
upload run: compile
ifdef USBDEV
	hatch run esphome $@ --device /dev/$(USBDEV) templates/$(DEVICE).yaml
else
	hatch run esphome $@ templates/$(DEVICE).yaml
endif

.PHONY: logs
logs:
	hatch run esphome logs templates/$(DEVICE).yaml

.PHONY: list-serial
list-serial:
	hatch run python -m serial.tools.list_ports -v

.PHONY: miniterm
miniterm:
	hatch run python -m serial.tools.miniterm
