const {Contract} = require('ethers');

async function main() {

    const [owner] = await ethers.getSigners();

    const tokenAddress = "0x2F6E2e4E6e7D840728D09F9ccA7d7c257bbAE679";
    const tokenABI = require("../../masterchef/abis/contracts/ThunderToken.sol/ThunderToken.json");
    const token = new Contract(tokenAddress, tokenABI, owner);

    const masterchefAddress = "0xd17FC46a194b73e41b80c23cc00426bCe69BBcEa";
    const masterchefABI = require("../../masterchef/abis/contracts/MasterChef.sol/MasterChef.json");
    const masterchef = new Contract(masterchefAddress, masterchefABI, owner);

    const routerAddress = "0x88D79346030D4dEdF6558BA0949D61e660d04e25";
    const WETHAddress = "0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6";
    // mainnet 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
    // goerli 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6
/*
    // Set Owner
    await token.transferOwnership(masterchefAddress);

    // Set Router
    await masterchef.setRouter(routerAddress);

    // Set WETH
    await masterchef.setWETH(WETHAddress);

    // Set LiqProvider and Marketing
    await masterchef.setLiqProvider("0x000000000000000000000000000000000000dEaD");
    await masterchef.setMarketing("0x000000000000000000000000000000000000dEaD");

    // Approve
    await token.approve(masterchefAddress, ethers.utils.parseEther("100"));
*/
    // Stake 100
    await masterchef.deposit(0, ethers.utils.parseEther("100"));

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});