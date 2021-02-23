from brownie import Contract, accounts
from brownie import XdaiERC20, XdaiMediator
from dotenv import load_dotenv
from os import getenv
import shelve

def main():
    load_dotenv('.env')
    accounts.add(getenv('acct0_pk'))
    eth_amb_addr = "0xD4075FB57fCf038bFc702c915Ef9592534bED5c1"
    xdai_amb_addr = "0xc38D4991c951fE8BCE1a12bEef2046eF36b0FA4A"
    d = shelve.open('addresses')
    d['eth_amb_addr'] = eth_amb_addr
    d['xdai_amb_addr'] = xdai_amb_addr

    #deploy XdaiMediator
    xdaiMediator = XdaiMediator.deploy({"from": accounts[0]})
    d['xdaiMediator'] = xdaiMediator.address
