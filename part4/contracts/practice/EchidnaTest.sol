pragma solidity ^0.6.0;

import "./Setup.sol";
import "../libraries/UniswapV2Library.sol";
import "../uni-v2/UniswapV2Router01.sol";

contract EchidnaTest is Setup {
    using SafeMath for uint;

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
        require(lpTokenBalance > 0 , "not enough liquidity");
        (uint reserve0Before, uint reserve1Before) = 
        UniswapV2Library.getReserves(address(factory), address(testToken1), address(testToken2));
        uint kBefore = reserve0Before * reserve1Before;
        liquidityToRemove = _between(liquidityToRemove, 1, lpTokenBalance);

        (bool success1,) = user.proxy(address(pair),abi.encodeWithSelector(pair.approve.selector,address(uniswapRouter),uint(-1)));
        require(success1);

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


    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

    function testPathIndependenceForSwaps(uint x) public {
        
        if (!completed) {
            _init(1_000_000_000, 1_000_000_000);
        }

        (uint reserve0, uint reserve1) = UniswapV2Library.getReserves(address(factory), address(testToken1), address(testToken2));

        uint MIN_AMOUNT = 100;
        uint userBalance = testToken1.balanceOf(address(user));

        require(userBalance > MIN_AMOUNT);

        x = _between(x, MIN_AMOUNT, uint(-1)/ 100);
        x = _between(x, MIN_AMOUNT, userBalance);

        require(reserve0 > MIN_AMOUNT, "Not enough reserve");
        require(reserve1 > MIN_AMOUNT, "Not enough reserve");

        uint yOut;
        {
            yOut = getAmountOut(x, reserve0, reserve1);
            if (yOut == 0)
                yOut = 1;
            x = getAmountIn(yOut, reserve0, reserve1);        
        }

        address[] memory path12 = new address[](2);
        path12[0] = address(testToken1);
        path12[1] = address(testToken2);
        address[] memory path21 = new address[](2);
        path21[0] = address(testToken2);
        path21[1] = address(testToken1);

        bool success;
        bytes memory retdata;
        uint xOut;
        uint[] memory amounts;

        (success, retdata) = 
        user.proxy(address(uniswapRouter), abi.encodeWithSelector(uniswapRouter.swapExactTokensForTokens.selector, x, 0, path12, address(user), uint(-1)));
        if (!success)
            return;

        amounts = abi.decode(retdata, (uint[]));
        yOut = amounts[1];

        (success, retdata) = 
        user.proxy(address(uniswapRouter), abi.encodeWithSelector(uniswapRouter.swapExactTokensForTokens.selector, yOut, 0, path21, address(user), uint(-1)));
        if (!success)
            return;

        amounts = abi.decode(retdata, (uint[]));
        xOut = amounts[1];

        assert(xOut < x);
        assert(((x - xOut) * 100) <= (3 * x));
    }
}