import asyncio

tasks: list = []

def create_task(coro, callback = None):
    """ Creates a task that is executed by the asyncio loop.

        A wrapper over asyncio.create_task() that ensures the returned object is
        not garbage collected, even if it isn't awaited. The named parameter
        callback also allows the user to easily pass in a callback to execute
        when the coroutine finishes
    """

    task = asyncio.create_task(coro)
    tasks.append(task)
    task.add_done_callback(lambda task : tasks.remove(task))

    if callback is not None:
        task.add_done_callback(callback)
    
    return task