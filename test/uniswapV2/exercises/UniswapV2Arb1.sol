// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IUniswapV2Pair} from
    "../../../src/interfaces/uniswap-v2/IUniswapV2Pair.sol";
import {IUniswapV2Router02} from
    "../../../src/interfaces/uniswap-v2/IUniswapV2Router02.sol";
import {IERC20} from "../../../src/interfaces/IERC20.sol";

contract UniswapV2Arb1 {
    struct SwapParams {
        // Router to execute first swap - tokenIn for tokenOut
        address router0;
        // Router to execute second swap - tokenOut for tokenIn
        address router1;
        // Token in of first swap
        address tokenIn;
        // Token out of first swap
        address tokenOut;
        // Amount in for the first swap
        uint256 amountIn;
        // Revert the arbitrage if profit is less than this minimum
        uint256 minProfit;
    }

    // Exercise 1
    // - Execute an arbitrage between router0 and router1
    // - Pull tokenIn from msg.sender
    // - Send amountIn + profit back to msg.sender
    function swap(SwapParams calldata params) external {
        // Write your code here
        // Don’t change any other code
        address [] memory  path =  new address[](2);
        path[0] = params.tokenIn;
        path[1] = params.tokenOut;
        IERC20(params.tokenIn).transferFrom(msg.sender,address(this),params.amountIn);
        IERC20(params.tokenIn).approve(params.router0,params.amountIn);
        uint256[] memory amounts = IUniswapV2Router02(params.router0).swapExactTokensForTokens({
            amountIn: params.amountIn,
            amountOutMin: 1,
            path: path,
            to: address(this),
            deadline: block.timestamp
        });
        IERC20(params.tokenOut).approve(params.router1,amounts[1]);
        address [] memory path2 = new address[](2);
        path2[0] = params.tokenOut;
        path2[1] = params.tokenIn;
        uint256[] memory amountsFinal = IUniswapV2Router02(params.router1).swapExactTokensForTokens({
            amountIn: amounts[1],
            amountOutMin: 1,
            path: path2,
            to:address(this),
            deadline: block.timestamp
        });
        require(amountsFinal[1] - params.amountIn > params.minProfit,"not enough profit");
        IERC20(params.tokenIn).transfer(msg.sender,amountsFinal[1]);
            
        
    }
    

    // Exercise 2
    // - Execute an arbitrage between router0 and router1 using flash swap
    // - Borrow tokenIn with flash swap from pair
    // - Send profit back to msg.sender
    /**
     * @param pair Address of pair contract to flash swap and borrow tokenIn
     * @param isToken0 True if token to borrow is token0 of pair
     * @param params Swap parameters
     */
    function flashSwap(address pair, bool isToken0, SwapParams calldata params)
        external
    {
        (uint256 amount0Out, uint256 amount1Out) = isToken0 ? (params.amountIn,uint256(0)) : (uint256(0),params.amountIn);
        address to = address(this);
        bytes memory data = abi.encode(params, to);
        IUniswapV2Pair(pair).swap({
            amount0Out:amount0Out,
            amount1Out:amount1Out,
            to:address(this),
            data: data
        });

    }

    function uniswapV2Call(
        address sender,
        uint256 amount0Out,
        uint256 amount1Out,
        bytes calldata data
    ) external {
        // Write your code here
        // Don’t change any other code
        (SwapParams memory params , address to ) =abi.decode(data,(SwapParams,address));
        IERC20(params.tokenIn).approve(params.router0,params.amountIn);
        address [] memory  path =  new address[](2);
        path[0] = params.tokenIn;
        path[1] = params.tokenOut;
        uint256[] memory amounts = IUniswapV2Router02(params.router0).swapExactTokensForTokens({
            amountIn: params.amountIn,
            amountOutMin: 1,
            path: path,
            to: address(this),
            deadline: block.timestamp
        });
        IERC20(params.tokenOut).approve(params.router1,amounts[1]);
        address [] memory path2 = new address[](2);
        path2[0] = params.tokenOut;
        path2[1] = params.tokenIn;
        uint256[] memory amountsFinal = IUniswapV2Router02(params.router1).swapExactTokensForTokens({
            amountIn: amounts[1],
            amountOutMin: 1,
            path: path2,
            to:address(this),
            deadline: block.timestamp
        });
        uint256 amountToRepay = (params.amountIn * 1000) / 997 + 1;
        uint256 profit = amountsFinal[1] - amountToRepay;
        
        require(profit >= params.minProfit,"not enough profit");
        IERC20(params.tokenIn).transfer(msg.sender,amountToRepay);
        IERC20(params.tokenIn).transfer(to,profit);

        
    }
}