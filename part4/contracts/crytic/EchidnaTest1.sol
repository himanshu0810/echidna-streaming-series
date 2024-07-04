pragma solidity ^0.6.0;
import "./Setup1.sol";

contract EchidnaTest1 is Setup1 {
    using SafeMath for uint;
    event logUints(uint kBefore, uint kAfter);
    function testProvideLiquidityInvariants(uint amount1, uint amount2) public {
        //PRECONDITIONS:
        amount1 = _between(amount1, 1000, uint(-1));
        amount2 = _between(amount2, 1000, uint(-1));
        if(!complete) {
            _init(amount1,amount2);
        }
        
        uint pairBalanceBefore = testPair.balanceOf(address(user));    
        (uint reserve1Before, uint reserve2Before) = 
        UniswapV2Library.getReserves(address(factory), address(testToken1), address(testToken2));

        
          
    }
}