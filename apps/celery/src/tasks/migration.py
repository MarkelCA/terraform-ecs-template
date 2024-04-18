from celery import shared_task
from time import sleep

@shared_task
def run():
    print("Migrating:")
    for i in range(15,0,-1):
        sleep(1)
        print(f"Migrating: {i}...")
