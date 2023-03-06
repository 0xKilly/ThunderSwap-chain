async function main() {

  const [owner] = await ethers.getSigners();
  const feeTo = "0x000000000000000000000000000000000000dead";
  const WETH = "0x000000000000000000000000000000000000dead";

  const ThunderFactory = await ethers.getContractFactory("ThunderFactory");
  const factory = await ThunderFactory.deploy(feeTo);
  await factory.deployed();
  console.log("Deploy factory : " + factory.address);

  const ThunderRouter = await ethers.getContractFactory("ThunderRouter");
  const router = await ThunderRouter.deploy(factory.address, WETH);
  await router.deployed();
  console.log("Deploy router : " + router.address);

  const ThunderZapV1 = await ethers.getContractFactory("ThunderZapV1");
  const zap = await ThunderZapV1.deploy(WETH, router.address, 10);
  await zap.deployed();
  console.log("Deploy zap : " + zap.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
