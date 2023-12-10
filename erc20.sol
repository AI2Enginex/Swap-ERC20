// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// swapExactTokensForTokens that is expected to be present in a smart contract. 
// This interface is often used when interacting with decentralized exchange routers, 
// such as Uniswap or PancakeSwap, to swap tokens on the Ethereum or Binance Smart Chain (BSC) networks.
// This interface provides a standardized way for other contracts or scripts to interact with a Uniswap-like router
interface IUniswapV2Router02 {
    function swapExactTokensForTokens(
        uint amountIn,             // The amount of the input token (the token you want to swap).
        uint amountOutMin,         // minimum amount of tokens to transfer
        address[] calldata path,   // the minimum amount of the output token (the token you want to receive) that must be received for the swap to be considered successful. 
                                    // This helps protect against slippage.
        address to,                 // recipient's address
        uint deadline               // the deadline of the transaction 
    ) external returns (uint[] memory amounts);  // The amounts of tokens received at each step of the swap. 
                                                // For example, if you're swapping Token A for Token B and then Token B 
                                                // for Token C, this array would contain the amounts of Token B and Token C received
                                                // keyword "external" indicated that the function is only accessible outside the contract
}

contract TokenSwap is IUniswapV2Router02 {
    using SafeERC20 for IERC20;

    address public tokenA;
    address public tokenB;
    address public uniswapRouter; // Address of Uniswap-like router
    bool public initialized; // Flag to check if initialized

    constructor() {
        initialized = false;
    }

    function initialize(address _tokenA, address _tokenB, address _uniswapRouter) external {
        require(!initialized, "Already initialized");
        tokenA = _tokenA;
        tokenB = _tokenB;
        uniswapRouter = _uniswapRouter;
        initialized = true;
    }

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external override returns (uint[] memory amounts) {
        // Assuming ERC-20 tokens
        IERC20(path[0]).safeTransferFrom(msg.sender, address(this), amountIn);

        // Approve Uniswap router to spend tokens
        IERC20(path[0]).approve(uniswapRouter, amountIn);

        // Swap tokens using Uniswap router
        amounts = IUniswapV2Router02(uniswapRouter).swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            to,
            deadline
        );

        return amounts;
    }
}
