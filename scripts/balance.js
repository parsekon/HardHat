const hre = require('hardhat');
const ethers = hre.ethers;

async function main() {
   const provider = ethers.provider;
   let sender = "0xdD2FD4581271e230360230F9337D5c0430Bf44C0";
   let signer = provider.getSigner(sender);
   const balance = await signer.getBalance();
   console.log(ethers.utils.formatEther(balance));
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });