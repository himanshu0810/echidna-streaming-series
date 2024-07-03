pragma solidity ^0.6.0;

import "./Setup.sol";
import "../libraries/UniswapV2Library.sol";
import "../uni-v2/UniswapV2Router01.sol";


contract EchidnaTest is Setup {

    // Modify the test provide liquidity function using the periphery
    function testProvideLiquidity(uint amount0, uint amount1) public {
        // Preconditions:
        amount0 = _between(amount0, 1000, uint(-1));
        amount1 = _between(amount1, 1000, uint(-1));

        if (!completed) {
            _init(amount0, amount1);
        }
        //// State before
        uint lpTokenBalanceBefore = pair.balanceOf(address(user));
        (uint reserve0Before, uint reserve1Before) = UniswapV2Library.getReserves(address(factory), address(testToken1), address(testToken2));
        uint kBefore = reserve0Before * reserve1Before;
        
        // Action:
        (bool success3,) = user.proxy(address(pair), abi.encodeWithSelector(
            uniswapRouter.addLiquidity.selector, 
            address(testToken1),
            address(testToken2),
            amount0,
            amount1,
            0, 0 , uint(-1)));

        // Postconditions:
        if (success3) {
            uint lpTokenBalanceAfter = pair.balanceOf(address(user));
            (uint reserve0After, uint reserve1After) = UniswapV2Library.getReserves(address(factory), address(testToken1), address(testToken2));
            uint kAfter = reserve0After * reserve1After;
            assert(lpTokenBalanceBefore < lpTokenBalanceAfter);
            assert(kBefore < kAfter);
        }
    }

    // Test the remove liquidity function 


    // test the swap functionality

}