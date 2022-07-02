// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./ILosBears.sol";

contract HumanPalm is ERC721Enumerable, ERC721Pausable, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;

    uint256 constant public maxTokenIds = 1554;
    uint256 constant public maxDuringPresale = 3;
    uint256 constant public maxDuringSale = 9;

    bool public presaleStarted;

    uint256 public presaleEnded;

    Counters.Counter private _tokenIds;

    string private _defaultBaseURI;

    ILosBears private _losBears;

    event TokenMint(address indexed minter, uint256 firstId, uint256 lastId);

    constructor(string memory baseURI, address losBearsContract) ERC721("Human Palm", "PALM") {
        _defaultBaseURI = baseURI;
        _losBears = ILosBears(losBearsContract);
        _tokenIds.increment();
    }

    function mint(uint256 quantity) external whenNotPaused {
        uint256 tokenId = _tokenIds.current();
        uint256 balance = balanceOf(msg.sender);
        require(presaleStarted && block.timestamp >= presaleEnded, "Presale not ended yet");
        require((balance + quantity) <= maxDuringSale, "Exceed max per wallet");
        require((tokenId - 1) + quantity < maxTokenIds, "Exceed max supply");
        for (uint256 i = 0; i < quantity; i++) {
            _safeMint(msg.sender, tokenId + i);
            _tokenIds.increment();
        }
        emit TokenMint(msg.sender, tokenId, (tokenId - 1) + quantity);
    }

    function presaleMint(uint256 quantity) external whenNotPaused {
        uint256 tokenId = _tokenIds.current();
        uint256 balance = balanceOf(msg.sender);
        require(_losBears.balanceOf(msg.sender) > 0, "Not whitelisted");
        require(presaleStarted && block.timestamp < presaleEnded, "Presale ended or not started");
        require((balance + quantity) <= maxDuringPresale, "Exceed max per wallet during presale");
        require((tokenId - 1) + quantity < maxTokenIds, "Exceed max supply");
        for (uint256 i = 0; i < quantity; i++) {
            _safeMint(msg.sender, tokenId + i);
            _tokenIds.increment();
        }
        emit TokenMint(msg.sender, tokenId, (tokenId - 1) + quantity);
    }

    function startPresale() external onlyOwner {
        presaleStarted = true;
        presaleEnded = block.timestamp + 20 minutes;
    }

    function togglePause() external onlyOwner {
        paused() ? _pause() : _unpause();
    }

    function setBaseURI(string calldata newURI) external onlyOwner {
        _defaultBaseURI = newURI;
    }

    function _baseURI() internal view override(ERC721) returns (string memory) {
        return _defaultBaseURI;
    }

    function tokenURI(uint256 tokenId) public view override(ERC721) returns (string memory) {
        _requireMinted(tokenId);
        return string(abi.encodePacked(_baseURI(), tokenId.toString(), ".json"));
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable, ERC721Pausable) {
        ERC721Enumerable._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721Enumerable, ERC721) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}