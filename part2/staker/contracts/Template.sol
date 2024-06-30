pragma solidity ^0.8.17;

import "./Staker.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {

    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {}

    function mint(address _to, uint256 _amount) external {
        _mint(_to, _amount);
    }
}

// We are using an external testing methodology
contract EchidnaTemplate {

    MockERC20 token;
    Staker stakerContract;

    constructor() {
        token = new MockERC20("TOKEN", "tok");
        stakerContract = new Staker(address(token));
    }

    function stakeTest(uint256 _amount) public returns(uint256 stakedAmount){
        // Pre-condition
        require(token.balanceOf(address(this)) >= _amount);

        // action
        uint256 preStakeBalance = stakerContract.stakedBalances(address(this));
        _amount = 1 + (_amount % (token.balanceOf(address(this))));
        stakerContract.stake(_amount);
        stakedAmount = _amount;

        // Post-Condition
        assert(stakerContract.stakedBalances(address(this)) == preStakeBalance + _amount);
    }

    function unstakeTest(uint256 _amount) public returns(uint256 unstakedAmount) {
        // Pre-Condition
        require(stakerContract.stakedBalances(address(this)) >= _amount);
        
        // Action
        uint256 preTokenBalance = token.balanceOf(address(this));
        _amount = 1 + (_amount % token.balanceOf(address(this)));
        stakerContract.unstake(_amount);

        unstakedAmount = _amount;

        // Post-Condition
        assert(token.balanceOf(address(this)) == preTokenBalance + _amount);
    }
}