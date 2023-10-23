// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;
import {Ownable} from 'openzeppelin-contracts/contracts/access/Ownable.sol';
import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import {SafeERC20} from 'openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol';

contract Schnaps is Ownable {
    using SafeERC20 for IERC20;

    // Initialize `owner`.
    constructor(address initialOwner) Ownable(initialOwner) {}

    // TODO: decide what to put in barcode
    event PaymentReceived(address sender, address token, uint256 amount, bytes barcode);

    /// @notice Proceed to a payment using ETH.
    ///
    /// @param barcode The barcode of the payment.
    function payWithEth(bytes calldata barcode) public payable {
        emit PaymentReceived(msg.sender, address(0), msg.value, barcode);
    }

    /// @notice Proceed to a payment using ERC20 token.
    ///
    /// @param token The address of the ERC20 token.
    /// @param amount The amount of the ERC20 token.
    /// @param barcode The barcode of the payment.
    function payWithToken(IERC20 token, uint256 amount, bytes calldata barcode) public {
        token.safeTransferFrom(msg.sender, address(this), amount);
        emit PaymentReceived(msg.sender, address(token), amount, barcode);
    }

    /// @notice Withdraw ETH from the contract.
    ///
    /// @param to The address to send ETH to.
    /// @param amount The amount of ETH to send.
    function withdrawEth(address payable to, uint256 amount) public onlyOwner {
        to.transfer(amount);
        // TODO: need an event?
    }

    /// @notice Withdraw ERC20 token from the contract.
    ///
    /// @param token The address of the ERC20 token.
    /// @param to The address to send ERC20 token to.
    /// @param amount The amount of ERC20 token to send.
    function withdrawToken(IERC20 token, address to, uint256 amount) public onlyOwner {
        token.safeTransfer(to, amount);
    }
}
