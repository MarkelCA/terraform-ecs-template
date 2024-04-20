from time import sleep
import os

print(os.environ.get("MY_SECRET_KEY"))

for i in range(10):
    print(f"Migrating... {i}")
    sleep(1)
