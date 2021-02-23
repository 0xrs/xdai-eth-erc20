// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;

import { BaseBridge, IAMB, IMultiTokenMediator, Decimal, IERC20 } from "../external/BaseBridge.sol";
import { IMainnetMediator } from "../../interfaces/IMainnetMediator.sol";
import { XdaiERC20 } from "./XdaiERC20.sol";
import { TransferInfoStorage } from "../external/TransferInfoStorage.sol";

contract XdaiMediator is BaseBridge, TransferInfoStorage {
    using Decimal for Decimal.decimal;

    uint256 public constant DEFAULT_GAS_LIMIT = 2e6;

    uint256[50] private __gap;

    address public mainnetMediator;
    address public xdaiERC20;
    uint256 private DECIMALS = 10**18;

    event FailedMessageFixed(bytes32 indexed messageId, address recipient, uint256 value);

    //
    // PUBLIC
    //
    function initialize(IAMB _xdaiAmbBridge, address _mainnetMediator) public onlyOwner {
        mainnetMediator = _mainnetMediator;
        __BaseBridge_init(_xdaiAmbBridge);
    }


    function unlockTokens(address _recipient, uint256 _val) public onlyXdaiAmbBridge {
        require(IAMB(ambBridge).messageSender() == mainnetMediator, "sender not mainnet mediator");
        IERC20(xdaiERC20).transfer(_recipient, _val);
    }

    function relayTokens(address _recipient, uint256 _val) external returns (bytes32) {
        IERC20(xdaiERC20).transferFrom(msg.sender, address(this), _val);
        bytes4 methodSelector = IMainnetMediator.mintTokens.selector;
        bytes memory data = abi.encodeWithSelector(methodSelector, _recipient, _val);
        bytes32 msgId = callBridge(mainnetMediator, data, DEFAULT_GAS_LIMIT);

        // Save value and receiver in case the message fails on the other side
        setMessageValue(msgId, _val);
        setMessageRecipient(msgId, _recipient);
        return msgId;

    }

    /**
    * @dev Method to be called when a bridged message execution failed. It will generate a new message requesting to
    * fix/roll back the transferred assets on the other network.
    * @param _messageId id of the message which execution failed.
    */
    function requestFailedMessageFix(bytes32 _messageId) external {
        require(!IAMB(ambBridge).messageCallStatus(_messageId));
        require(IAMB(ambBridge).failedMessageReceiver(_messageId) == address(this));
        require(IAMB(ambBridge).failedMessageSender(_messageId) == mainnetMediator);

        bytes4 methodSelector = IMainnetMediator.fixFailedMessage.selector;
        bytes memory data = abi.encodeWithSelector(methodSelector, _messageId);
        IAMB(ambBridge).requireToPassMessage(mainnetMediator, data, DEFAULT_GAS_LIMIT);
    }

    /**
    * @dev Handles the request to fix transferred assets which bridged message execution failed on the other network.
    * It uses the information stored by passMessage method when the assets were initially transferred
    * @param _messageId id of the message which execution failed on the other network.
    */
    function fixFailedMessage(bytes32 _messageId) external onlyXdaiAmbBridge {

        require(IAMB(ambBridge).messageSender() == mainnetMediator, "sender not mainnet mediator");

        require(!messageFixed(_messageId));

        address recipient = messageRecipient(_messageId);
        uint256 value = messageValue(_messageId);
        setMessageFixed(_messageId);
        fixUnlockTokens(recipient, value);
        emit FailedMessageFixed(_messageId, recipient, value);
    }

    function fixUnlockTokens(address _recipient, uint256 _val) internal {
        IERC20(xdaiERC20).transfer(_recipient, _val);
    }
    //setter
    function setXdaiERC20(address _xdaiERC20) public onlyOwner {
        xdaiERC20 = _xdaiERC20;
    }

    modifier onlyXdaiAmbBridge() {
        require(msg.sender == address(ambBridge));
        _;
    }

    //test func
    function faucet() external {
        XdaiERC20(xdaiERC20).mint(msg.sender, 10000*DECIMALS);
    }
}
