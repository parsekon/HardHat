const hre = require('hardhat');
const walletArtifact = require('../artifacts/contracts/Wallet/Wallet.sol/Wallet.json')
const ethers = hre.ethers;

async function main() {
    const contractAddr = '0xef11D1c2aA48826D4c41e54ab82D1Ff5Ad8A64Ca'
    const accountAddr = '0x14dC79964da2C08b23698B3D3cc7Ca32193d9955'

    let signer = ethers.provider.getSigner(accountAddr)

    const contract = new ethers.Contract(contractAddr, walletArtifact.abi, signer)

    let contractBalance = await contract.getBallance()

    // console.log(ethers.utils.formatEther(contractBalance))

    // console.log(await contract.owner())

    // let amountInEther = ethers.utils.parseEther("2.0")

    // let tx = {
    //     to: contractAddr,
    //     value: amountInEther
    // }

    // result = await signer.sendTransaction(tx)

    // console.log(result)
    // console.log(await contract.withdraw(ethers.utils.parseEther("10.0")))

    // contractBalance = await contract.getBallance()

    const balance = await signer.getBalance()

    console.log(ethers.utils.formatEther(balance))

  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });