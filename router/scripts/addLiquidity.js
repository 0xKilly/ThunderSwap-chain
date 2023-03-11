const {Contract} = require('ethers');

async function main() {

    const [owner] = await ethers.getSigners();

    const tokenAddress = "0x29011c897794620dC75ADdcafA0E2B792e895Ad6";
    const tokenABI = require("../../masterchef/abis/contracts/ThunderToken.sol/ThunderToken.json");
    const token = new Contract(tokenAddress, tokenABI, owner);

    const routerAddress = "0x4C22BD8010738c48cA03B5CAB58212bF8E8Ab0bf";
    const routerABI = require("../../router/abis/contracts/ThunderRouter.sol/ThunderRouter.json");
    const router = new Contract(routerAddress, routerABI, owner);

    // Approve
    await token.approve(routerAddress, ethers.utils.parseEther("1000"));

    // Add liquidity
    await router.addLiquidityETH(
        tokenAddress,
        ethers.utils.parseEther("1000"),
        0,
        0,
        owner.address,
        9999999999999,
        {value: ethers.utils.parseEther("1")}
    )
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});