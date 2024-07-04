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

    /**
     * @dev original TSwap invariant formula: x * y == k, where
     *          x is token balance for SwapToken,
     *          y is token balance for Weth,
     *          k is a constant ratio
     *      this is a very common AMM invariant formula used in many other AMM protocols notably Uniswap
     *          Mint: add to k
     *          Burn: subtract from k
     *          Swap: shift x and y leaving k untouched
     *          Skim: realign x * y to be equal to k by trimming extra
     *      https://www.nascent.xyz/idea/youre-writing-require-statements-wrong
     * @dev Assumptions:
     *      1. invariants defined by TSwap are correct  // #a prob need to check the math later to be sure
     *      2. swaps do not use more than 8 decimals of precision   // #i to be code-enforced for the invariants test
     *      3. fee does not use more than 8 decimals of precision   // #i fee precision set to equal swap precision
     */
    function invariant_TSwapPoolInvariant() external {
        uint256 changeSwapToken;    // change of SwapToken balance in the pool
        uint256 amountSwapToken;    // balance of SwapToken in the pool b4 change
        uint256 changeWeth;         // change of Weth balance in the pool
        uint256 amountWeth;         // balance of Weth in the pool b4 change
        uint256 fee;                // swap fee, with feePrecision already applied
        uint256 swapPrecision;      // precision for swaps
        uint256 feePrecision;       // precision for fee

        // invariant formula check for SwapToken:
        //  changeSwapToken == (beta / (1 - beta)) * (1 / (1 - fee)) * amountSwapToken
        //      where:  beta = changeWeth * swapPrecision / amountWeth
        //              1 - beta = (1 * swapPrecision - changeWeth * swapPrecision / amountWeth)
        //      and:    1 - fee = 1 * feePrecision - fee
        //              (1 / (1 - fee)) = (1 * feePrecision / (1 * feePrecision - fee))
        //      therefore:
        //  changeSwapToken == (    (changeWeth * swapPrecision / amountWeth) / 
        //                          (   1 * swapPrecision - (changeWeth * swapPrecision / amountWeth)   )     ) * 
        //                     (    1 * feePrecision / (1 * feePrecision - fee)    ) * 
        //                     amountSwapToken
        assertEq(
                    changeSwapToken,
                    (   (changeWeth * swapPrecision / amountWeth) / 
                        (   1 * swapPrecision - (changeWeth * swapPrecision / amountWeth)   )   ) * 
                    (   (1 * feePrecision) / (1 * feePrecision - fee)   ) * 
                    (   amountSwapToken )
                );

        // invariant formula check for Weth:
        //  changeWeth == (alpha * gamma / (1 + alpha * gamma)) * amountWeth
        //      where:  alpha = changeWeth * swapPrecision / amountWeth
        //              gamma = 1 * feePrecision - fee
        //              alpha * gamma = (changeWeth * swapPrecision / amountWeth) * (1 * feePrecision - fee)
        //              1 + alpha * gamma = (1 * swapPrecision * feePrecision + (changeWeth * swapPrecision / amountWeth) * (1 * feePrecision - fee))
        //      therefore:
        //  changeWeth == ( (changeWeth * swapPrecision / amountWeth) * 
        //                  (1 * feePrecision - fee)    ) /
        //                  (1 * swapPrecision * feePrecision + (changeWeth * swapPrecision / amountWeth) * (1 * feePrecision - fee)    ) *
        //                  amountWeth
        assertEq(
                    changeWeth,
                    (   (changeWeth * swapPrecision / amountWeth) * 
                        (1 * feePrecision - fee)    ) /
                    (1 * swapPrecision * feePrecision + (changeWeth * swapPrecision / amountWeth) * (1 * feePrecision - fee)    ) *
                    amountWeth
                );
    }
}