from brownie import Contract, accounts
from brownie import XdaiMediator, XdaiERC20
from dotenv import load_dotenv
from os import getenv
import shelve

def main():
    d = shelve.open('addresses')
    mainnetERC20_addr = d['mainnetERC20']
    mainnetMediator_addr = d['mainnetMediator']
    DECIMALS = 10**18

    #approve
    mainnetERC20 = Contract(mainnetERC20_addr)
    mainnetERC20.approve(mainnetMediator_addr, 10000*DECIMALS, {"from": accounts[0]})

    #relay
    mainnetMediator = Contract(mainnetMediator_addr)
    mainnetMediator.relayTokens(accounts[0], 50*DECIMALS, {"from": accounts[0]})
