from dotenv import load_dotenv
from os import getenv
import shelve

def main():
    d = shelve.open('addresses')
    for k, v in d.items():
        print(k, "=>", v)
