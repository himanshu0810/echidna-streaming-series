pragma solidity ^0.6.0;

import "../uni-v2/UniswapV2Pair.sol";
import "../uni-v2/UniswapV2Factory.sol";
import "../uni-v2/UniswapV2ERC20.sol";

contract User {

    function proxy(address target, bytes memory data) public returns(bool success, bytes memory retdata) {
        return target.call(data);
    }
}

contract Setup {

    UniswapV2ERC20 token0;
    UniswapV2ERC20 token1;
    UniswapV2Pair pair;
    UniswapV2Factory uniswapFactory;
    User user;

    constructor() public {
        token0 = new UniswapV2ERC20();
        token1 = new UniswapV2ERC20();
        uniswapFactory = new UniswapV2Factory(address(user));
        pair = uniswapFactory.createPair(address(token0), address(token1));
        user = new User();

        user.proxy(address(token0), abi.encodeWithSelector(token0.approve.selector, 
            address(pair), uint(-1)));
        user.proxy(address(token1), abi.encodeWithSelector(token1.approve.selector, 
            address(pair), uint(-1)));
    }

    function _init(uint _amount0, uint _amount1) internal {
        token0.mint(address(user), _amount1);
        token1.mint(address(user), _amount1);
        completed = true;
    }

    function _between(uint value, uint low, uint high) {
        return low + (value % (high - low) + 1);
    }
}