// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

const totalSupply = Number(process.env.SUPPLY) || 1000000 // 1M by default

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  await hre.run('compile');

  const [ deployer ] = await hre.ethers.getSigners();
  console.log(`Deploying contracts with the account: ${deployer.address}`);
  console.log(`Account balance: ${hre.ethers.utils.formatEther((await deployer.getBalance()).toString())}`);

  // deploy token itself
  const TKNContract = await hre.ethers.getContractFactory("TKN");
  const token = await TKNContract.deploy(totalSupply);

  await token.deployed();
  console.log(`Token contract deployed on the address ${token.address} with supply ${totalSupply}`);

  // deploy staking contract
  const StakingContract = await hre.ethers.getContractFactory('Staking');
  const staking = await StakingContract.deploy(token.address);
  await staking.deployed();
  console.log(`Staking contract deployed on the address ${staking.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
