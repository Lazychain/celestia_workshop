# Lazy Workshop

Date: 2025-01-20

## Context

Since **Celestine Sloth Society** have his NFT Collection on other blockchains, there is a limit on what this NFT can do in terms of functionality.

**Celestine Sloth Society** wants to have his own blockchain **Lazychain** to evolve his main product NFT collection.

**Lazychain** is a community-driven blockchain for Sloths and on chain fun powered by Astria with Celestia underneath.

**App Specific Sequencing** (ASS) powered by Astria's sequencing layer maximizes the value that flows back to the Sloth community.

Our primary goal is to demonstrate that blockchain technology can be accessible and useful for everyday applications.

We're building a platform for developers to create applications users actually want to use, combined with distribution to an existing crypto native user base.

Whether you're building a social platform, a gaming application, or another consumer service, Lazychain provides the infrastructure and community support you need `LazyDev`.

## Architecture

We are going to use a **modular blockchain** using **Sovereign Rollups** using **Geth** as **Execution Layer**, **Astria** as **Settlement and consensus** layer and **Celestia** as **Data Availability Sampling** layer.

You can find details about our architecture on [docs](https://github.com/Lazychain/docs/blob/main/learn/adr/0013-astria.md#architecture).

## Hands on LazyDev, in control

As your first assignment, we encourage you to do a `NFT staking contract` for the campaign `Sleep2Earn`.

But first, let me tell you how is a normal day in Lazy development department.

A `Product manager` work with the Lazy community via `questions` or `polls` and `voting governance` to select most relevant needs.

Then with the `CEO` establish a course of decisions and funding.

With the help of `Analist, Technical leader and a UX` give life to a project on `docs`.

This project is taken by the `Project Manager` and the `Technical Leader` and create all the `Tasks` need it and a `Plan` to try to fulfill.

The day has come to `Stake2Earn` campaign with `NFT staking contract`.

Your `Technical leader` create and initialize a project with all the tech need it.

It assigns you some issues according to a `Plan`.

**Are you ready for what it takes the challenge?**

## Tasks

Your first `Task` is to read all the specification design and learn about the project scope and boundaries.

- Understand how the [architecture](docs/specifications/architecture.md) works.
- Understand what is expected for you to do with [lock-unlock](docs/specifications/staking.md) and [exchange](docs/specifications/exchange.md) according to the specifications.

### User Story 001

Read the [001 NFT Start Staking](docs/stories/0001-nft-stake-lock.md) User Story.

Challenge:

- Try to use TDD on this first assignment.
- Use [erc721](https://docs.openzeppelin.com/contracts/5.x/erc721).
- Implement the User Story 001 smart contract.
- Keep your code commented [natspec-format](https://docs.soliditylang.org/en/latest/natspec-format.html).
- Test Coverage must be 85% higher.

### User Story 002

Read the [002 NFT Stop Staking](docs/stories/0002-nft-stake-unlock.md) User Story.
Challenge:

- Do the same tasks as `User Story 0001`
- Deploy and run the tests over local blockchain.

### User Story 004

Read the [004 Staking Whitelist](docs/stories/0004-nft-stake-whitelist.md) User Story.
Challenge:

- Do the same tasks as `User Story 0001`
- Deploy and run the tests over testnet blockchain.

### User Story 005

Read the [004 User Points Consumed](docs/stories/0005-nft-stake-consume.md) User Story.
Challenge:

- Do the same tasks as `User Story 0001`.
- Create a PR and wait for reviews!!!

### User Story 006

Read the [004 User Points Consumed](docs/stories/0006-exchange-points-erc20.md) User Story.
Challenge:

- Do the same tasks as `User Story 0001`.
- Create a PR and wait for reviews!!!

### Tips

#### Build contracts

```shell
forge build
```

#### Debug contracts

```shell
forge test --match-contract StakingTest --match-test test_ImReady -vvvv
```

#### Generate coverage report

```shell
clear && forge coverage --report lcov && genhtml -o report --branch-coverage lcov.info --ignore-errors inconsistent --ignore-errors category
```

```shell
forge coverage --no-match-path 'test/invariant/**/*.sol' --report lcov
lcov --extract lcov.info --rc branch_coverage=1 --rc derive_function_end_line=0 -o lcov.info 'src/*' 
genhtml lcov.info --rc branch_coverage=1 --rc derive_function_end_line=0 -o coverage
```

#### Run local deploy

```shell
source .env
anvil
```

```shell
source .env
forge script script/Deploy.s.sol:Deploy --fork-url $CHAIN_RPC --broadcast
```
