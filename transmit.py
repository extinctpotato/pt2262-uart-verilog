import serial
import sys
import time

def bin_list_to_string(message_lst):
    def __chunks(lst, n):
        """Yield successive n-sized chunks from lst."""
        for i in range(0, len(lst), n):
            yield lst[i:i + n]

    s = bytearray('', encoding='ascii')

    for chunk in __chunks(message_lst, 8):
        s.append(int("".join(map(str, chunk)), 2))

    return s

def states_to_bin(states_lst):
    return "".join(
            ["01" if x == "1" else "00" if x == "0" else "10" if x == "f" else None for x in states_lst]
            )

def states_to_message(states_lst):
    return bin_list_to_string(states_to_bin(states_lst))

with serial.Serial(sys.argv[1], 9600, timeout=1) as ser:
    ser.write(states_to_message(sys.argv[2]))
    ser.close()
