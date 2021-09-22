// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import { Base64 } from "../../MetadataUtils.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract Card is ERC721Enumerable, ReentrancyGuard, Ownable {
    string[] private spellMagnifiers = [
        "Instant",
        "Mighty",
        "Dire",
        "Zealous",
        "Ardent",
        "Potent",
        "Urgent",
        "Empyrean",
        "Irate",
        "Clever"
    ];

    string[] private spellType = [
        "Solar",
        "Lunar",
        "Frigid",
        "Shimmering",
        "Gloom",
        "Apocalypse",
        "Corpse",
        "Cataclysmic",
        "Grim",
        "Necro",
        "Sorrow",
        "Victory",
        "Forged",
        "Miracle",
        "Nimble",
        "Hateful",
        "Chimeric",
        "Oblivion",
        "Nature",
        "Dark",
        "Life"
    ];

    string[] private spellNames = [
        "Lightning",
        "Stricken",
        "Revive",
        "Burst",
        "Tempest",
        "Assault",
        "Pandemonium",
        "Rage",
        "Sorrow",
        "Frost",
        "Hypnosis",
        "Vortex",
        "Ice",
        "Fire",
        "Fireball",
        "Wall",
        "Infuriate",
        "Invisibility",
        "Fury",
        "Frenzy",
        "Stun",
        "Heal",
        "Reanimate",
        "Freeze",
        "Burn",
        "Gravitation",
        "Gale",
        "Torment",
        "Maelstrom"
    ];

    string[] private artifactNames = [
        "Divine Robe",
        "Ghost Wand",
        "Scythe",
        "Staff",
        "Gauntlet",
        "Sword",
        "Bow",
        "Shield",
        "Helmet",
        "Boots",
        "Ring",
        "Amulet",
        "Belt",
        "Bracers",
        "Cloak",
        "Gloves",
        "Greaves",
        "Helm",
        "Pendant",
        "Potion",
        "Scepter",
        "Sigil",
        "Tome",
        "Crown",
        "Ring"
    ];

    string[] private enchantmentNames = [
        "Strength",
        "Flight",
        "Shade",
        "Deathgrip",
        "Shield",
        "Drain",
        "Agony",
        "Firebreath",
        "Blight",
        "Lethargy",
        "Shrink",
        "Invert",
        "Age",
        "Alacrity",
        "Haste"
    ];

    string[] private commonCreature = [
        "Spider",
        "Warlock",
        "Magi",
        "Skin-Walker",
        "Paladin",
        "Berserker",
        "Fairy",
        "Troll",
        "Wolf",
        "Ghoul",
        "Eagle"
    ];

    string[] private rareCreature = ["Goblin", "Orc", "Griffin", "Kraken", "Cyclops", "Hydra"];

    string[] private legendaryCreature = ["Elf", "Dwarf", "Ogre", "Giant", "Oni"];

    string[] private mythicCreature = ["Dragon", "Wizard", "Phoenix", "Demon"];

    string[] private creatureModifiers = [
        "Knight",
        "King",
        "Queen",
        "Lord",
        "Rogue",
        "Undead",
        "Merchant",
        "Thief",
        "Assassin",
        "Fighter",
        "Warrior",
        "Monk",
        "Priest"
    ];

    string[] private mythicCreatureModifiers = ["Nameless", "Chaos", "Time", "Grand", "Undead", "Ancient"];

    string[] private nameModifiers = ["Aura", "Light", "Snow", "Dark", "Death", "Earth", "Frozen"];

    string[] private locations = [
        "of the West",
        "of the Plains",
        "of the Swamp",
        "of the Low Hills",
        "of the Border",
        "of the Bright Mountains",
        "of the Polar Woods",
        "of the Golden Palace",
        "of the Eastern Skies",
        "of the Haven",
        "of the Black Stone",
        "of the Frozen Castle",
        "of the Magical Forest",
        "of the Eternal Land",
        "of the Arctic Blizzards",
        "of the Mountains"
    ];

    string[] private mythicLocations = [
        "of the Light",
        "of the Sky",
        "of Hate",
        "of Illusion",
        "of the Dead",
        "of the Shadows",
        "of the Void"
    ];

    string private _tokenBaseURI = "https://0xAdventures.com/";
    bool public frozen = false;

    function freezeBaseURI() public onlyOwner {
        frozen = true;
    }

    function _baseURI() internal view override returns (string memory) {
        return _tokenBaseURI;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        require(!frozen, "Contract is frozen.");
        _tokenBaseURI = baseURI;
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function getCardTitle(uint256 tokenId, uint256 offset) public view returns (string memory) {
        // require(tokenId <= MAX_MINT, "only 8000 can be minted");
        require(offset < 45, "only 45 card titles per deck");

        uint256 cardRand = random(string(abi.encodePacked(toString(tokenId), toString(offset))));
        uint256 deckRarity = random(string(abi.encodePacked(toString(tokenId))));

        uint8 cardQuality = 3;
        string[] memory monsterArray = mythicCreature;

        uint8 level1 = 20;
        uint8 level2 = (20 + 12);
        uint8 level3 = (20 + 12 + 4);

        if (deckRarity % 40 < 23) {
            level1 = 30;
            level2 = (30 + 9);
            level3 = (30 + 9 + 4);
        } else if (deckRarity % 40 < 37) {
            level1 = 25;
            level2 = (25 + 12);
            level3 = (25 + 12 + 5);
        }

        if (cardRand % 45 < level1) {
            cardQuality = 0;
            monsterArray = commonCreature;
        } else if (cardRand % 45 < level2) {
            cardQuality = 1;
            monsterArray = rareCreature;
        } else if (cardRand % 45 < level3) {
            cardQuality = 2;
            monsterArray = legendaryCreature;
        }

        if (cardRand % 10 < 5) {
            return pluckCreature(tokenId, "MONSTER", monsterArray, offset, cardQuality);
        } else if (cardRand % 10 < 6) {
            return pluckOther(tokenId, "ARTIFACTS", artifactNames, offset, cardQuality);
        } else if (cardRand % 10 < 8) {
            return pluckOther(tokenId, "SPELL", spellNames, offset, cardQuality);
        } else {
            return pluckOther(tokenId, "ENCHANTMENT", enchantmentNames, offset, cardQuality);
        }
    }

    function pluckCreature(
        uint256 tokenId,
        string memory keyPrefix,
        string[] memory sourceArray,
        uint256 offset,
        uint8 cardQuality
    ) internal view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked(keyPrefix, toString(tokenId), toString(offset))));
        string memory output = string(abi.encodePacked(sourceArray[rand % sourceArray.length]));

        if (cardQuality == 1 || cardQuality == 2) {
            output = string(
                abi.encodePacked(
                    nameModifiers[rand % nameModifiers.length],
                    " ",
                    creatureModifiers[rand % creatureModifiers.length],
                    " ",
                    output
                )
            );
        }

        if (cardQuality == 2) {
            output = string(abi.encodePacked(output, " ", locations[rand % locations.length]));
        }

        if (cardQuality == 3) {
            output = string(
                abi.encodePacked(
                    nameModifiers[rand % nameModifiers.length],
                    " ",
                    mythicCreatureModifiers[rand % mythicCreatureModifiers.length],
                    " ",
                    output,
                    " ",
                    mythicLocations[rand % mythicLocations.length]
                )
            );
        }

        return output;
    }

    function pluckOther(
        uint256 tokenId,
        string memory keyPrefix,
        string[] memory sourceArray,
        uint256 offset,
        uint8 cardQuality
    ) internal view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked(keyPrefix, toString(tokenId), toString(offset))));

        string memory output = string(abi.encodePacked(sourceArray[rand % sourceArray.length]));

        if (cardQuality > 0) {
            output = string(abi.encodePacked(spellType[rand % spellType.length], " ", output));
        }

        if (cardQuality > 1) {
            output = string(abi.encodePacked(spellMagnifiers[rand % spellMagnifiers.length], " ", output));
        }

        return output;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        string memory output;
        string memory stringTokenId = toString(tokenId);

        for (uint256 i = 0; i < 11; i = i + 1) {
            uint256 offset = (i + 1) * 18 + 73;
            output = string(
                abi.encodePacked(
                    output,
                    "<tspan x='32' y='",
                    toString(offset),
                    "'>",
                    getCardTitle(tokenId, i),
                    "</tspan>"
                )
            );
        }

        uint256 creatureCount = 0;
        uint256 artifactCount = 0;
        uint256 spellCount = 0;
        uint256 enchantmentCount = 0;

        for (uint256 i = 10; i < 45; i++) {
            uint256 cardSplit = random(string(abi.encodePacked(toString(tokenId), toString(i))));
            uint256 cardCatagory = cardSplit % 10;
            if (cardCatagory % 10 < 5) {
                creatureCount++;
            } else if (cardCatagory % 10 < 6) {
                artifactCount++;
            } else if (cardCatagory % 10 < 8) {
                spellCount++;
            } else {
                enchantmentCount++;
            }
        }

        output = string(
            abi.encodePacked(
                output,
                "</text> <text fill='white' xml:space='preserve' style='white-space: pre;' font-family='Georgia' font-size='8' letter-spacing='0em'><tspan x='32' y='308.291'>34 other cards: ",
                toString(creatureCount),
                " monsters, ",
                toString(enchantmentCount),
                " enchantments,",
                toString(spellCount),
                " spells, ",
                toString(artifactCount),
                " artifacts</tspan></text>"
            )
        );

        output = string(
            abi.encodePacked(
                "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'> <rect width='350' height='350' fill='url(#paint0_linear)'/> <rect width='318' height='318' transform='translate(16 16)' fill='#16150f'/> <text fill='white' xml:space='preserve' style='white-space: pre;' font-family='Georgia' font-size='12' font-weight='bold' letter-spacing='0em'><tspan x='32' y='62.1865'>STARTER DECK</tspan></text> <text fill='#F19100' xml:space='preserve' style='white-space: pre;' font-family='Georgia' font-size='16' font-weight='bold' letter-spacing='0.16em'><tspan x='32' y='43.582'>45 ADVENTURE CARDS</tspan></text> <text fill='white' xml:space='preserve' style='white-space: pre;' font-family='Georgia' font-size='12' letter-spacing='0em'>",
                output,
                "<defs> <linearGradient id='paint0_linear' x1='175' y1='350' x2='175' y2='0' gradientUnits='userSpaceOnUse'> <stop stop-color='#744500'/> <stop offset='1' stop-color='#D68103'/> </linearGradient> </defs></svg>"
            )
        );

        string memory animationUrl = string(abi.encodePacked(_baseURI(), "animation/", stringTokenId));
        string memory externalUrl = string(abi.encodePacked(_baseURI(), "decks/", stringTokenId));

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "Adventure Cards #',
                        stringTokenId,
                        '", "animation_url": "',
                        animationUrl,
                        '", "external_url": "',
                        externalUrl,
                        '", "description": "Cards is an on chain, collectable card game, based on crypto primitives. Each Starter Deck is 45 cards, a mix of rarities and types. The decks can be unbundled and used however you like.", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(output)),
                        '"}'
                    )
                )
            )
        );

        output = string(abi.encodePacked("data:application/json;base64,", json));

        return output;
    }

    mapping(address => uint256) private _mintPerAddress;

    uint256 public MAX_PER_ADDRESS = 2;
    uint256 public MAX_MINT = 8000;

    uint256 public publicIssued = 0;
    uint256 public publicMax = 0;

    function mintPublic() public {
        require(_mintPerAddress[msg.sender] < MAX_PER_ADDRESS, "You have reached your minting limit.");
        require(publicIssued < 7778, "There are no more NFTs for public minting.");
        require(publicIssued < publicMax, "There are no more NFTs for public minting at this time.");

        _mintPerAddress[msg.sender] += 1;

        uint256 tokenId = publicIssued + 1;

        publicIssued += 1;
        _safeMint(msg.sender, tokenId);
    }

    function setPublicMax(uint256 _publicMax) public onlyOwner {
        require(_publicMax <= MAX_MINT, "You can not set it that high.");

        publicMax = _publicMax;
    }

    function ownerClaim(uint256 tokenId) public nonReentrant onlyOwner {
        require(tokenId > 7777 && tokenId < 8001, "Token ID invalid");
        _safeMint(owner(), tokenId);
    }

    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT license
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    constructor() ERC721("Card", "Card") Ownable() {}
}