const { expect } = require("chai");
const { ethers } = require("hardhat");

describe('Staking', () => {
    let accounts;
    let owner;
    let staking;
    let token;
    const totalSupply = 1000000;

    before(async () => {
        accounts = await ethers.getSigners();
        owner = accounts[0];
        // deploy token to test network
        const TKNContract = await ethers.getContractFactory('TKN');
        token = await TKNContract.deploy(totalSupply);
        await token.deployed();

        // deploy staking contract
        const StakingContract = await ethers.getContractFactory('Staking');
        staking = await StakingContract.deploy(token.address);
        await staking.deployed();

        // let the contract approve transfer tokens from user account
        await token.approve(staking.address, totalSupply);
    });

    describe('stake', () => {
        it('should stake specific token amount', async () => {
            const amount = 1000;
            await expect(staking.stake(amount))
                .to.emit(staking, 'Stake')
                .withArgs(owner.address, amount);
            
            expect(await token.balanceOf(staking.address)).to.equal(amount);
            expect(await token.balanceOf(owner.address)).to.equal(totalSupply - amount);
        });
        // TODO: test user can't double stake
        // TODO: test user can't pass zero amount
        // TODO: test scenario stake -> unstake -> stake(should be able to stake again)
    });

    describe('distribute', () => {
        it('should distribute reward successfully', async () => {
            const reward = 200;
            await expect(staking.distribute(reward))
                .to.emit(staking, 'Distribute')
                .withArgs(reward);

            const expectedStakingBalance = 1000 + reward;
            const expectedOwnerBalance = totalSupply - expectedStakingBalance;
            expect(await token.balanceOf(staking.address)).to.equal(expectedStakingBalance);
            expect(await token.balanceOf(owner.address)).to.equal(expectedOwnerBalance);
        });
        // TODO: only owner can call this function
        // TODO: should revert if there are no active stakes
        // TODO: test fractional divisions and calculation rounding 
    });

    describe('getAllStakers', () => {
        it('should output all active stakers', async () => {
            expect(await staking.getAllStakers()).to.eql([[owner.address, ethers.BigNumber.from('1200')]]);
        });
        // TODO: should return multiple stakers
    });

    describe('unstake', () => {
        it('should unstake tokens successfully', async () => {
            const expectedReward = 1000 + 200;
            await expect(staking.unstake())
                .to.emit(staking, 'Unstake')
                .withArgs(owner.address, expectedReward);

            expect(await token.balanceOf(staking.address)).to.equal(0);
            expect(await token.balanceOf(owner.address)).to.equal(totalSupply);
        });
        // TODO: should revert if stake equals to zero
        // TODO: should revert if staker not exist
    });
});