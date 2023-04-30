const hre = require("hardhat");

async function main() {

  const Treasury = await hre.ethers.getContractFactory("Treasury");
  const treasury = await Treasury.deploy("0xF574063f6174B1f5336DAE61BA5A89df4DE399f6");

  await treasury.deployed();

  console.log("Treasury deployed to:", treasury.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
