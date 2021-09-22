// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract AdventureAirdrop is ERC721 {
    IERC721 immutable ac;

    constructor(address _adventure) ERC721("Test", "TST") {
        ac = IERC721(_adventure);
    }

    function claimForAdventure(uint256 tokenId) external payable {
        require(msg.value >= 1 ether, "pay up");
        require(ac.ownerOf(tokenId) == msg.sender, "you must own the cards");
        _mint(msg.sender, tokenId);
    }
}
