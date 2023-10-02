const hre = require("hardhat"); //importing hardhat 

//reads the environment variables of the VRF 
const vrfCoordinatorV2Address = process.env.VRFaddress;
const subId = process.env.SubId;
const keyHash = process.env.keyHash;
const callbackGasLimit = process.env.gasLimit;

//the main function to deploy the contract 
async function main() {

    //with the await const HogwartsNFT = hre.ethers.getContractFactory("nameOfContract") it deploys the contract and assignes it to the variable as an object 
    console.log("Deploying the NFTHogwarts contract...")//message that the contract was deployed 
    //deploy the contract 
    const HogwartsNFT = await hre.ethers.getContractFactory("HogwartsNFT");
    const hogwartsNFT = await HogwartsNFT.deploy(); //using Hardhat to create factory for the HogwartNFT and then deplying it 

    let currentBlock = await hre.ethers.provider.getBlockNumber();
    //retrieves the current block number and waits for 5 additional blocks to be mined before proceeding. Often done.    
    while (currentBlock + 5 > (await hre.ethers.provider.getBlockNumber())) { }

    //obtains the Ethereum address of the deployed Hogwarts NFT contract and logs it.
    const hogwartsAddress = await hogwartsNFT.getAddress();
    console.log("Hogwarts NFT deployed to:", hogwartsAddress);

    console.log("Deploying Random House Assignment Contract...");
    // Deploying Random House Assignment contract
    const RandomHouse = await hre.ethers.getContractFactory("RandomHouseAssignment");
    const randomHouse = await RandomHouse.deploy(hogwartsAddress, vrfCoordinatorV2Address, subId, keyHash, callbackGasLimit);
    while (currentBlock + 5 > (await hre.ethers.provider.getBlockNumber())) { } //just to wait to deploy the contract 5 blocks 

    const randomAddress = await randomHouse.getAddress();//getting the contract address but for the randomHouseAssignement
    console.log("Random House Assignment deployed to:", randomAddress);

    // Transferring ownership
    await hogwartsNFT.transferOwnership(randomAddress);
    console.log("Ownership transferred");
}

//calling the main function to esecute it 
main();



