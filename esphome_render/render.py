import os

import click
from jinja2 import Environment, FileSystemLoader


@click.command()
@click.argument('device_id')
@click.argument('device_ip')
@click.argument('device_type')
@click.argument('name')
@click.argument('templates', nargs=-1)
@click.option('--room', default='nil', help='Name of the room for this sensor')
def main(device_id: str, device_ip: str, device_type: str, name: str, templates, room: str=None):
    wifi_password = os.environ['WIFI_PASSWORD'].strip()
    fallback_password = os.environ['WIFI_FALLBACK'].strip()

    if device_type == 'esp32':
        platform = 'ESP32'
        board = 'nodemcu-32s'
    elif device_type == 'esp8266':
        platform = 'ESP8266'
        board = 'nodemcuv2'
    else:
        platform = 'ESP8266'
        board = 'esp8285'

    if not wifi_password:
        raise Exception('WIFI_PASSWORD env not set')
    if not fallback_password:
        raise Exception('FALLBACK_PASSWORD env not set')

    env = Environment(loader=FileSystemLoader('templates'))

    # Read the templated esphome header YAML, and patch in variables
    with open('templates/_esphome.tmpl', encoding='utf-8') as f:
        t = env.from_string(f.read())
        esphome = t.render(
            device_id=device_id,
            device_name=name,
            static_ip=device_ip,
            wifi_password=wifi_password,
            fallback_password=fallback_password,
            platform=platform,
            board=board,
            room=room,
        )

    # Combine the esphome header with each template
    for template in templates:
        with open(f'templates/{template}.tmpl', encoding='utf-8') as f:
            esphome = f'{esphome}\n\n# ----------------------------------------\n\n{f.read()}'

    if not os.path.exists('build'):
        os.makedirs('build')

    # Write out the build config
    with open(f'build/device_{device_id}.yaml', 'w', encoding='utf-8') as f:
        f.write(esphome)
