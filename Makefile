export WIFI_PASSWORD


.PHONY: gen-templates
gen-templates:
	ID=ea9c90 NAME="Kogan Plug 1" IP=192.168.20.208 TMPL=kogan_plug ./render.py
	ID=040cab NAME="Kogan Plug 2" IP=192.168.20.207 TMPL=kogan_plug ./render.py
	ID=047c60 NAME="Kogan Plug 3" IP=192.168.20.214 TMPL=kogan_plug ./render.py
	ID=c0a4b4 NAME="Kogan Plug 4" IP=192.168.20.218 TMPL=kogan_plug ./render.py
	ID=6c7fe7 NAME="Kogan RGBW 1" IP=192.168.20.209 TMPL=kogan_rgbww ./render.py
	ID=6c8595 NAME="Kogan RGBW 2" IP=192.168.20.174 TMPL=kogan_rgbww ./render.py
	#ID=c05775 NAME="Arlec PC189HA 1" IP=192.168.20.206 ./render.py
	ID=92d0f9 NAME="Arlec PC190HA 1" IP=192.168.20.216 TMPL=arlec_pc190ha ./render.py
	#ID=f58f91 NAME="Arlec PB89HA" IP=192.168.20.164 ./render.py
	ID=10945b NAME="ESP8622 1" IP=192.168.20.121 ROOM="Master bedroom" TMPL=esp8266_dht22 ./render.py
	ID=774ba4 NAME="ESP8622 2" IP=192.168.20.122 ROOM="Bea bedroom" TMPL=esp8266_dht22 ./render.py

.PHONY: compile
compile: gen-templates
	docker-compose run --rm esphome compile device_$(DEVICE).yaml

.PHONY: upload
upload:
	docker-compose run --rm esphome upload device_$(DEVICE).yaml
