// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import {Test, console2} from "forge-std/Test.sol";
import {Schnaps} from "../src/Schnaps.sol";
import { TestToken } from "./mock.sol";
import {IERC20} from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';

contract SchnapsTest is Test {
    Schnaps public schnaps;
    address owner = address(0xbeef);
    uint256 amount = 100;
    uint256 supply = 1000;
    address payable receiver = payable(address(1337));
    bytes barcode = "0xdeadbeef";
    IERC20 token;

    event PaymentReceived(address sender, address token, uint256 amount, bytes barcode);
    event Withdrawal(address receiver, address token, uint256 amount);

    function setUp() public {
        schnaps = new Schnaps(owner);
        token = new TestToken(supply);
        token.transfer(address(this), amount);
        token.approve(address(schnaps), amount);
    }

    function test_payWithEth() public {
        vm.expectEmit(true, true, true, true);
        emit PaymentReceived(address(this), address(0), amount, barcode);
        schnaps.payWithEth{value: amount}(barcode);
    }

    function test_payWithToken() public {
        vm.expectEmit(true, true, true, true);
        emit PaymentReceived(address(this), address(token), amount, barcode);
        schnaps.payWithToken(token, amount, barcode);
    }

    function test_withdrawEth() public {
        schnaps.payWithEth{value: amount}(barcode);

        vm.prank(owner);
        vm.expectEmit(true, true, true, true);
        emit Withdrawal(receiver, address(0), amount);
        schnaps.withdrawEth(receiver, amount);
    }

    function test_withdrawEthUnauthorized() public {
        schnaps.payWithEth{value: amount}(barcode);

        vm.expectRevert();
        schnaps.withdrawEth(receiver, amount);
    }

    function test_withdrawEthTooMuch() public {
        schnaps.payWithEth{value: amount}(barcode);

        vm.prank(owner);
        vm.expectRevert();
        schnaps.withdrawEth(receiver, amount + 1);
    }

    function test_withdrawToken() public {
        schnaps.payWithToken(token, amount, barcode);

        vm.prank(owner);
        vm.expectEmit(true, true, true, true);
        emit Withdrawal(receiver, address(token), amount);
        schnaps.withdrawToken(token, receiver, amount);
    }

    function test_withdrawTokenUnauthorized() public {
        schnaps.payWithToken(token, amount, barcode);

        vm.expectRevert();
        schnaps.withdrawToken(token, receiver, amount);
    }

    function test_withdrawTokenTooMuch() public {
        schnaps.payWithToken(token, amount, barcode);

        vm.prank(owner);
        vm.expectRevert();
        schnaps.withdrawToken(token, receiver, amount + 1);
    }
}
