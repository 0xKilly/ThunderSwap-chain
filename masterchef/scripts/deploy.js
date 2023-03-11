async function main() {

  const [owner] = await ethers.getSigners();
  const thunderPerBlock = "1000000000000000000"; // 1
  const currentBlock = 8626000;
  // mainnet 16800000
  // goerli 8626000

  const Token = await ethers.getContractFactory("ThunderToken");
  const token = await Token.deploy();
  await token.deployed();
  console.log("Deploy token : " + token.address);

  const Master = await ethers.getContractFactory("MasterChef");
  const master = await Master.deploy(token.address, thunderPerBlock, currentBlock);
  await master.deployed();
  console.log("Deploy master : " + master.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
