from serial import Serial
from serial.tools import list_ports
import asyncio
from asyncio import Lock
import time
import random

class MockSerial:
    def __init__(self):
        self.in_waiting = True

    def reset_input_buffer(self):
        pass

    def write(self, message: bytes):
        print(f"Mock Write: {message.decode().strip()}")

    def read_until(self, terminator: bytes = b"\n") -> bytes:
        value = str(random.randint(10, 100)) + "\n"
        time.sleep(0.05)
        return value.encode()
    
    def close(self):
        print("Mock serial connection closed!")

class SerialManager():
    def __init__(self, ser):
        self.ser: Serial = ser
        self.ser_mutex: Lock = Lock()

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
            async with asyncio.timeout(read_timeout):
                response = await asyncio.to_thread(self.__query, message)
        finally:
            self.ser_mutex.release()
        return response

    async def command(self, message: str):
        async with self.ser_mutex:
            await asyncio.to_thread(self.ser.write, message.encode() + b"\n")

    def __query(self, message: str) -> str:
        self.ser.reset_input_buffer() # This will cause problems if we ever add non-query messaging to the serial connection
        self.ser.write(message.encode() + b"\n")
        return self.ser.read_until(b"\n").decode().strip()

def create_serial_connection(mock = False):
    if mock:
        return MockSerial()

    ports = list_ports.comports()
    arduino_name = ""
    for port in ports:
        if port.vid in (9025, 6790):
            arduino_name = port.name
    if not arduino_name:
        raise Exception("Arduino not connected!")
    if arduino_name.startswith("tty"):
        arduino_name = "/dev/" + arduino_name
    return Serial(arduino_name, 115200)
