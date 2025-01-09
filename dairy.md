# Dairy

## Project

### Init

- Init

```shell
forge init
forge install foundry-rs/forge-std
forge install OpenZeppelin/openzeppelin-foundry-upgrades
forge install OpenZeppelin/openzeppelin-contracts-upgradeable
forge fmt
```

- Updated `foundry.toml`, adding remappings
- Generate `remappings.txt` for VS code `forge remappings > remappings.txt`
- Configure `foundry.toml` to use hardhat well known wallet 1.
- Configure `foundry.toml` to limit fuzz testing and setup chain.

### Test and Coverage

```shell
forge build
forge test
forge coverage
```

### Deploy local

Console number 1

```shell
source .env.local
anvil -m "$ANVIL_MNEMONIC" --block-base-fee-per-gas 0 --gas-price 0 --chain-id $ANVIL_CHAIN_ID
```

Console number 2

```shell
source .env.local
export PRIVATE_KEY=$ANVIL_PK
forge script script/Deploy.s.sol:StakingScript --fork-url $ANVIL_CHAIN_RPC --private-key $PRIVATE_KEY
```
