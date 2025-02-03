import { ethers } from "hardhat";

async function main() {
  const tokenAddress = process.env.CONTRACT_ADDRESS;
  if (!tokenAddress) throw new Error("CONTRACT_ADDRESS not set in .env");
  const token = await ethers.getContractAt("ParityToken", tokenAddress);

  const [deployer] = await ethers.getSigners();
  const deployerAddress = deployer.address;
  const recipientAddress = "0x01b7b2bC30c958bA3bC0852bF1BD4efB165281Ba";

  const deployerBalance = await token.balanceOf(deployerAddress);
  const recipientBalance = await token.balanceOf(recipientAddress);

  console.log("Token Balances:");
  console.log(
    `Deployer (${deployerAddress}): ${ethers.formatUnits(
      deployerBalance,
      18
    )} PRTY`
  );
  console.log(
    `Recipient (${recipientAddress}): ${ethers.formatUnits(
      recipientBalance,
      18
    )} PRTY`
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
