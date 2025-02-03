import { ethers } from "hardhat";

async function main() {
  const tokenAddress = process.env.CONTRACT_ADDRESS;
  if (!tokenAddress) throw new Error("CONTRACT_ADDRESS not set in .env");

  // Address to transfer tokens to
  const recipientAddress = "0x01b7b2bC30c958bA3bC0852bF1BD4efB165281Ba"; // Replace with your recipient address

  // Amount to transfer (e.g., 100 tokens)
  const amount = ethers.parseUnits("10000", 18); // 1000 tokens with 18 decimals

  console.log("Transferring tokens...");

  // Get the contract instance
  const token = await ethers.getContractAt("ParityToken", tokenAddress);

  // Transfer tokens
  const tx = await token.transfer(recipientAddress, amount);
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
