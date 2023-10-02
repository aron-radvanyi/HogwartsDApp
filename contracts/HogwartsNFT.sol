
/*
* Allows the owner to mint non-fungible tokens representing the four Hogwarts houses.
* Store NFTs on IPFS and associated them with a specific house.
* Make the tokens soulbound within the Hogwarts context.
*/

pragma solidity ^0.8.8;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

//the main contract 
contract HogwartsNFT is ERC721UriStorage, Ownable {
    //state variables 
    mapping(uint256 => address) public s_requestIdToSender;
    mapping(address => uint256) public s_addressToHouse;
    mapping(address => bool) public hasMinted; 
    mapping(address => string) public s_addToName; 

    uint256 private s_tokenCounter; 

    string[] internal houseTokenURIs  = [
        "ipfs://QmXja2QBKsNW9qnw9kKfcm25rJTomwAVJUrXekYFJnVwbg/Gryffindor.json",
        "ipfs://QmXja2QBKsNW9qnw9kKfcm25rJTomwAVJUrXekYFJnVwbg/Hufflepuff.json",
        "ipfs://QmXja2QBKsNW9qnw9kKfcm25rJTomwAVJUrXekYFJnVwbg/Ravenclaw.json",
        "ipfs://QmXja2QBKsNW9qnw9kKfcm25rJTomwAVJUrXekYFJnVwbg/Slytherin.json"
    ];

    //event to call NftMinted 
    event NftMinted(uint256 house, address minter, string name);

    //constructor to set the counter to 0 
    constructor() ERC721("Hogwarts NFT", "HP") {
        s_tokenCounter = 0;
    }

    //allows to check anyone that the user specific address has already minted an NFT 
    function hasMintedNFT(address _user) public view returns(bool){
        return hasMinted[_user];
    }

    //gets the house associated with the users address 
    function getHouseIndex(address _user) public view returns (uint256){
        return s_addressToHouse[_user];
    }

    function mintNFT(address recipientAddress, uint256 house, string memory name) external onlyOwner {
        //hasMinted is undecleared so !hasMinted will[recipientAddress] will return not Null if the address has an NFT minted to it 
        require(!hasMinted[recipientAddress],"You already have minted your house NFT"); //ensure the address is not minted before 

        uint256 tokenId = s_tokenCounter;
        _safeMint(recipientAddress,tokenId);
        _setTokenURI(tokenId, houseToken);

        s_addressToHouse[recipientAddress] = house; //mapping house to address
        s_addresToName[recipientAddress] = name; //mapping name to address
        
        s_tokenCounter +=1; //adding one to the counter 
        hasMinted[recipientAddress] = true; //changing the value in the mapping to true for the address

        emit NftMinted(house, recipientAddress, name);        
    }

    function _beforeTokenTransfer(address addressFrom, address addressTo, uint256 fisrtTokenId, uint256 batchSize) internal virtual override {
                super._beforeTokenTransfer(from , to, fisrtTokenId, batchSize );
                require(addressFrom == address(0) || addressTo == address(0), "Error! This is not allowed in Hogwarts!");
    }






}




