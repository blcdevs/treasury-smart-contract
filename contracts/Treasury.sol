//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

interface IProtocolAdapter {
    function deposit(uint256 amount) external;
    function withdraw(uint256 amount) external;
    function getBalance() external view returns (uint256);
    function getAPY() external view returns (uint256);
}

contract Treasury is Ownable {
    using SafeMath for uint256;

    IERC20 public stableCoin;
    IProtocolAdapter[] public adapters;
    uint256[] public distributionRatios;

    constructor(IERC20 _stableCoin) {
        stableCoin = _stableCoin;
    }

    function addAdapter(IProtocolAdapter adapter, uint256 ratio) external onlyOwner {
        adapters.push(adapter);
        distributionRatios.push(ratio);
    }

    function updateAdapterRatio(uint256 index, uint256 newRatio) external onlyOwner {
        distributionRatios[index] = newRatio;
    }

    function deposit(uint256 amount) external {
        stableCoin.transferFrom(msg.sender, address(this), amount);

        uint256 totalRatio = getTotalRatio();
        for (uint256 i = 0; i < adapters.length; i++) {
            uint256 adapterAmount = amount.mul(distributionRatios[i]).div(totalRatio);
            stableCoin.approve(address(adapters[i]), adapterAmount);
            adapters[i].deposit(adapterAmount);
        }
    }

    function withdraw(uint256 amount) external onlyOwner {
        uint256 totalRatio = getTotalRatio();
        for (uint256 i = 0; i < adapters.length; i++) {
            uint256 adapterAmount = amount.mul(distributionRatios[i]).div(totalRatio);
            adapters[i].withdraw(adapterAmount);
        }
        stableCoin.transfer(msg.sender, amount);
    }

    function getAggregatedAPY() external view returns (uint256) {
        uint256 totalRatio = getTotalRatio();
        uint256 aggregatedAPY = 0;

        for (uint256 i = 0; i < adapters.length; i++) {
            uint256 apy = adapters[i].getAPY();
            aggregatedAPY = aggregatedAPY.add(apy.mul(distributionRatios[i]).div(totalRatio));
        }

        return aggregatedAPY;
    }

    function getTotalRatio() internal view returns (uint256) {
        uint256 totalRatio = 0;
        for (uint256 i = 0; i < distributionRatios.length; i++) {
            totalRatio = totalRatio.add(distributionRatios[i]);
        }
        return totalRatio;
    }
}