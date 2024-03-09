import pytest

from brownie import Record, accounts, Contract, reverts
from brownie.network import gas_price
from brownie.network.account import Account
from brownie.network.gas.strategies import LinearScalingStrategy


def test():
    gas_price(LinearScalingStrategy("60 gwei", "70 gwei", 1.1))
    contract: Contract = Record.deploy()

    tx = accounts[0].transfer(Account(contract.address), buy)
