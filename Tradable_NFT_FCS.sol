// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TradableNFTFCS is ERC721, Ownable {
    using Strings for uint256;

    // maximum number of tokens that can be minted
    uint256 public constant MAX_MINTABLE_TOKENS = 10000;
    // maximum number of tokens that can be minted per transaction
    uint256 public constant MAX_MINTABLE_TOKENS_PER_TX = 10;
    // maximum number of tokens that can be minted per wallet
    uint256 public constant MAX_MINTABLE_TOKENS_PER_WALLET = 10;

    // price of NFT = 0.01 ether
    uint256 public nftPrice = 1e16;
    // can NFT be minted right now
    bool public canMint = false;
    // number of tokens currently in circulation
    uint256 public numTokensMinted = 0;
    // number of tokens possessed by each individual
    mapping(address => uint256) private tokensPossessed;
    // ipfs uri of the NFT metadata
    string public ipfsUri = "";
    // ipfs extension for the NFT
    string public ipfsExtension = ".json";

    constructor() ERC721("", "")Ownable(msg.sender) {}

    function mintNft(uint256 _numTokens) external payable {
        require(canMint, "Cannot mint right now!! Sorry for the inconvenience :)");
        require(numTokensMinted + _numTokens <= MAX_MINTABLE_TOKENS, "This exceeds the maximum number of tokens in circulation!!");
        require(tokensPossessed[msg.sender] + _numTokens <= MAX_MINTABLE_TOKENS_PER_WALLET, "Thou cannot possess these many tokens of this NFT!!");
        require(_numTokens <= MAX_MINTABLE_TOKENS_PER_WALLET, "Thou cannot buy these many tokens in one transaction!!");
        require(nftPrice * _numTokens <= msg.value, "Insufficient funds!!");
        
        uint256 currentTokensMinted = numTokensMinted;
        for (uint256 i = 0; i < _numTokens; ++i) {
            _safeMint(msg.sender, currentTokensMinted + i);
        }
        tokensPossessed[msg.sender] += _numTokens;
        numTokensMinted += _numTokens;
    }
        
    function transferNFT(address to, uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "Thou art not the owner of this NFT X(");
        safeTransferFrom(msg.sender, to, tokenId);
        tokensPossessed[to] += 1;
        tokensPossessed[msg.sender] -= 1;
    }

    function tradeNFT(address user1, uint256 tokenId1, address user2, uint256 tokenId2) external {
        require(ownerOf(tokenId1) == user1, "User1 is not the owner of NFT1");
        require(ownerOf(tokenId2) == user2, "User2 is not the owner of NFT2");
        safeTransferFrom(user1, user2, tokenId1);
        safeTransferFrom(user2, user1, tokenId2);
    }


    function setIpfsUri(string memory _ipfsUri) external onlyOwner {
        ipfsUri = _ipfsUri;
    }

    function setNftPrice(uint256 _nftPrice) external onlyOwner {
        nftPrice = _nftPrice;
    }

    function toggleCanMintState() external onlyOwner {
        canMint = !canMint;
    }
}