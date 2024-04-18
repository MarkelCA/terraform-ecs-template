from celery import shared_task
from time import sleep

@shared_task(ignore_result=False)
def run(a: int, b: int) -> int:
    print("Countdown:")
    for i in range(15,0,-1):
        sleep(1)
        print(f"Add: {i}...")
    return a + b
