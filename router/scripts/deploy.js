async function main() {

  const [owner] = await ethers.getSigners();
  const feeTo = owner.address;
  const weth = "0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6";
  // mainnet 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
  // goerli 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6

  const ThunderFactory = await ethers.getContractFactory("ThunderFactory");
  const factory = await ThunderFactory.deploy(feeTo);
  await factory.deployed();
  console.log("Deploy factory : " + factory.address);

  const ThunderRouter = await ethers.getContractFactory("ThunderRouter");
  const router = await ThunderRouter.deploy(factory.address, weth);
  await router.deployed();
  console.log("Deploy router : " + router.address);

  const ThunderZapV1 = await ethers.getContractFactory("ThunderZapV1");
  const zap = await ThunderZapV1.deploy(weth, router.address, 10);
  await zap.deployed();
  console.log("Deploy zap : " + zap.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
