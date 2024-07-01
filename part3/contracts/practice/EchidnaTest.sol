pragma solidity ^0.6.0;

import "./Setup.sol";

contract EchidnaTest is Setup {

    function testPRovideLiquidity(uint _amount0, uint _amount1) public {
        // Preprocessing
        _amount0 = _between(_amount0, 1000, uint(-1));
        _amount1 = _between(_amount1, 1000, uint(-1));

        if(!completed) {
            _init(_amount0, _amount1);
        }

        (uint reserveToken0, uint reserveToken1,) = pair.getReserves();
        
        uint lpTokenBefore = pair.balanceOf(address(user));
        uint kBefore = reserveToken0 * reserveToken1;

        // Actions
        (bool success, _ ) = pair.mint(address(user));

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