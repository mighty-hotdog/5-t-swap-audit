// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {StdInvariant} from "forge-std/StdInvariant.sol";
import {Test} from "forge-std/Test.sol";
import {PoolFactory} from "../../src/PoolFactory.sol";
import {TSwapPool} from "../../src/TSwapPool.sol";
import {ERC20Mock} from "../mocks/ERC20Mock.sol";

contract Invariants is StdInvariant, Test {
    PoolFactory factory;
    TSwapPool pool;
    ERC20Mock mockWeth;
    ERC20Mock mockSwapToken;

    function setUp() external {
        mockWeth = new ERC20Mock("wETH", "WETH");
        mockSwapToken = new ERC20Mock("SwapToken","SWAP");
        factory = new PoolFactory(address(mockWeth));
        pool = TSwapPool(factory.createPool(address(mockSwapToken)));
    }

    function invariant_TSwapPoolInvariant() external {
        // x * y == k   where x is SwapToken and y is Weth
    }
}