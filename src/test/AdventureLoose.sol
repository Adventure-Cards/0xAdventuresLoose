// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./utils/AdventureLooseSetup.sol";
import "./utils/AdventureAirdrop.sol";
import { IAdventureAirdrop } from "../AdventureLoose.sol";
import { ItemIds } from "../AdventureTokensMetadata.sol";

contract ERC721Callback is AdventureLooseTest {
    function testCannotCallOnERC721ReceivedDirectly() public {
        try
            acLoose.onERC721Received(address(0), address(0), 0, "0x")
        {} catch Error(string memory error) {
            assertEq(error, Errors.IsNotAdventureCards);
        }
    }
}

contract Open is AdventureLooseTest {
    function testCanOpenBag() public {
        alice.open(BAG);
        assertEq(ac.ownerOf(BAG), address(acLoose));
    }

    function testCanOpenBagWithApproval() public {
        alice.openWithApproval(BAG);
        assertEq(ac.ownerOf(BAG), address(acLoose));
        checkOwns1155s(BAG, address(alice));
    }

    function testFailCannotOpenBagYouDoNotOwn() public {
        alice.open(OTHER_BAG);
    }

    // helper for checking ownership of erc1155 tokens after unbundling a bag
    function checkOwns1155s(uint256 tokenId, address who) private {
        ItemIds memory ids = acLoose.ids(tokenId);
        assertEq(acLoose.balanceOf(who, ids.weapon), 1);
        assertEq(acLoose.balanceOf(who, ids.chest), 1);
        assertEq(acLoose.balanceOf(who, ids.head), 1);
        assertEq(acLoose.balanceOf(who, ids.waist), 1);
        assertEq(acLoose.balanceOf(who, ids.foot), 1);
        assertEq(acLoose.balanceOf(who, ids.hand), 1);
        assertEq(acLoose.balanceOf(who, ids.neck), 1);
        assertEq(acLoose.balanceOf(who, ids.ring), 1);
    }
}

contract Reassemble is AdventureLooseTest {
    AdventureLooseUser internal bob;

    function setUp() public override {
        super.setUp();

        bob = new AdventureLooseUser(ac, acLoose);
        bob.claim(OTHER_BAG);
        bob.open(OTHER_BAG);

        alice.open(BAG);
    }

    // Reassembling does not require `setsApprovalForAll`
    function testCanReassemble() public {
        alice.reassemble(BAG);
        assertEq(ac.ownerOf(BAG), address(alice));

        bob.reassemble(OTHER_BAG);
        assertEq(ac.ownerOf(OTHER_BAG), address(bob));
    }

    function testCannotReassembleBagYouDoNotOwn() public {
        try alice.reassemble(OTHER_BAG) { fail(); } catch Error(string memory error) {
            assertEq(error, "ERC1155: burn amount exceeds balance");
        }
    }

    function testCannotReassembleWithoutOwningAllPieces() public {
        uint256 id = acLoose.weaponId(BAG);
        alice.transferERC1155(address(bob), id, 1);
        try alice.reassemble(BAG) { fail(); } catch Error(string memory error) {
            assertEq(error, "ERC1155: burn amount exceeds balance");
        }
    }
}

contract Airdrop is AdventureLooseTest {
    AdventureAirdrop airdrop;

    function setUp() public override {
        super.setUp();
        airdrop = new AdventureAirdrop(address(ac));
        alice.open(BAG);
    }

    function testCanClaimAirdropForAdventureLoose() public {
        acLoose.claimAirdropForAdventureLoose{value: 1 ether}(
            IAdventureAirdrop(address(airdrop)),
            BAG
        );
        assertEq(airdrop.ownerOf(BAG), address(acLoose));
    }

    function testCanClaimAirdrop() public {
        acLoose.claimAirdropForAdventureLoose{value: 1 ether}(
            IAdventureAirdrop(address(airdrop)),
            BAG
        );
        alice.reassemble(BAG);
        alice.claimAirdrop(address(airdrop), BAG);
        assertEq(airdrop.ownerOf(BAG), address(alice));
    }

    function testCannotClaimAirdropIfNotOwner() public {
        acLoose.claimAirdropForAdventureLoose{value: 1 ether}(
            IAdventureAirdrop(address(airdrop)),
            BAG
        );

        try alice.claimAirdrop(address(airdrop), BAG) { fail(); } catch Error(
            string memory error
        ) {
            assertEq(error, Errors.DoesNotOwnTheAdventureDeck);
        }
    }

    function testCannotClaimAirdropWithoutEnoughMoney() public {
        try
            acLoose.claimAirdropForAdventureLoose{value: 0.8 ether}(
                IAdventureAirdrop(address(airdrop)),
                BAG
            )
        {} catch Error(string memory error) {
            assertEq(error, "pay up");
        }
    }

    function testCannotClaimAirdropForUnopenedBags() public {
        alice.claim(OTHER_BAG);
        try
            acLoose.claimAirdropForAdventureLoose{value: 1 ether}(
                IAdventureAirdrop(address(airdrop)),
                OTHER_BAG
            )
        {} catch Error(string memory error) {
            assertEq(error, "you must own the bag");
        }
    }
}
