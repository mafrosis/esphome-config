export WIFI_PASSWORD
export WIFI_FALLBACK

venv:
	python3 -m venv venv
	./venv/bin/pip install -e .

.PHONY: setup
setup: venv
	@echo "Now source venv/bin/activate"

.PHONY: clean
clean:
	rm -f build/device_*

.PHONY: gen-templates
gen-templates: clean
	render ea9c90 192.168.20.208 esp8285 'Kogan Plug 1'    kogan_plug
	render 040cab 192.168.20.207 esp8285 'Kogan Plug 2'    kogan_plug
	render 047c60 192.168.20.214 esp8285 'Kogan Plug 3'    kogan_plug
	render c0a4b4 192.168.20.218 esp8285 'Kogan Plug 4'    kogan_plug
	render 6c7fe7 192.168.20.209 esp8285 'Kogan RGBW 1'    kogan_rgbww
	render 6c8595 192.168.20.174 esp8285 'Kogan RGBW 2'    kogan_rgbww
	render 92d0f9 192.168.20.216 esp8285 'Arlec PC190HA 1' arlec_pc190ha
	render c05775 192.168.20.206 esp8285 'Arlec PC190HA 2' arlec_pc190ha
	render 10945b 192.168.20.121 esp8266 'ESP8622 1'       dht22         --room 'Master bedroom'
	render 774ba4 192.168.20.122 esp8266 'ESP8622 2'       dht22         --room 'Bea bedroom'

.PHONY: compile
compile: gen-templates
	esphome compile build/device_$(DEVICE).yaml

.PHONY: upload
upload: compile
	esphome upload build/device_$(DEVICE).yaml
