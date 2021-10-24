const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ERC-20 token", function () {
  let accounts;

  before(async () => {
    accounts = await ethers.getSigners();
  });

  it("Should create ERC-20 token and mint all to owner address", async function () {
    const TKNContract = await ethers.getContractFactory("TKN");
    const token = await TKNContract.deploy(1000000);
    await token.deployed();

    expect(await token.totalSupply()).to.equal(1000000);
    // owner balance should contain 1000000 TKNs
    expect(await token.balanceOf(accounts[0].address)).to.equal(1000000);
  });
});
