import datetime

def show_current_time():
    current_time = datetime.datetime.now().strftime("%I:%M %p")
    print(f"The current time is {current_time}")