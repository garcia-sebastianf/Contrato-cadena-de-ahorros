// We require the Hardhat Runtime Environment explicity here. This is optional
//but useful for running the script in a standalone fashion through `<scripts>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.

const hre = require("hardhat");

async function main() {

    const SimpleContractFactory = await hre.ethers.getContractFactory("ContratoCadena");
    const contratoCadena = await SimpleContractFactory.deploy();

    await contratoCadena.waitForDeployment();

    const contractAddress = await contratoCadena.getAddress();

    console.log("Contract deployed to", contractAddress);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});