pragma solidity 0.8.6;

import "../libraries/Margin.sol";

contract MarginTest {
    Margin.Data margin;
    mapping (address => Margin.Data) private margins;

    function testDeposit(uint delRisky, uint delStable) public {
        uint preBalRisky = margin.balanceRisky;
        uint preBalStable = margin.balanceStable;

        // Actions
        Margin.deposit(margin, delRisky, delStable);
        
        // Postconditions
        assert(preBalRisky + delRisky == margin.balanceRisky);
        assert(preBalStable + delStable == margin.balanceStable);
    }

    function testWithdraw(uint delRisky, uint delStable) public {
        uint preBalRisky = margin.balanceRisky;
        uint preBalStable = margin.balanceStable;

        // Actions
        Margin.withdraw(margins, delRisky, delStable);
        
        // Postconditions
        assert(preBalRisky - delRisky == margin.balanceRisky);
        assert(preBalStable - delStable == margin.balanceStable);
    }
}