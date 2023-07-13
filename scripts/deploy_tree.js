async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("Deploying Tree and Seed contracts with the account:", deployer.address);
  
    const Seed = await ethers.getContractFactory("Seed");
    const seedContract = await Seed.deploy(Tree.address);
    await seedContract.deployed();
  
    console.log("Seed contract address:", seedContract.address);
  
    const Tree = await ethers.getContractFactory("Tree");
    const treeContract = await Tree.deploy(seedContract.address);
    await treeContract.deployed();
  
    console.log("Tree contract address:", treeContract.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
  