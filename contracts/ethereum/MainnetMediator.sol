// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;

import { BaseBridge, IAMB, IMultiTokenMediator, Decimal, IERC20 } from "../external/BaseBridge.sol";
import { IXdaiMediator } from "../../interfaces/IXdaiMediator.sol";
import { MainnetERC20 } from "./MainnetERC20.sol";
import { TransferInfoStorage } from "../external/TransferInfoStorage.sol";

contract MainnetMediator is BaseBridge, TransferInfoStorage {
    using Decimal for Decimal.decimal;

    uint256 public constant DEFAULT_GAS_LIMIT = 2e6;

    //**********************************************************//
    //   The order of below state variables can not be changed  //
    //**********************************************************//


    //**********************************************************//
    //  The order of above state variables can not be changed   //
    //**********************************************************//

    //◥◤◥◤◥◤◥◤◥◤◥◤◥◤◥◤ add state variables below ◥◤◥◤◥◤◥◤◥◤◥◤◥◤◥◤//

    //◢◣◢◣◢◣◢◣◢◣◢◣◢◣◢◣ add state variables above ◢◣◢◣◢◣◢◣◢◣◢◣◢◣◢◣//
    uint256[50] private __gap;
    address public xdaiMediator;
    address public mainnetERC20;

    event FailedMessageFixed(bytes32 indexed messageId, address recipient, uint256 value);

    //
    // PUBLIC
    //
    function initialize(IAMB _mainnetAmbBridge, address _xdaiMediator) public onlyOwner {
        xdaiMediator = _xdaiMediator;
        __BaseBridge_init(_mainnetAmbBridge);
    }

    function relayTokens(address _recipient, uint256 _val) external returns (bytes32){
        IERC20(mainnetERC20).transferFrom(msg.sender, address(this), _val);
        MainnetERC20(mainnetERC20).burn(address(this), _val);
        bytes4 methodSelector = IXdaiMediator.unlockTokens.selector;
        bytes memory data = abi.encodeWithSelector(methodSelector, _recipient, _val);
        bytes32 msgId = callBridge(xdaiMediator, data, DEFAULT_GAS_LIMIT);

        // Save value and receiver in case the message fails on the other side
        setMessageValue(msgId, _val);
        setMessageRecipient(msgId, _recipient);
        return msgId;
    }

    function mintTokens(address _recipient, uint256 _val) external onlyMainnetAmbBridge {
        require(IAMB(ambBridge).messageSender() == xdaiMediator, "sender not xdai mediator");
        MainnetERC20(mainnetERC20).mint(_recipient, _val);
    }

    /**
    * @dev Method to be called when a bridged message execution failed. It will generate a new message requesting to
    * fix/roll back the transferred assets on the other network.
    * @param _messageId id of the message which execution failed.
    */
    function requestFailedMessageFix(bytes32 _messageId) external {
        require(!IAMB(ambBridge).messageCallStatus(_messageId));
        require(IAMB(ambBridge).failedMessageReceiver(_messageId) == address(this));
        require(IAMB(ambBridge).failedMessageSender(_messageId) == xdaiMediator);

        bytes4 methodSelector = IXdaiMediator.fixFailedMessage.selector;
        bytes memory data = abi.encodeWithSelector(methodSelector, _messageId);
        IAMB(ambBridge).requireToPassMessage(xdaiMediator, data, DEFAULT_GAS_LIMIT);
    }

    /**
    * @dev Handles the request to fix transferred assets which bridged message execution failed on the other network.
    * It uses the information stored by passMessage method when the assets were initially transferred
    * @param _messageId id of the message which execution failed on the other network.
    */

    function fixFailedMessage(bytes32 _messageId) external onlyMainnetAmbBridge {
        require(IAMB(ambBridge).messageSender() == xdaiMediator, "sender not mainnet mediator");
        require(!messageFixed(_messageId));
        address recipient = messageRecipient(_messageId);
        uint256 value = messageValue(_messageId);
        setMessageFixed(_messageId);
        fixRevertBurnTokens(recipient, value);
        emit FailedMessageFixed(_messageId, recipient, value);
    }

    function fixRevertBurnTokens(address _recipient, uint256 _val) internal {
        MainnetERC20(mainnetERC20).mint(_recipient, _val);
    }

    //
    // INTERNALS
    //

    //setter
    function setMainnetERC20(address _mainnetERC20) public onlyOwner {
        mainnetERC20 = _mainnetERC20;
    }

    modifier onlyMainnetAmbBridge() {
        require(msg.sender == address(ambBridge));
        _;
    }
}
