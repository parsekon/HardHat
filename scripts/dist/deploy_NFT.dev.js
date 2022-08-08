"use strict";

var hre = require('hardhat');

function main() {
  var MyToken, myToken;
  return regeneratorRuntime.async(function main$(_context) {
    while (1) {
      switch (_context.prev = _context.next) {
        case 0:
          _context.next = 2;
          return regeneratorRuntime.awrap(ethers.getContractFactory("MyToken"));

        case 2:
          MyToken = _context.sent;
          _context.next = 5;
          return regeneratorRuntime.awrap(MyToken.deploy());

        case 5:
          myToken = _context.sent;
          console.log("MyToken:", myToken.address);

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