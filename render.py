#! /usr/bin/env python3

import os

from jinja2 import Environment, FileSystemLoader


def main():
    device_id = os.environ['ID']
    device_name = os.environ['NAME']
    static_ip = os.environ['IP']
    template = os.environ['TMPL']
    wifi_password = os.environ['WIFI_PASSWORD']

    if not wifi_password:
        raise Exception('WIFI_PASSWORD env not set')

    env = Environment(loader=FileSystemLoader('templates'))

    with open(f'templates/{template}.tmpl', encoding='utf-8') as f:
        t = env.from_string(f.read())
        output = t.render(
            device_id=device_id,
            device_name=device_name,
            static_ip=static_ip,
            wifi_password=wifi_password,
        )

    with open(f'device_{device_id}.yaml', 'w') as f:
        f.write(output)


if __name__ == '__main__':
    main()
