// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;

import { ERC20 } from "OpenZeppelin/openzeppelin-contracts@3.3.0/contracts/token/ERC20/ERC20.sol";
import { Ownable } from "OpenZeppelin/openzeppelin-contracts@3.3.0/contracts/access/Ownable.sol";

contract XdaiERC20 is ERC20, Ownable {

    address public xdaiAmbBridge;
    address public xdaiMediator;
    address public mainnetMediator;


    constructor(string memory _name, string memory _symbol, address _xdaiAmbBridge, address _xdaiMediator, address _mainnetMediator) ERC20(_name, _symbol) public {
        xdaiAmbBridge = _xdaiAmbBridge;
        xdaiMediator = _xdaiMediator;
        mainnetMediator = _mainnetMediator;
    }

    function mint(address _account, uint256 _amount) public onlyXdaiMediator {
        _mint(_account, _amount);
    }

    function burn(address _account, uint256 _amount) public onlyXdaiMediator {
        _burn(_account, _amount);
    }

    //setters
    function setXdaiAmbBridge(address _xdaiAmbBridge) public onlyOwner {
        xdaiAmbBridge = _xdaiAmbBridge;
    }

    function setXdaiMediator(address _xdaiMediator) public onlyOwner {
        xdaiMediator = _xdaiMediator;
    }

    function setMainnetMediator(address _mainnetMediator) public onlyOwner {
        mainnetMediator = _mainnetMediator;
    }

    modifier onlyXdaiMediator() {
        require(msg.sender == xdaiMediator, "!xdaiMediator");
        _;
    }
}
