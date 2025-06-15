from serial import Serial
import platform

import asyncio
from asyncio import Lock
import time

class SerialManager():
    def __init__(self, ser):
        self.ser: Serial = ser
        self.ser_mutex: Lock = Lock()

    def __read_line(self) -> str:
        while not self.ser.in_waiting:
            time.sleep(0.005)

        response = self.ser.read_until(b"\n").decode()
        return response.strip()

    def __query(self, message: str) -> str:
        self.ser.reset_input_buffer() # This will cause problems if we ever add non-query messaging to the serial connection
        self.ser.write(message.encode() + b"\n")
        return self.__read_line()

    async def query(self, message: str, read_timeout = 0.5) -> str:
        """
            Query over serial.

            Sends the message, then returns the next response. Mutex protected,
            so coroutine may take longer than expected if many coroutines are
            querying. read_timeout is only a timeout on the read/write portion
            of the query routine, so it is possible for this coroutine to take
            longer than the read_timeout if it must wait to acquire the mutex.

            Raises a TimeoutError if read_timeout is exceeded.
        """
        await self.ser_mutex.acquire()
        try:
            real_timeout = read_timeout
            if not read_timeout > 0:
                real_timeout = None
            async with asyncio.timeout(real_timeout):
                response = await asyncio.to_thread(self.__query, message)
        finally:
            self.ser_mutex.release()
        return response

    async def command(self, message: str):
        async with self.ser_mutex:
            await asyncio.to_thread(self.ser.write, message.encode() + b"\n")

def default_port_name():
    if platform.system() == "Windows":
        return "COM1"
    elif platform.system() == "Linux":
        return "/dev/tty/USB0"
    elif platform.system() == "Darwin": # Mac
        return "no/effing/clue"

_default_serial = SerialManager(Serial(port=default_port_name(), baudrate=115200))

def get_default_manager() -> SerialManager:
    return _default_serial 