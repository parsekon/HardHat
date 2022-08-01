const hre = require('hardhat');

async function main() {
    // We get the contract to deploy
    const IterMapping = await ethers.getContractFactory("IterMapping");
    const iterMapping = await IterMapping.deploy();
  
    console.log("IterMapping:", iterMapping.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });