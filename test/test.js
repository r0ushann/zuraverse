const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Seed", function () {
  let Seed;
  let Tree;
  let seedContract;
  let treeContract;
  let owner;
  let addr1;
  let addr2;

  beforeEach(async function () {
    Seed = await ethers.getContractFactory("Seed");
    Tree = await ethers.getContractFactory("Tree");
    [owner, addr1, addr2] = await ethers.getSigners();

    seedContract = await Seed.deploy(Tree.address);
    await seedContract.deployed();

    treeContract = await Tree.deploy(seedContract.address);
    await treeContract.deployed();
  });

  it("should plant and grow the seed into a tree", async function () {
    // Plant the seed
    await seedContract.connect(addr1).plantTheSeed();

    // Wait for growth duration
    await ethers.provider.send("evm_increaseTime", [2 * 24 * 60 * 60]); // Increase time by 2 days
    await ethers.provider.send("evm_mine");

    // Add water
    await seedContract.connect(addr1).addWater(0);

    // Check if sapling is grown
    expect(await seedContract.isSapling(0)).to.equal(true);

    // Wait for tree generation duration
    await ethers.provider.send("evm_increaseTime", [13 * 24 * 60 * 60]); // Increase time by 13 days
    await ethers.provider.send("evm_mine");

    // Add water
    await seedContract.connect(addr1).addWater(0);

    // Check if tree is generated
    expect(await seedContract.isTree(0)).to.equal(true);

    // Mint the tree NFT
    await treeContract.connect(addr1).safeMint(addr1.address);

    // Check if the tree NFT is owned by addr1
    expect(await treeContract.ownerOf(0)).to.equal(addr1.address);
  });

  it("should fail to add water if not the owner", async function () {
    // Plant the seed
    await seedContract.connect(addr1).plantTheSeed();

    // Wait for growth duration
    await ethers.provider.send("evm_increaseTime", [2 * 24 * 60 * 60]); // Increase time by 2 days
    await ethers.provider.send("evm_mine");

    // Add water with a different address (not the owner)
    await expect(seedContract.connect(addr2).addWater(0)).to.be.revertedWith(
      "Not the owner"
    );
  });
});
