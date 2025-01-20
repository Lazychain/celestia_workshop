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

