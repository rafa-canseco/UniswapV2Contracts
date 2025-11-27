// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test,console2} from"forge-std/Test.sol";
import {IERC20} from "../../src/interfaces/IERC20.sol";
import {IWETH} from "../../src/interfaces/IWETH.sol";
import {IUniswapV2Router02} from "../../src/interfaces/uniswap-v2/IUniswapV2Router02.sol";
import {DAI,WETH,MKR,UNI,UNISWAP_V2_ROUTER_02} from "../../src/interfaces/Constants.sol";

contract UniswapV2SwapAmountsTests is Test {
    IWETH private constant weth = IWETH(WETH);
    IERC20 private constant dai = IERC20(DAI);
    IERC20 private constant mkr = IERC20(MKR);
    IERC20 private constant uni = IERC20(UNI);
    
    IUniswapV2Router02 private constant router = 
        IUniswapV2Router02(UNISWAP_V2_ROUTER_02);
        
        function test_getAmountsOut() public view {
            address [] memory path = new address[](3);
            path[0] = WETH;
            path[1] = DAI;
            path[2] = MKR;
            
            uint256 amountIn = 1e18;
            uint[] memory amounts = router.getAmountsOut(amountIn, path);
            
            console2.log("WETH", amounts[0]);
            console2.log("DAI", amounts[1]);
            console2.log("MKR", amounts[2]);
            
            //getAmountsOut(uint amountIn, address[] memory path)
            // returns (uint[] memory amounts)
        }
        
        function test_getsAmountIn() public view {
            address [] memory path = new address[](3);
            path[0] = WETH;
            path[1] = DAI;
            path[2] = UNI;
            
            uint256 amountOut = 1e18;
            
            uint256[] memory amounts = router.getAmountsIn(amountOut, path);
            
            console2.log("WETH", amounts[0]);
            console2.log("DAI", amounts[1]);
            console2.log("UNI", amounts[2]);
            
        }
    
    
}