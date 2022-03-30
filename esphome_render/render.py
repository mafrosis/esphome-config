import os

import click
from jinja2 import Environment, FileSystemLoader
import yaml

# pylint: disable=consider-using-f-string


@click.command()
@click.argument('device_id')
@click.argument('device_ip')
@click.argument('device_type')
@click.argument('name')
@click.argument('templates', nargs=-1)
@click.option('--room', default='nil', help='Name of the room for this sensor')
@click.option('--address', default='nil', help='Sensor address')
def main(device_id: str, device_ip: str, device_type: str, name: str, templates, room: str=None,
         address: str='0'):
    wifi_password = os.environ['WIFI_PASSWORD'].strip()
    fallback_password = os.environ['WIFI_FALLBACK'].strip()

    if device_type == 'lolin':
        platform = 'ESP32'
        board = 'lolin_d32'
    elif device_type == 'lolin_pro':
        platform = 'ESP32'
        board = 'lolin_d32_pro'
    elif device_type == 'esp32':
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
        )
        components = [esphome]

    # Read in all device templates, substituting any variables
    for template in templates:
        with open(f'templates/{template}.tmpl', encoding='utf-8') as f:
            t = env.from_string(f.read())
            components.append(
                t.render(
                    room=room,
                    address=address,
                    fallback_password=fallback_password,
                )
            )

    merged_components = {}

    def _merge(merged, node):
        if isinstance(node, list):
            merged += node
        elif isinstance(node, dict):
            for k,v in node.items():
                if k not in merged:
                    merged[k] = {} if v is None else v
                else:
                    _merge(merged[k], v)
        else:
            raise Exception('Unknown node type: expected list or dict')

    # Merge components under single top-level key:
    # - multiple sensors merge
    # - multiple mqtt entries merge
    # - multiple mqtt.on_message entries merge
    for component in components:
        for doc in yaml.load_all(component, Loader=yaml.Loader):
            _merge(merged_components, doc)

    # Dump the merged template components back to YAML
    esphome = yaml.dump(merged_components, Dumper=yaml.Dumper)

    if not os.path.exists('build'):
        os.makedirs('build')

    # Write out the build config
    with open(f'build/device_{device_id}.yaml', 'w', encoding='utf-8') as f:
        f.write(esphome)
