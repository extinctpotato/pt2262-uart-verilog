import serial
import sys
import time
import argparse
import pathlib
import paho.mqtt.subscribe as paho_subscribe
from typing import Callable, Any

def bin_list_to_string(message_lst: str) -> bytearray:
    def __chunks(lst, n):
        """Yield successive n-sized chunks from lst."""
        for i in range(0, len(lst), n):
            yield lst[i:i + n]

    s = bytearray('', encoding='ascii')

    for chunk in __chunks(message_lst, 8):
        s.append(int("".join(map(str, chunk)), 2))

    return s

def states_to_bin(states_lst: str) -> str:
    return "".join(
            ["01" if x == "1" else "00" if x == "0" else "10" if x == "f" else None for x in states_lst]
            )

def tx_states(serial_port: str, states: str):
    msg = bin_list_to_string(states_to_bin(states))
    with serial.Serial(serial_port, 9600) as ser:
        ser.write(msg)

def on_mqtt_message(serial_port: str) -> Callable[[Any], None]:
    def __callback(client, _, msg):
        tx_states(serial_port, msg.payload.decode())

    return __callback

if __name__ == "__main__":
    parser = argparse.ArgumentParser(prog='pt2262_verilog_tx')
    parser.add_argument('-d', '--device',
                        help='path to the TTY character device',
                        default='/dev/ttyUSB0'
                        )
    parser.add_argument('-b', '--broker', type=str, help='mqtt broker hostname', default='localhost')
    parser.add_argument('-t', '--topic', type=str, help='mqtt topic to subscribe to', default='pt2262_verilog')
    subparsers = parser.add_subparsers(required=True)

    mqtt = subparsers.add_parser('mqtt')
    mqtt.set_defaults(func=lambda a: paho_subscribe.callback(on_mqtt_message(a.device) , a.topic, hostname=a.broker))

    tx = subparsers.add_parser('tx')
    tx.add_argument('msg', type=str, help='(e.g. ffffffff0001)')
    tx.set_defaults(func=lambda a: tx_states(a.device, a.msg))

    args = parser.parse_args()
    args.func(args)
