from celery import shared_task

@shared_task
def run():
    raise Exception('Task failed')
