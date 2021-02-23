from brownie import Contract, accounts
from brownie import XdaiMediator, XdaiERC20
from dotenv import load_dotenv
from os import getenv
import shelve

def main():
    d = shelve.open('addresses')
    xdaiERC20_addr = d['xdaiERC20']
    xdaiMediator_addr = d['xdaiMediator']
    DECIMALS = 10**18

    #faucet
    xdaiMediator = Contract(xdaiMediator_addr)
    xdaiMediator.faucet({"from": accounts[0]})

    #approve
    xdaiERC20 = Contract(xdaiERC20_addr)
    xdaiERC20.approve(xdaiMediator_addr, 1000*DECIMALS, {"from": accounts[0]})

    #relay
    xdaiMediator.relayTokens(accounts[0], 100*DECIMALS, {"from": accounts[0]})
