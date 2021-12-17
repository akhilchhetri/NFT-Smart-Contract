pragma solidity ^0.8.3;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract FactoryNFT is ERC721Enumerable, Ownable{
    using Strings for uint256;
    string public baseURI;
    string public baseExtension = ".json";
    string public notRevealedUri;
    uint256 public cost = 0.0005 ether;
    uint256 public maxSupply = 10000;
    // mint amount at once
    uint256 public maxMintAmount =1;
    // mint amount per address limit
    uint256 public nftPerAddressLimit =1;
    bool public paused = false;
    bool public revealed = false;
    bool public onlyWhiteListed= true;
    address[] public whiteListedAddress;
    mapping(address => uint256) public addressMintedBalance;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _initBaseURI,
        string memory _initNotRevealedUri
    )ERC721(_name, _symbol){
        setBaseURI(_initBaseURI);
        setNotRevealedURI(_initNotRevealedUri);
    }

    //  mint function
    function mint(uint256 _mintAmount) public payable{
        require(!paused, "This contract is paused");
        uint256 supply = totalSupply();
        require(_mintAmount > 0, "need to mint atleast 1 NFT");
        require(_mintAmount <= maxMintAmount, "Max mint amount exceeded");
        require(supply + _mintAmount <= maxSupply, "Max NFT limit exceeded");

        if(msg.sender !=owner()){
            if(onlyWhiteListed == true){
                require(isWhitelisted(msg.sender),"user wallet address is not whitelisted");
                // logic to restrict minting more than limit amount
                uint256 ownerTokenCount = addressMintedBalance[msg.sender];
                require(ownerTokenCount + _mintAmount <= nftPerAddressLimit, "Max NFT per address exceeded");
            }
            require(msg.value <= cost * _mintAmount, "Insufficient Funds");
        }

        for (uint256 i=1; i<=_mintAmount; i++){
            addressMintedBalance[msg.sender]++;
            _safeMint(msg.sender, supply + i);
        }
    }
    // isWhitelisted function
    // returns a boolean value
    // This is a view function that doesnot change the state
    function isWhitelisted(address _user) public view returns(bool) {
        for(uint256 i = 0; i < whiteListedAddress.length; i++) {
            if(whiteListedAddress[i] == _user){
                // return true if whitelisted arrary contains the user address
                return true;
            }
        }
        return false;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function walletOfOwner(address _owner) public view returns(uint256[] memory){
        // gives the token count of the owner address
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);

        for (uint256 i =0; i<ownerTokenCount; i++){
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);

        }
        return tokenIds;
    }
    
    // tokenURI
    function tokenURI(uint256 tokenId) public view virtual override returns(string memory){
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        if(revealed ==false){
            return notRevealedUri;
        }
        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0 ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension)) : "";
    }

    // only Owner
    function reveal() public onlyOwner {
        revealed = true;
    }

    // nft per address limit
    function setNftPerAddressLimit(uint256 _limit) public onlyOwner(){
        nftPerAddressLimit = _limit;
    }

    function setCost(uint256 _newCost) public onlyOwner(){
        cost = _newCost;
    }
    function setMaxMintAmount(uint256 _newMaxMintAmount) public onlyOwner(){
        maxMintAmount = _newMaxMintAmount;
    }

    function setBaseExtension(string memory _newBaseExtension) public onlyOwner(){
        baseExtension = _newBaseExtension;
    }


    function setOnlyWhiteListed(bool _state) public onlyOwner() {
        onlyWhiteListed = _state;
    }

    function setNotRevealedURI(string memory _notRevealedUri) public onlyOwner() {
        notRevealedUri = _notRevealedUri;
    }

    function pause(bool _state) public onlyOwner() {
        paused = _state;
    }

    function whitelistUsers(address[] calldata _users) public onlyOwner() {
        delete whiteListedAddress;
        whiteListedAddress = _users;
    }

    function withdraw() public payable onlyOwner() {
        (bool os,) = payable(owner()).call{value: address(this).balance}("");
        require(os);
    }
}


/**
    ["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4",
    "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2",
    "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db",
    "0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB",
    "0x617F2E2fD72FD9D5503197092aC168c91465E7f2"]
*/