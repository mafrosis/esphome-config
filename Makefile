export WIFI_PASSWORD
export WIFI_FALLBACK
export USBDEV

venv:
	python3 -m venv venv
	./venv/bin/pip install -e .

.PHONY: setup
setup: venv
	@echo "Now source venv/bin/activate"

.PHONY: clean
clean:
	rm -rf build

.PHONY: gen-templates
gen-templates:
	render 92d0f9 192.168.20.55  esp8285 'Arlec PC190HA 1' arlec_pc190ha
	render c05775 192.168.20.56  esp8285 'Arlec PC190HA 2' arlec_pc190ha
	#
	# Athom
	render 3feb4d 192.168.20.203 esp8285 'Athom Plug 1'    athom_plug_v2
	render 3fe9af 192.168.20.204 esp8285 'Athom Plug 2'    athom_plug_v2
	render 10295e 192.168.20.201 esp8285 'Athom RBGW 1'    athom_rgbww
	render 104632 192.168.20.202 esp8285 'Athom RBGW 2'    athom_rgbww
	#
	# Indoor temp sensors
	render 10945b 192.168.20.53  esp8266 'ESP8622 1'       dht22          --room 'Master Bedroom'
	render 774ba4 192.168.20.52  esp8266 'ESP8622 2'       dht22 temt6000 --room 'Bea Bedroom'
	render 7756f8 192.168.20.51  esp8266 'ESP8622 3'       dht22          --room 'Living Room PS5'

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
