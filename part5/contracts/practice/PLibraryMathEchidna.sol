pragma solidity 0.8.6;

import "../libraries/Reserve.sol";

contract PLibraryMathEchidna {

    Reserve.Data private reserve; 
    bool isSetUp;
    event LogUint256(uint256,uint256,uint256);

    function setUpReserve() public {
        reserve.reserveRisky = 1 ether;
        reserve.reserveStable = 2 ether;
        reserve.liquidity = 3 ether;
        isSetUp = true;
    }
   
    function reserve_allocate(uint delRisky, uint delStable) public {
        // PreConditions
        require(delRisky > 0 && delStable > 0, "delta risky and delta stable should be greater than zero");
        
        if (!isSetUp)
            setUpReserve();

        uint256 liquidity0 = (delRisky * reserve.liquidity) / uint256(reserve.reserveRisky); // calculate the risky token spot price 
        uint256 liquidity1 = (delStable * reserve.liquidity) / uint256(reserve.reserveStable); // calculate the stable token spot price

        uint delLiquidity = liquidity0 < liquidity1 ? liquidity0 : liquidity1; // min(risky,stable)
        require(delLiquidity > 0, "delta liquidity needs to be >0");
      
        uint preallocationreserverisky = reserve.reserveRisky;
        uint preallocationreservestable = reserve.reserveStable;
        uint preallocationreserveliquidity = reserve.liquidity; 

        // Actions
        Reserve.allocate(reserve, delRisky, delStable, delLiquidity, 1000);

        // PostConditions

        emit LogUint256(delRisky, preallocationreserverisky, reserve.reserveRisky );
        emit LogUint256(delStable, preallocationreservestable, reserve.reserveStable );
        emit LogUint256(delLiquidity, preallocationreserveliquidity, reserve.liquidity );

        assert(reserve.reserveRisky ==  preallocationreserverisky+ delRisky);
        assert(reserve.reserveStable == preallocationreservestable + delStable);
        assert(reserve.liquidity == preallocationreserveliquidity + delLiquidity);
    }

    function removeLiquidity(uint delRisky, uint delStable) public {
        require(delRisky > 0 && delStable > 0, "delrisky and delstabel should be >0");

        if (!isSetUp)
            setUpReserve();

        uint256 liquidity0 = (delRisky * reserve.liquidity) / uint256(reserve.reserveRisky); // calculate the risky token spot price 
        uint256 liquidity1 = (delStable * reserve.liquidity) / uint256(reserve.reserveStable); // calculate the stable token spot price

        uint delLiquidity = liquidity0 < liquidity1 ? liquidity0 : liquidity1; // min(risky,stable)
        require(delLiquidity > 0, "delta liquidity needs to be >0");

        uint preallocationreserverisky = reserve.reserveRisky;
        uint preallocationreservestable = reserve.reserveStable;
        uint preallocationreserveliquidity = reserve.liquidity; 

        // Actions
        Reserve.remove(reserve, delRisky, delStable, delLiquidity, 1000);

        // PostConditions

        emit LogUint256(delRisky, preallocationreserverisky, reserve.reserveRisky );
        emit LogUint256(delStable, preallocationreservestable, reserve.reserveStable );
        emit LogUint256(delLiquidity, preallocationreserveliquidity, reserve.liquidity );

        assert(reserve.reserveRisky ==  preallocationreserverisky - delRisky);
        assert(reserve.reserveStable == preallocationreservestable - delStable);
        assert(reserve.liquidity == preallocationreserveliquidity - delLiquidity);
    }

    function allocate_then_remove(uint delRisky, uint delStable) public {
        // PreConditions
        require(delRisky > 0 && delStable > 0, "delta risky and delta stable should be greater than zero");
        
        if (!isSetUp)
            setUpReserve();

        uint256 liquidity0 = (delRisky * reserve.liquidity) / uint256(reserve.reserveRisky); // calculate the risky token spot price 
        uint256 liquidity1 = (delStable * reserve.liquidity) / uint256(reserve.reserveStable); // calculate the stable token spot price

        uint delLiquidity = liquidity0 < liquidity1 ? liquidity0 : liquidity1; // min(risky,stable)
        require(delLiquidity > 0, "delta liquidity needs to be >0");
      
        uint preallocationreserverisky = reserve.reserveRisky;
        uint preallocationreservestable = reserve.reserveStable;
        uint preallocationreserveliquidity = reserve.liquidity; 

        // Actions
        Reserve.allocate(reserve, delRisky, delStable, delLiquidity, 1000);
        Reserve.remove(reserve, delRisky, delStable, delLiquidity, 1000);

        // PostConditions

        emit LogUint256(delRisky, preallocationreserverisky, reserve.reserveRisky );
        emit LogUint256(delStable, preallocationreservestable, reserve.reserveStable );
        emit LogUint256(delLiquidity, preallocationreserveliquidity, reserve.liquidity );

        assert(reserve.reserveRisky ==  preallocationreserverisky);
        assert(reserve.reserveStable == preallocationreservestable);
        assert(reserve.liquidity == preallocationreserveliquidity);
    }
}