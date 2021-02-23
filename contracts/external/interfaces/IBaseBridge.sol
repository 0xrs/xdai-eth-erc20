// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;

import { IERC20 } from "OpenZeppelin/openzeppelin-contracts@3.3.0/contracts/token/ERC20/ERC20.sol";
import { Decimal } from "../../utils/Decimal.sol";

interface IBaseBridge {
    function erc20Transfer(
        IERC20 _token,
        address _receiver,
        Decimal.decimal calldata _amount
    ) external;
}
