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

        // State before
        uint lpTokenBalanceBefore = pair.balanceOf(address(user));
        (uint reserve0Before, uint reserve1Before) = 
        UniswapV2Library.getReserves(address(factory), address(testToken1), address(testToken2));

        uint kBefore = reserve0Before * reserve1Before;
 
        (bool success, ) = user.proxy(address(uniswapRouter), abi.encodeWithSelector(uniswapRouter.addLiquidity.selector, address(testToken1), address(testToken2), amount0, amount1, 0, 0, address(user), uint(-1)));
        
        if (success) {
            uint lpTokenBalanceAfter = pair.balanceOf(address(user));
            (uint reserve0After, uint reserve1After) =
            UniswapV2Library.getReserves(address(factory), address(testToken1), address(testToken2));

            uint kAfter = reserve0After * reserve1After;

            assert(lpTokenBalanceBefore < lpTokenBalanceAfter);
            assert(kBefore < kAfter);
        }
    }

    function testRemoveLiquidity(uint liquidityToRemove) public {

        uint lpTokenBalance = pair.balanceOf(address(user));
        (uint reserve0Before, uint reserve1Before) = 
        UniswapV2Library.getReserves(address(factory), address(testToken1), address(testToken2));

        uint kBefore = reserve0Before * reserve1Before;

        liquidityToRemove = _between(liquidityToRemove, 0, lpTokenBalance);

        (bool success, ) = 
        user.proxy(address(uniswapRouter), abi.encodeWithSelector(
            uniswapRouter.removeLiquidity.selector, 
            address(testToken1), 
            address(testToken2),
            liquidityToRemove,
            0, 0, address(user), uint(-1)));

        if (success) {
            uint lpTokenAfter = pair.balanceOf(address(user));
            (uint reserve0After, uint reserve1After) = 
            UniswapV2Library.getReserves(address(factory), address(testToken1), address(testToken2));

            uint kAfter = reserve0After * reserve1After;
            assert(lpTokenAfter <= lpTokenBalance);
            assert(kAfter <= kBefore);
        }    
    }

}
