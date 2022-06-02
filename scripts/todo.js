const hre = require("hardhat");
const ethers = hre.ethers;

async function main() {
  const [deployer] = await ethers.getSigners();

  const TodoList = await ethers.getContractFactory("TodoList", deployer);
  const todo = await TodoList.deploy();
  await todo.deployed();
}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
