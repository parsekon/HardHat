"use strict";

var hre = require('hardhat');

var ethers = hre.ethers;

function main() {
  var accountAddr, signer, Wallet, wallet;
  return regeneratorRuntime.async(function main$(_context) {
    while (1) {
      switch (_context.prev = _context.next) {
        case 0:
          accountAddr = '0x14dC79964da2C08b23698B3D3cc7Ca32193d9955';
          signer = ethers.provider.getSigner(accountAddr);
          _context.next = 4;
          return regeneratorRuntime.awrap(ethers.getContractFactory('Wallet', signer));

        case 4:
          Wallet = _context.sent;
          _context.next = 7;
          return regeneratorRuntime.awrap(Wallet.deploy());

        case 7:
          wallet = _context.sent;
          _context.next = 10;
          return regeneratorRuntime.awrap(wallet.deployed());

        case 10:
          console.log("Wallet address (contract):", wallet.address);

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