"use strict";

var hre = require('hardhat');

var walletArtifact = require('../artifacts/contracts/Wallet/Wallet.sol/Wallet.json');

var ethers = hre.ethers;

function main() {
  var contractAddr, accountAddr, signer, contract, contractBalance, balance;
  return regeneratorRuntime.async(function main$(_context) {
    while (1) {
      switch (_context.prev = _context.next) {
        case 0:
          contractAddr = '0xef11D1c2aA48826D4c41e54ab82D1Ff5Ad8A64Ca';
          accountAddr = '0x14dC79964da2C08b23698B3D3cc7Ca32193d9955';
          signer = ethers.provider.getSigner(accountAddr);
          contract = new ethers.Contract(contractAddr, walletArtifact.abi, signer);
          _context.next = 6;
          return regeneratorRuntime.awrap(contract.getBallance());

        case 6:
          contractBalance = _context.sent;
          _context.next = 9;
          return regeneratorRuntime.awrap(signer.getBalance());

        case 9:
          balance = _context.sent;
          console.log(ethers.utils.formatEther(balance));

        case 11:
        case "end":
          return _context.stop();
      }
    }
  });
}

main().then(function () {
  return process.exit(0);
})["catch"](function (error) {
  console.error(error);
  process.exit(1);
});