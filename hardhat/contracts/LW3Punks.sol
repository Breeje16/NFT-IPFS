//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract LW3Punks is ERC721Enumerable, Ownable {
    using Strings for uint256;

    string _baseTokenURI;

    uint256 public _price = 0.01 ether;

    bool public _paused;

    uint256 public maxTokenIds = 10;

    uint256 public mintedTokenIds;

    modifier onlyWhenNotPaused() {
        require(!_paused, "Contract is paused");
        _;
    }

    constructor(string memory baseURI) ERC721("LW3Punks", "LW3PUNKS") {
        _baseTokenURI = baseURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function mint() public payable onlyWhenNotPaused {
        require(mintedTokenIds < maxTokenIds, "No more tokens left");
        require(msg.value >= _price, "Ether value sent is not correct");

        mintedTokenIds++;
        _safeMint(msg.sender, mintedTokenIds);
    }

    function tokenURI(uint256 tokenIds) public view virtual override returns (string memory) {
        require(_exists(tokenIds), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenIds.toString())) : "";
    }

    function setPaused(bool paused) public onlyOwner {
        _paused = paused;
    }

    function withdraw() public onlyOwner {
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    receive() external payable {}

    fallback() external payable {}
}