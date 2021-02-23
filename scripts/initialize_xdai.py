from brownie import Contract, accounts
from brownie import XdaiMediator, XdaiERC20
from dotenv import load_dotenv
from os import getenv
import shelve

def main():

    d = shelve.open('addresses')
    mainnetMediator_addr = d['mainnetMediator']
    xdaiMediator_addr = d['xdaiMediator']
    eth_amb_addr = d['eth_amb_addr']
    xdai_amb_addr = d['xdai_amb_addr']

    #deploy xdai erc20
    xdaiERC20 = XdaiERC20.deploy("PEPE (on XDAI)", "PEPE (on XDAI)", xdai_amb_addr, xdaiMediator_addr, mainnetMediator_addr, {"from": accounts[0]})

    #initialize mainnetMediator
    xdaiMediator = Contract(xdaiMediator_addr)
    xdaiMediator.initialize(xdai_amb_addr, mainnetMediator_addr, {"from": accounts[0]})
    #set mainnet erc20
    xdaiMediator.setXdaiERC20(xdaiERC20.address, {"from": accounts[0]})
    d['xdaiERC20'] = xdaiERC20.address
