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

    // function testRemoveLiquidity(uint liquidityToRemove) public {
    //     uint lpTokenBalance = pair.balanceOf(address(user));
    //     require(lpTokenBalance > 0 , "not enough liquidity");
    //     (uint reserve0Before, uint reserve1Before) = 
    //     UniswapV2Library.getReserves(address(factory), address(testToken1), address(testToken2));
    //     uint kBefore = reserve0Before * reserve1Before;
    //     liquidityToRemove = _between(liquidityToRemove, 1, lpTokenBalance);

    //     (bool success1,) = user.proxy(address(pair),abi.encodeWithSelector(pair.approve.selector,address(uniswapRouter),uint(-1)));
    //     require(success1);

    //     (bool success, ) = 
    //     user.proxy(address(uniswapRouter), abi.encodeWithSelector(
    //         uniswapRouter.removeLiquidity.selector, 
    //         address(testToken1), 
    //         address(testToken2),
    //         liquidityToRemove,
    //         0, 0, address(user), uint(-1)));

    //     if (success) {
    //         uint lpTokenAfter = pair.balanceOf(address(user));
    //         (uint reserve0After, uint reserve1After) = 
    //         UniswapV2Library.getReserves(address(factory), address(testToken1), address(testToken2));
    //         uint kAfter = reserve0After * reserve1After;
    //         assert(lpTokenAfter <= lpTokenBalance);
    //         assert(kAfter <= kBefore);
    //     }    
    // }

    function testSwapTokens(uint amount0) public {

        require(amount0 > 0 , "Amount swapped should be gt than zero");

        address[] memory path = new address[](2);
        path[0] = address(testToken1);
        path[1] = address(testToken2);

        (uint reserve0Before, uint reserve1Before) = 
        UniswapV2Library.getReserves(address(factory), address(testToken1), address(testToken2));
        uint kBefore = reserve0Before * reserve1Before;

        uint balanceTestToken1 = testToken1.balanceOf(address(user));
        uint balanceTestToken2 = testToken2.balanceOf(address(user));

        (bool success,) = user.proxy(address(uniswapRouter), abi.encodeWithSelector(uniswapRouter.swapExactTokensForTokens.selector, amount0, 0, path, address(user), uint(-1)));

        if (success) {
            (uint reserve0After, uint reserve1After) = 
            UniswapV2Library.getReserves(address(factory), address(testToken1), address(testToken2));
            uint kAfter= reserve0After * reserve1After;

            uint balanceAfterTestToken1 = testToken1.balanceOf(address(user));
            uint balanceAfterTestToken2 = testToken2.balanceOf(address(user));

            assert(kAfter > kBefore);
            assert(balanceAfterTestToken1 < balanceTestToken1);
            assert(balanceAfterTestToken2 > balanceTestToken2);
        }
    }
}
