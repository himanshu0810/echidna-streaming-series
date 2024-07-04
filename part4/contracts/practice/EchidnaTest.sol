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

        
        try user.proxy(address(uniswapRouter), abi.encodeWithSelector(uniswapRouter.addLiquidity.selector, address(testToken1), address(testToken2), amount0, amount1, 0, 0, address(user), uint(-1)))
        {}
        catch { assert(false); }


    }
}