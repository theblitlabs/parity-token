import { ethers } from "hardhat";
import * as fs from "fs";
import * as path from "path";
import { Wallet } from "ethers";

async function main() {
  // Initial supply of 1 million tokens
  const initialSupply = 1_000_000;

  console.log("Deploying ParityToken contract...");

  const ParityToken = await ethers.getContractFactory("ParityToken");
  const token = await ParityToken.deploy(initialSupply);
  await token.waitForDeployment();

  const address = await token.getAddress();
  console.log(`ParityToken deployed to: ${address}`);

  // Update .env file
  const envPath = path.join(__dirname, "..", ".env");
  const envContent = fs.readFileSync(envPath, "utf-8");
  const updatedEnv = envContent.replace(
    /CONTRACT_ADDRESS=.*/,
    `CONTRACT_ADDRESS=${address}`
  );
  fs.writeFileSync(envPath, updatedEnv);
  console.log("Updated .env with new contract address");

  // Log some initial details
  const [deployer] = await ethers.getSigners();
  console.log(`Deployer address: ${deployer.address}`);
  const deployerBalance = await token.balanceOf(deployer.address);
  console.log(`Initial supply: ${initialSupply} PRTY`);
  console.log(`Deployer balance: ${deployerBalance} wei`);

  // Only verify deployer address matches private key on non-Hardhat networks
  const network = await ethers.provider.getNetwork();
  if (network.name !== "hardhat" && process.env.PRIVATE_KEY) {
    const expectedAddress = new Wallet(process.env.PRIVATE_KEY).address;
    if (deployer.address !== expectedAddress) {
      throw new Error("Configured private key does not match deployer address");
    }
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
