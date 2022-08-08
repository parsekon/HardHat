const hre = require('hardhat');

async function main() {
    // We get the contract to deploy
    const MyToken = await ethers.getContractFactory("MyToken");
    const myToken = await MyToken.deploy();
  
    console.log("MyToken:", myToken.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });