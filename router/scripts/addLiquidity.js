const {Contract} = require('ethers');

async function main() {

    const [owner] = await ethers.getSigners();

    const tokenAddress = "0x2F6E2e4E6e7D840728D09F9ccA7d7c257bbAE679";
    const tokenABI = require("../../masterchef/abis/contracts/ThunderToken.sol/ThunderToken.json");
    const token = new Contract(tokenAddress, tokenABI, owner);

    const routerAddress = "0x88D79346030D4dEdF6558BA0949D61e660d04e25";
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