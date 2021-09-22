# <h1 align="center"> 0xAdventuresLoose </h1>

### <h4 align="center"> Forked from Georgios's [LootLoose](https://github.com/gakonst/lootloose) </h4>

**Split your [0xAdventures](https://0xadventures.com/) decks.**

![Github Actions](https://github.com/abigger87/0xAdventuresLoose/workflows/Tests/badge.svg)

0xAdventuresLoose is an ERC-1155 contract which allows you to:
1. Open your [Adventure Decks](https://www.adventureloose.com/) and mint 45 ERC-1155 tokens, corresponding to each item
in the bag
2. Re-assemble your ERC721 bag by giving back the ERC-1155 tokens to the contract

Each ERC1155's token URI is a b64 encoded SVG image, with the item's name (just that item's, not
any other item from the bag that contained it).

You can mint the 45 ERC-1155 tokens via 2 ways:
1. `approve` the `AdventureLoose.sol` contract to spend your NFT (or via `setApprovalForAll`) and calling `open`.
2. Transferring your NFT directly to the contract, triggerring the `onERC721Received` callback

You can reassemble the bag by first `approve` or `setApprovalForAll` for the tokens
contained in the bag and then calling `reassemble`.

Average gas cost to `open` is 322k gas, to `reassemble` 165k.

A UI is available for these contracts at [adventureloose](https://adventureloose.com) ([repo](https://github.com/abigger87/adventureloose.com))

## Building and testing

```sh
git clone https://github.com/abigger87/0xAdventuresLoose.git
cd 0xAdventuresLoose
make
make test
```

## Installing the toolkit

If you do not have DappTools already installed, you'll need to run the below
commands

### Install Nix

```sh
# User must be in sudoers
curl -L https://nixos.org/nix/install | sh

# Run this or login again to use Nix
. "$HOME/.nix-profile/etc/profile.d/nix.sh"
```

### Install DappTools

```sh
curl https://dapp.tools/install | sh
```

### Security Notes

* In order to improve gas efficiency, OZ's ERC1155.sol was patched to expose the `_balances`
mapping. We use that to do a batch mint inside `open`.

### Disclaimer

_These smart contracts are being provided as is. No guarantee, representation or warranty is being made, express or implied, as to the safety or correctness of the user interface or the smart contracts. They have not been audited and as such there can be no assurance they will work as intended, and users may experience delays, failures, errors, omissions, loss of transmitted information or loss of funds. Paradigm is not liable for any of the foregoing. Users should proceed with caution and use at their own risk._
