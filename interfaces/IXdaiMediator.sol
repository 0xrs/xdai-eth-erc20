// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;

interface IXdaiMediator {
    function unlockTokens(address _recipient, uint256 _val) external;
    function relayTokens(address _recipient, uint256 _val) external returns (bytes32 messageId);
    function requestFailedMessageFix(bytes32 _messageId) external;
    function fixFailedMessage(bytes32 _messageId) external;
}
