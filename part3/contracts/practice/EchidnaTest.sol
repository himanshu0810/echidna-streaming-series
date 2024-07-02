pragma solidity ^0.6.0;

import "./Setup.sol";

contract EchidnaTest is Setup {

    function testProvideLiquidity(uint _amount0, uint _amount1) public {
        // Preprocessing
        _amount0 = _between(_amount0, 1000, uint(-1));
        _amount1 = _between(_amount1, 1000, uint(-1));

        if(!completed) {
            _init(_amount0, _amount1);
        }

        (uint reserveToken0, uint reserveToken1,) = pair.getReserves();
        uint lpTokenBefore = pair.balanceOf(address(user));
        uint kBefore = reserveToken0 * reserveToken1;

        (bool success1, ) = user.proxy(address(token0), 
                abi.encodeWithSelector(token0.transfer.selector, address(pair), amount0));
        (bool success2, ) = user.proxy(address(token1), 
                abi.encodeWithSelector(token1.transfer.selector, address(pair), amount2));
        rrquire(success1 && success2);

        // Actions
        (bool success, ) = user.proxy(address(pair), 
            abi.encodeWithSelector(bytes4(keccak256("mint(address)")), address(user)));

        // PostProcessing
        if (success) {
            uint lpTokenAfter = pair.balanceof(user);
            (uint reserveToken0, uint reserveToken1,) = pair.getReserves();
            uint kAfter = reserveToken0 * reserveToken1;
            assert(kBefore < KAfter);
            assert(lpTokenBefore < lpTokenAfter);
        }
    }
}