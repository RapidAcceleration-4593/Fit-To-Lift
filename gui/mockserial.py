import asyncio

class MockSerialManager:
    """Mock serial manager for UI testing without hardware."""

    async def query(self, message: str, read_timeout=0.5):
        await asyncio.sleep(0.1)  # simulate delay
        return "42.0"             # fake response value

    async def command(self, message: str):
        print(f"[MockSerial] Command received: {message}")
        await asyncio.sleep(0.05)
