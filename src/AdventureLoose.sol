//SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

// ============ Imports ============

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

import "./AdventureTokensMetadata.sol";

interface ILootAirdrop {
    function claimForLoot(uint256) external payable;

    function safeTransferFrom(
        address,
        address,
        uint256
    ) external payable;
}

library Errors {
    string constant DoesNotOwnTheAdventureDeck =
        "you do not own the adventure cards deck for this airdrop";
    string constant IsNotAdventureCards = "msg.sender is not the Adventure Cards contract";
}

/// @title Adventure Tokens
/// @author Georgios Konstantopoulos
/// @author Andreas Bigger
/// @notice Allows unbundling your ERC721 Adventure Decks and extracting the items inside it
/// The created tokens are ERC1155 compatible, and their on-chain SVG is their name
contract AdventureLoose is ERC1155, AdventureTokensMetadata {
    // The OG Adventure Cards contract
    IERC721 immutable ac;

    // No need for a URI since we're doing everything onchain
    constructor(address _loot) ERC1155("") {
        ac = IERC721(_loot);
    }

    /// @notice Transfers the erc721 bag from your account to the contract and then
    /// opens it. Use it if you have already approved the transfer, else consider
    /// just transferring directly to the contract and letting the `onERC721Received`
    /// do its part
    function open(uint256 tokenId) external {
        ac.safeTransferFrom(msg.sender, address(this), tokenId);
    }

    /// @notice Claims an airdrop for a token owned by LootLoose. The airdrop is then
    /// claimable by the owner of the reassembled pieces.
    function claimAirdropForLootLoose(ILootAirdrop airdrop, uint256 tokenId)
        external
        payable
    {
        airdrop.claimForLoot{value: msg.value}(tokenId);
    }

    /// @notice Allows you to claim an airdrop that has already been claimed by LootLoose
    /// if you are the owner of the ERC721 bag the airdrop corresponds to
    function claimAirdrop(ILootAirdrop airdrop, uint256 tokenId) external {
        require(ac.ownerOf(tokenId) == msg.sender, Errors.DoesNotOwnTheAdventureDeck);
        airdrop.safeTransferFrom(address(this), msg.sender, tokenId);
    }

    /// @notice ERC721 callback which will unbundle the deck
    function onERC721Received(
        address,
        address from,
        uint256 tokenId,
        bytes calldata
    ) external returns (bytes4) {
        // only supports callback from the Adventure Cards contract
        require(msg.sender == address(ac), Errors.IsNotAdventureCards);
        unbundle(from, tokenId);
        return LootLoose.onERC721Received.selector;
    }

    /// @notice Unbundles your Adventure Cards Deck and mints you 45 ERC-1155 tokens for each item in that deck
    function unbundle(address who, uint256 tokenId) private {
        // NB: We patched ERC1155 to expose `_balances` so
        // that we can manually mint to a user, and manually emit a `TransferBatch`
        // event. If that's unsafe, we can fallback to using _mint
        uint256[] memory ids = new uint256[](8);
        uint256[] memory amounts = new uint256[](8);
        ids[0] = itemId(tokenId, weaponComponents, WEAPON);
        ids[1] = itemId(tokenId, chestComponents, CHEST);
        ids[2] = itemId(tokenId, headComponents, HEAD);
        ids[3] = itemId(tokenId, waistComponents, WAIST);
        ids[4] = itemId(tokenId, footComponents, FOOT);
        ids[5] = itemId(tokenId, handComponents, HAND);
        ids[6] = itemId(tokenId, neckComponents, NECK);
        ids[7] = itemId(tokenId, ringComponents, RING);
        for (uint256 i = 0; i < ids.length; i++) {
            amounts[i] = 1;
            // +21k per call / unavoidable - requires patching OZ
            _balances[ids[i]][who] += 1;
        }

        emit TransferBatch(_msgSender(), address(0), who, ids, amounts);
    }

    /// @notice Re-assembles the original Adventure Cards Deck by burning all the ERC1155 tokens
    /// which were inside of it. Because ERC1155 tokens are fungible, you can give it
    /// any token that matches the one that was originally in it (i.e. you don't need to
    /// give it the exact e.g. Divine Robe that was created during minting.
    function reassemble(uint256 tokenId) external {
        // 1. burn the items
        burnItem(tokenId, weaponComponents, WEAPON);
        burnItem(tokenId, chestComponents, CHEST);
        burnItem(tokenId, headComponents, HEAD);
        burnItem(tokenId, waistComponents, WAIST);
        burnItem(tokenId, footComponents, FOOT);
        burnItem(tokenId, handComponents, HAND);
        burnItem(tokenId, neckComponents, NECK);
        burnItem(tokenId, ringComponents, RING);

        // 2. give back the bag
        ac.safeTransferFrom(address(this), msg.sender, tokenId);
    }

    function itemId(
        uint256 tokenId,
        function(uint256) view returns (uint256[5] memory) componentsFn,
        uint256 itemType
    ) private view returns (uint256) {
        uint256[5] memory components = componentsFn(tokenId);
        return TokenId.toId(components, itemType);
    }

    /// @notice Extracts the components associated with the ERC721 Loot bag using
    /// dhof's LootComponents utils and proceeds to burn a token for the corresponding
    /// item from the msg.sender.
    function burnItem(
        uint256 tokenId,
        function(uint256) view returns (uint256[5] memory) componentsFn,
        uint256 itemType
    ) private {
        uint256[5] memory components = componentsFn(tokenId);
        uint256 id = TokenId.toId(components, itemType);
        _burn(msg.sender, id, 1);
    }

    function uri(uint256 tokenId) public view override returns (string memory) {
        return tokenURI(tokenId);
    }
}
