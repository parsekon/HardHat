const hre = require('hardhat');
const ethers = hre.ethers;

async function main() {
    const accountAddr = '0x14dC79964da2C08b23698B3D3cc7Ca32193d9955'
    let signer = ethers.provider.getSigner(accountAddr)
    const Wallet = await ethers.getContractFactory('Wallet', signer)
    const wallet = await Wallet.deploy()
    await wallet.deployed()

    console.log("Wallet address (contract):", wallet.address)
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });