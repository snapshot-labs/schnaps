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
    bytes barcode = "0xdeadbeef";
    IERC20 token;

    event PaymentReceived(address sender, address token, uint256 amount, bytes barcode);

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
}
