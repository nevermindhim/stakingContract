//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.4;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Staking is Ownable {
    IERC20 public stakingToken;

    uint public allActiveStakes;
    uint private rewardToBeDistributed;
    uint constant decimals = 1e18;

    struct StakeHolder {
        address _address;
        uint _stake;
    }
    
    struct RewardHolder {
        address _address;
        uint _reward;
    }

    StakeHolder[] internal stakeHolders;
    mapping(address => uint) internal So;
    // TODO: add events

    constructor(address tokenAddress) {
        stakingToken = IERC20(tokenAddress);
        stakeHolders.push(); // get rid of zero index
    }

    function getStakeHolderIndex(address _address) private view returns (uint) {
        for (uint i = 1; i < stakeHolders.length; i += 1){
            if (_address == stakeHolders[i]._address) {
                return i;
            }
        }
        return 0;
    }

    function stake(uint amount) public {
        uint index = getStakeHolderIndex(msg.sender);
        bool holderNotExist = index == 0;
        bool zeroHolderAlreadyExist = (index != 0 && stakeHolders[index]._stake == 0);
        require(holderNotExist || zeroHolderAlreadyExist, 'Staker already exist');

        if (holderNotExist) {
            stakeHolders.push(StakeHolder(msg.sender, amount));
        }
        if (zeroHolderAlreadyExist) {
            stakeHolders[index]._stake = amount;
        }
        
        So[msg.sender] = rewardToBeDistributed;
        allActiveStakes += amount;
        stakingToken.transferFrom(msg.sender, address(this), amount);
    }
    
    function calculateReward(StakeHolder memory stakeHolder) internal view returns (uint) {
        // devide decimals to bring values back to normal format
        return stakeHolder._stake + (stakeHolder._stake * (rewardToBeDistributed - So[stakeHolder._address])) / decimals;
    }
    
    function getAllStakers() public view returns (RewardHolder[] memory) {
        RewardHolder[] memory rewardHolders = new RewardHolder[](stakeHolders.length - 1);
        for (uint i = 1; i < stakeHolders.length; i += 1){
            StakeHolder memory stakeHolder = stakeHolders[i];
            uint reward = calculateReward(stakeHolder);
            rewardHolders[i - 1] = RewardHolder(stakeHolder._address, reward);
        }
        return rewardHolders;
    }

    function distribute(uint reward) onlyOwner public {
        require(allActiveStakes != 0, 'You need at least one ');

        rewardToBeDistributed += reward * decimals / allActiveStakes; // multiply by decimals to not to lose decimals
        stakingToken.transferFrom(msg.sender, address(this), reward);
    }

    function unstake() public {
        uint index = getStakeHolderIndex(msg.sender);
        StakeHolder storage holder = stakeHolders[index];
        require(holder._stake != 0, 'Nothing to unstake');

        allActiveStakes -= holder._stake;
        uint amount = calculateReward(holder);
        holder._stake = 0;
        stakingToken.transfer(msg.sender, amount);
    }
}