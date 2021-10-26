//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
// TODO: if user makes 2 stakes with the same address should I sum stakes or revert

contract Staking is Ownable {
    IERC20 public stakingToken;
    uint allActiveStakes;
    uint rewardToBeDistributed;

    struct StakeHolder {
        address _address;
        uint stake;
    }

    StakeHolder[] internal stakeHolders;
    mapping(address => uint) internal So;

    constructor(address tokenAddress) {
        stakingToken = IERC20(tokenAddress);
        stakeHolders.push(); // avoid 0 index
    }

    function getStakeHolder(address _address) public view returns(uint) {
        for (uint i = 0; i < stakeHolders.length; i += 1){
            if (_address == stakeHolders[i]._address) {
                return i;
            }
        }
        return 0;
    }

    function stake(uint amount) external {
        stakeHolders.push(StakeHolder(msg.sender, amount));
        So[msg.sender] = rewardToBeDistributed;
        allActiveStakes += amount;
        stakingToken.transferFrom(msg.sender, address(this), amount);
    }

    function distribute(uint reward) onlyOwner external {
        require(allActiveStakes != 0, 'You need at least one ');
        rewardToBeDistributed += reward / allActiveStakes;
        stakingToken.transferFrom(msg.sender, address(this), reward);
    }

    function unstake() external {
        StakeHolder memory holder = stakeHolders[getStakeHolder(msg.sender)];
        allActiveStakes -= holder.stake;
        uint amount = holder.stake + holder.stake * (rewardToBeDistributed - So[msg.sender]);
        holder.stake = 0;
        stakingToken.transfer(msg.sender, amount);
    }
}