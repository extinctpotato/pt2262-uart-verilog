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

    print(repr(s))

    return s

with serial.Serial(sys.argv[1], 9600, timeout=1) as ser:
    #ser.write(bin_list_to_string("101010101010101000000001"))
    ser.write(bin_list_to_string("101010101010101000000011"))
    ser.flush()
    ser.close()
