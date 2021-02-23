// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;

import { ERC20 } from "OpenZeppelin/openzeppelin-contracts@3.3.0/contracts/token/ERC20/ERC20.sol";
import { Ownable } from "OpenZeppelin/openzeppelin-contracts@3.3.0/contracts/access/Ownable.sol";

contract MainnetERC20 is ERC20, Ownable {

    address public mainnetAmbBridge;
    address public mainnetMediator;
    address public xdaiMediator;

    constructor(string memory _name, string memory _symbol, address _mainnetAmbBridge, address _xdaiMediator, address _mainnetMediator) ERC20(_name, _symbol) public {
        mainnetAmbBridge = _mainnetAmbBridge;
        xdaiMediator = _xdaiMediator;
        mainnetMediator = _mainnetMediator;
    }

    function mint(address _account, uint256 _amount) public onlyMainnnetMediator {
        //require(IAMB(mainnetAmbBridge).messageSender() == xdaiMediator, "sender not xdai mediator");
        _mint(_account, _amount);
    }

    function burn(address _account, uint256 _amount) public onlyMainnnetMediator {
        _burn(_account, _amount);
    }

    //setters TODO
    function setMainnetAmbBridge(address _mainnetAmbBridge) public onlyOwner {
        mainnetAmbBridge = _mainnetAmbBridge;
    }

    function setXdaiMediator(address _xdaiMediator) public onlyOwner {
        xdaiMediator = _xdaiMediator;
    }

    function setMainnetMediator(address _mainnetMediator) public onlyOwner {
        mainnetMediator = _mainnetMediator;
    }

    modifier onlyMainnnetMediator() {
        require(msg.sender == mainnetMediator, "!mainnetMediator");
        _;
    }
}
