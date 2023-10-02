pragma solidity ^0.8.8;

import "./HogwartsNFT.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract RandomHouseAssignment is
    VRFConsumerBaseV2 //inherits from VRFConsumerBaseV2, randomly assigns houses to users
{
    HogwartsNFT public nftContract; //NFT contract from the HogwartsNFT.sol
    VRFCoordinatorV2Interface private i_vrfCoordinator; // interface to the Chainlink VRF coordinator
    uint64 private i_subscriptionId; //subscription id from Chainlink VRF
    bytes32 private i_keyHash; //to generate random numbers
    uint32 private i_callbackGasLimit;
    mapping(uint256 => address) private s_requestIdToSender; //mapping to associate the request numebr with the request's sender id
    mapping(address => string) private s_nameToSender; //link sender name with address

    event NftRequested(uint256 indexed reuqestId, address requester);

    constructor(
        address _nftContract,
        address vrfCoordinatorV2Address, //calls the parent contract VRFConsumerBaseV2
        uint subId,
        bytes32 keyHash,
        uint32 callbackgasLimit
    ) VRFConsumerBaseV2(vrfCoordinatorV2Address) {
        //the parent contract called
        nftContract = HogwartsNFT(_nftContract);
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2Address);
        i_subscriptionId = subId;
        i_keyHash = keyHash;
        i_callbackGasLimit = callbackGasLimit;
    }

    function requestNFT(string memory name) public {
        //request to the CHainlink VRF to request random words
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_keyHash,
            i_subscriptionId,
            3, //number of random words to request
            i_callbackGasLimit, //gas limit for callback function
            1 //userProvidedSeed 
        );

        s_requestIdToSender[requestId] = msg.sender;
        s_nameToSender[msg.sender] = name;
        emit NftRequested(requestId, msg.sender);
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        address nftOwner = s_requestIdToSender[requestId]; //retrieving the nftOwner address using the s_requestIdToSender's requestId
        string memory name = s_nameToSender[nftOwner]; // retrieving teh name associated to the NFt owner from the mapping 
        uint256 house = randomWords[0] % 4; //getting the first random word
        nftContract.mintNFT(nftOwner, house, name);
    }
}
