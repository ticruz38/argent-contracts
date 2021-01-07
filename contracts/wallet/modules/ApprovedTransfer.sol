// Copyright (C) 2018  Argent Labs Ltd. <https://argent.xyz>

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;

import "../base/Utils.sol";
import "../base/BaseTransfer.sol";
import "./IApprovedTransfer.sol";

/**
 * @title ApprovedTransfer
 * @notice Feature to transfer tokens (ETH or ERC20) or call third-party contracts with the approval of guardians.
 * @author Julien Niset - <julien@argent.xyz>
 */
contract ApprovedTransfer is IApprovedTransfer, BaseTransfer {
    function transferToken(
        address _token,
        address _to,
        uint256 _amount,
        bytes calldata _data
    )
        external override
        onlyWhenUnlocked()
    {
        doTransfer(_token, _to, _amount, _data);
        resetDailySpent();
    }

    function callContract(
        address _contract,
        uint256 _value,
        bytes calldata _data
    )
        external override
        onlyWhenUnlocked()
        onlyAuthorisedContractCall(_contract)
    {
        doCallContract(_contract, _value, _data);
        resetDailySpent();
    }

    function approveTokenAndCallContract(
        address _token,
        address _spender,
        uint256 _amount,
        address _contract,
        bytes calldata _data
    )
        external override
        onlyWhenUnlocked()
        onlyAuthorisedContractCall(_contract)
    {
        doApproveTokenAndCallContract(_token, _spender, _amount, _contract, _data);
        resetDailySpent();
    }

    function changeLimit(uint256 _newLimit) external override
    onlyWhenUnlocked()
    {
        uint128 targetLimit = LimitUtils.safe128(_newLimit);
        current = targetLimit;
        pending = targetLimit;
        changeAfter = LimitUtils.safe64(block.timestamp);

        resetDailySpent();
        emit LimitChanged(address(this), _newLimit, changeAfter);
    }

    function approveWethAndCallContract(
        address _spender,
        uint256 _amount,
        address _contract,
        bytes calldata _data
    )
        external override
        onlyWhenUnlocked(_wallet)
        onlyAuthorisedContractCall(_wallet, _contract)
    {
        doApproveWethAndCallContract(_wallet, _spender, _amount, _contract, _data);
        resetDailySpent();
    }

    /**
    * @notice Helper method to Reset the daily consumption.
    * @param _versionManager The Version Manager.
    * @param _wallet The target wallet.
    */
    function resetDailySpent() private 
    onlyWhenUnlocked()
    {
        alreadySpent = uint128(0);
        periodEnd = uint64(0);
    }
}