import { ethers } from "hardhat";

async function main() {
  // Get the deployer account
  const [deployer] = await ethers.getSigners();
  console.log(`Using deployer address: ${deployer.address}`);

  const tokenAddress = process.env.CONTRACT_ADDRESS;
  if (!tokenAddress) throw new Error("CONTRACT_ADDRESS not set in .env");

  const recipientAddress = process.env.ADDRESS;
  if (!recipientAddress) throw new Error("ADDRESS not provided");

  const amount = process.env.AMOUNT;
  if (!amount) throw new Error("AMOUNT not provided");
  const amountWei = ethers.parseUnits(amount, 18);

  // Get the contract instance with deployer
  const token = await ethers.getContractAt(
    "ParityToken",
    tokenAddress,
    deployer
  );

  // Check if deployer is owner
  const owner = await token.owner();
  if (owner !== deployer.address) {
    throw new Error("Deployer is not contract owner - cannot mint tokens");
  }

  // Mint tokens to deployer first
  console.log("Minting tokens to deployer...");
  const mintTx = await token.mint(deployer.address, amountWei);
  await mintTx.wait();

  console.log("Transferring tokens...");

  // Transfer tokens
  const tx = await token.transfer(recipientAddress, amountWei);
  await tx.wait();

  // Get balances
  const recipientBalance = await token.balanceOf(recipientAddress);
  console.log(`Transfer complete!`);
  console.log(
    `Recipient balance: ${ethers.formatUnits(recipientBalance, 18)} PRTY`
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
