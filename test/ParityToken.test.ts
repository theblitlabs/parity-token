import { expect } from "chai";
import { ethers } from "hardhat";
import { Signer } from "ethers";

describe("ParityToken", function () {
  let token: any;
  let owner: Signer;
  let addr1: Signer;
  let addr2: Signer;

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();
    const ParityToken = await ethers.getContractFactory("ParityToken");
    token = await ParityToken.deploy(ethers.parseEther("1000"));
  });

  describe("Deployment", function () {
    it("Should assign initial supply to deployer", async function () {
      const ownerBalance = await token.balanceOf(await owner.getAddress());
      expect(ownerBalance).to.equal(ethers.parseEther("1000"));
    });

    it("Should set correct token metadata", async function () {
      expect(await token.name()).to.equal("Parity Token");
      expect(await token.symbol()).to.equal("PRTY");
      expect(await token.decimals()).to.equal(18);
    });
  });

  describe("Transfers", function () {
    it("Should transfer tokens between accounts", async function () {
      await token.transfer(await addr1.getAddress(), ethers.parseEther("100"));
      const addr1Balance = await token.balanceOf(await addr1.getAddress());
      expect(addr1Balance).to.equal(ethers.parseEther("100"));
    });

    it("Should fail if sender has insufficient balance", async function () {
      await expect(token.connect(addr1).transfer(await owner.getAddress(), 1))
        .to.be.reverted;
    });
  });

  describe("Approvals", function () {
    it("Should set allowance correctly", async function () {
      await token.approve(await addr1.getAddress(), 100);
      const allowance = await token.allowance(
        await owner.getAddress(),
        await addr1.getAddress()
      );
      expect(allowance).to.equal(100);
    });
  });

  describe("Minting", function () {
    it("Should allow anyone to mint tokens (vulnerability)", async function () {
      await token.connect(addr1).mint(await addr1.getAddress(), 100);
      const newSupply = await token.totalSupply();
      expect(newSupply).to.equal(ethers.parseEther("1000") + 100n);
    });
  });

  describe("Burning", function () {
    it("Should burn tokens correctly", async function () {
      const initialBalance = await token.balanceOf(await owner.getAddress());
      await token.burn(ethers.parseEther("100"));
      expect(await token.totalSupply()).to.equal(ethers.parseEther("900"));
    });
  });

  describe("Data Transfers", function () {
    it("Should handle transferWithDataAndCallback", async function () {
      const MockCallback = await ethers.getContractFactory("MockCallback");
      const mock = await MockCallback.deploy();

      await token.transferWithDataAndCallback(
        mock.target,
        100,
        mock.interface.encodeFunctionData("mockFunction")
      );

      expect(await mock.callCount()).to.equal(1);
    });
  });

  describe("Edge Cases", function () {
    it("Should handle zero-value transfers", async function () {
      await expect(token.transfer(await addr1.getAddress(), 0))
        .to.emit(token, "Transfer")
        .withArgs(await owner.getAddress(), await addr1.getAddress(), 0);
    });

    it("Should prevent transfers to zero address", async function () {
      await expect(token.transfer(ethers.ZeroAddress, 1)).to.be.reverted;
    });
  });
});
