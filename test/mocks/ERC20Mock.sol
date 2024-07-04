// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @notice A mock contract of the ERC20 standard for testing purposes.
 */
contract ERC20Mock is ERC20 {
    constructor(string memory name,string memory symbol) ERC20(name,symbol) {}

    /**
     * @dev Public ERC20 functions callable by anyone:
     *      name(), symbol(), decimals(), totalSupply(), balanceOf(),
     *      allowance(), approve(), transfer(), transferFrom()
     * @dev No burn() function available; not needed for this testing
     */
    function mint(address to,uint256 amount) external {
        _mint(to,amount);
    }
}