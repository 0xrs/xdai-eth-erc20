from brownie import Contract, accounts
from brownie import MainnetMediator, MainnetERC20
from dotenv import load_dotenv
from os import getenv
import shelve

def main():

    d = shelve.open('addresses')
    mainnetMediator_addr = d['mainnetMediator']
    xdaiMediator_addr = d['xdaiMediator']
    eth_amb_addr = d['eth_amb_addr']
    xdai_amb_addr = d['xdai_amb_addr']

    #deploy mainnet erc20
    mainnetERC20 = MainnetERC20.deploy("PEPE", "PEPE", eth_amb_addr, xdaiMediator_addr, mainnetMediator_addr, {"from": accounts[0]})


    #initialize mainnetMediator
    mainnetMediator = Contract(mainnetMediator_addr)
    mainnetMediator.initialize(eth_amb_addr, xdaiMediator_addr, {"from": accounts[0]})
    #set mainnet erc20
    mainnetMediator.setMainnetERC20(mainnetERC20.address, {"from": accounts[0]})
    d['mainnetERC20'] = mainnetERC20.address
