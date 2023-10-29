// SPDX-License-Identifier: MIT License

// @title Non-transferable POAP NFT 
// https://twitter.com/0xSorcerers | https://github.com/Dark-Viper | https://t.me/Oxsorcerer | https://t.me/battousainakamoto | https://t.me/darcViper

pragma solidity ^0.8.17;

import "./ERC721Enumerable.sol";
import "abdk-libraries-solidity/ABDKMath64x64.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract BuidlersConnectAfrica is ERC721Enumerable, Ownable, ReentrancyGuard {        
        constructor(string memory _name, string memory _symbol, address _authority, address _newGuard) 
            ERC721(_name, _symbol)
        {
            authority = _authority;
            guard = _newGuard;
        }
    using Math for uint256;
    using ABDKMath64x64 for uint256;   

    uint256 COUNTER = 1;
    using Strings for uint256;
    string public baseURI;
    address private guard; 
    address public authority; 
    string public author = "0xSorcerer | Builders Connect ";
    bool public paused = false; 

    modifier onlyGuard() {
        require(msg.sender == guard, "Not authorized.");
        _;
    }

    modifier onlyAuthority() {
        require(msg.sender == authority, "Not authorized.");
        _;
    }

    struct Participant {
        string Event;
        uint256 ID;  
        string Type; 
        uint256 Date;   
    }

    //Arrays

    // Mapping
    mapping (uint256 => Participant) public participants;

    event Minted(string indexed _event, uint256 tokenId, string indexed _type, address indexed _address);

    function mint(string memory _event, string memory _type, uint256 _date, address[] calldata _addresses) external onlyAuthority {
        require(!paused, "Paused Contract");
        require(bytes(_event).length > 0, "Event is Not Named");
        require(bytes(_type).length > 0, "Participant Type is Not Classified");

        uint256 date;
        if (_date == 0) {
            date = block.timestamp;
        } else {
            date = _date;
        }
        // For i in Addresses array, create a new Participant and map it
         for (uint256 i = 0; i < _addresses.length; i++) {
        address wallet = _addresses[i];
        participants[COUNTER] = Participant({
            Event: _event,
            ID: COUNTER,
            Type: _type,
            Date: date});

        // Mint a token for each Participant
        uint256 tokenId = COUNTER;
        _mint(wallet, tokenId);
        
        emit Minted(_event, tokenId, _type, wallet);
        COUNTER++;
        }
    }
    
    function setDate(uint256 newDate) external onlyAuthority {
        for (uint256 i = 0; i <= totalSupply(); i++) {
            participants[i].Date = newDate;
        }
    }    

    function changeType(string memory _newType, uint256[] calldata _nfts) external onlyAuthority {
        for (uint256 i = 0; i < _nfts.length; i++) {
            participants[_nfts[i]].Type = _newType;
        }
    }

    
    function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
    }

    function updateBaseURI(string memory _newLink) external onlyAuthority() {
        baseURI = _newLink;
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
    require(_tokenId > 0 && _tokenId <= totalSupply(), "Not Found");
    return
      bytes(baseURI).length > 0
        ? string(abi.encodePacked(baseURI, _tokenId.toString(), ".json"))
        : "";
    }

    event Pause();
    function pause() public onlyGuard {
        require(!paused, "Contract already paused.");
        paused = true;
        emit Pause();
    }

    event Unpause();
    function unpause() public onlyGuard {
        require(paused, "Contract not paused.");
        paused = false;
        emit Unpause();
    } 

    function setAuthority (address _newAuthority) external onlyOwner {
        authority = _newAuthority;
    }

    function setGuard (address _newGuard) external onlyGuard {
        guard = _newGuard;
    }
}              
