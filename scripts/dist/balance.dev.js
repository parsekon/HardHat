"use strict";

var hre = require('hardhat');

var ethers = hre.ethers;

function main() {
  var provider, sender, signer, balance;
  return regeneratorRuntime.async(function main$(_context) {
    while (1) {
      switch (_context.prev = _context.next) {
        case 0:
          provider = ethers.provider;
          sender = "0xdD2FD4581271e230360230F9337D5c0430Bf44C0";
          signer = provider.getSigner(sender);
          _context.next = 5;
          return regeneratorRuntime.awrap(signer.getBalance());

        case 5:
          balance = _context.sent;
          console.log(ethers.utils.formatEther(balance));

        case 7:
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