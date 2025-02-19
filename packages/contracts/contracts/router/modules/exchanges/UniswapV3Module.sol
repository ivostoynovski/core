// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {BaseExchangeModule} from "./BaseExchangeModule.sol";
import {BaseModule} from "../BaseModule.sol";
import {IUniswapV3Router} from "../../interfaces/IUniswapV3Router.sol";

// Notes on the UniswapV3 module:
// - supports swapping tokens via direct paths

contract UniswapV3Module is BaseExchangeModule {
    using SafeERC20 for IERC20;

    // --- Fields ---

    address public constant weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    address public constant swapRouter =
        0xE592427A0AEce92De3Edee1F18E0157C05861564;

    // --- Constructor ---

    constructor(address owner, address router)
        BaseModule(owner)
        BaseExchangeModule(router)
    {}

    // --- Swaps ---

    function ethToExactOutput(
        IUniswapV3Router.ExactOutputSingleParams calldata params,
        address refundTo
    ) external payable refundETHLeftover(refundTo) {
        if (params.tokenIn != weth) {
            revert WrongParams();
        }

        IUniswapV3Router(swapRouter).exactOutputSingle{value: msg.value}(
            params
        );
    }

    function erc20ToExactOutput(
        IUniswapV3Router.ExactOutputSingleParams calldata params,
        address refundTo
    ) external refundERC20Leftover(refundTo, params.tokenIn) {
        approveERC20IfNeeded(
            params.tokenIn,
            swapRouter,
            params.amountInMaximum
        );
        IUniswapV3Router(swapRouter).exactOutputSingle(params);
    }
}
