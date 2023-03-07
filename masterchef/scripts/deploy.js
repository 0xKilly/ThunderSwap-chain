const fs = require('fs');

async function main() {

  const [owner] = await ethers.getSigners();
  const thunderPerBlock = "1000000000000000000"; // 1
  const currentBlock = 16777300;

  const Token = await ethers.getContractFactory("ThunderToken");
  const token = await Token.deploy();
  await token.deployed();
  fs.writeFile(__dirname + "/sources/tokenAddress", token.address, (err) => {
    if (err) throw err;
  });
  console.log("Deploy token : " + token.address);

  const Master = await ethers.getContractFactory("MasterChef");
  const master = await Master.deploy(token.address, thunderPerBlock, currentBlock);
  await master.deployed();
  fs.writeFile(__dirname + "/sources/masterAddress", master.address, (err) => {
    if (err) throw err;
  });
  console.log("Deploy master : " + master.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
