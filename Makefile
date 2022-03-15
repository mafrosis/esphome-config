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
	render ea9c90 192.168.20.208 esp8285 'Kogan Plug 1'    kogan_plug
	render 040cab 192.168.20.50  esp8285 'Kogan Plug 2'    kogan_plug
	render 047c60 192.168.20.54  esp8285 'Kogan Plug 3'    kogan_plug
	render c0a4b4 192.168.20.218 esp8285 'Kogan Plug 4'    kogan_plug
	render 6c7fe7 192.168.20.209 esp8285 'Kogan RGBW 1'    kogan_rgbww
	render 6c8595 192.168.20.174 esp8285 'Kogan RGBW 2'    kogan_rgbww
	render 92d0f9 192.168.20.55  esp8285 'Arlec PC190HA 1' arlec_pc190ha
	render c05775 192.168.20.56  esp8285 'Arlec PC190HA 2' arlec_pc190ha
	render 10945b 192.168.20.53  esp8266 'ESP8622 1'       dht22          --room 'Master Bedroom'
	render 774ba4 192.168.20.52  esp8266 'ESP8622 2'       dht22 temt6000 --room 'Bea Bedroom'

.PHONY: compile
compile: gen-templates
	esphome compile build/device_$(DEVICE).yaml

.PHONY: upload
upload: compile
ifdef USBDEV
	esphome upload --device /dev/$(USBDEV) build/device_$(DEVICE).yaml
else
	esphome upload build/device_$(DEVICE).yaml
endif
