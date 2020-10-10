
# Vampire-protocol

## Rebaser and Summoner farming pool are still under development, the rest is done. For any bugs or queries https://t.me/bytefang

## The Protocol
VAMP is an experimental protocol building upon the most exciting innovations in programmable money and governance. Built by a team of DeFi natives, it seeks to create:

•	an elastic supply to seek eventual price stability<br/>

At its core, VAMP is an elastic supply cryptocurrency, which expands and contracts its supply in response to market conditions, initially targeting 1 USD per VAMP. This stability mechanism includes one key addition to existing elastic supply models such as Ampleforth

We have built VAMP to be a minimally viable monetary experiment, and at launch there will be 63.64% of VAMP tokens. After deployment the remaining 36.36% of VAMP tokens will be farmed.

## Audits

None. Contributors have given their best efforts to ensure the security of these contracts, but make no guarantees. It has been spot checked by just a few pairs of eyes. It is a probability - not just a possibility - that there are bugs. That said, minimal changes were made to the staking/distribution contracts that have seen hundreds of millions flow through them via SNX, YFI, and YFI derivatives. The reserve contract is excessively simple as well. We prioritized staked assets' security first and foremost.

The original devs encourage governance to fund a bug bounty/security audit

The token itself is largely based on COMP and Ampleforth which have undergone audits - but we made non-trivial changes.

The rebaser may also have bugs - but has been tested in multiple scenarios. It is restricted to Externally Owned Accounts (EOAs) calling the rebase function for added security. SafeMath is used everywhere.

If you feel uncomfortable with these disclosures, don't stake or hold VAMP. If the community votes to fund an audit, or the community is gifted an audit, there is no assumption that the original devs will be around to implement fixes, and is entirely at their discretion.


## Distribution

The initial distribution of VAMP will be evenly distributed across five farming pools: Uniswap LP (ETH/VAMP), WBTC, WETH, USDT, UNI. These pools were chosen intentionally to reach a broad swath of the overall DeFi community, as well as specific communities with a proven commitment to active governance and an understanding of complex tokenomics.

Following the launch of the initial distribution pools, a second distribution pool called Summoner to farm vMANA with VAMP will launch for 7 days. After that a final pool to farm VAMP with vMANA_uniswap (vMANA/eth) LP tokens will launch.


## Rebases

Rebases are controlled by an external contract called the Rebaser. This is comparable to Ampleforth's `monetaryPolicy` contract. It dictates how large the rebase is and what happens on the rebase. The VAMP token just changes the supply based on what this contract provides it.

There are a requirements before rebases are active:
<br />
•	Liquid VAMP/ETH market<br/>
•	`init_twap()`<br/>
•	`activate_rebasing()`<br/>

Rebasing will begin its activation phase after all of the farming pools will close. This begins with `init_twap()` on the rebaser contract.  The oracle is designed to be 12 hours between checkpoints. Given that, 12 hours after `init_twap()` is called, anyone can call `activate_rebasing()`. This turns rebasing on, permanently. Now anyone can call `rebase()` when `inRebaseWindow() == true;`.

In a rebase, the order of operations are:
<br />
•	ensure in rebase window<br/>
•	calculate how far off-price is from the peg<br/>
•	dampen the rebase by the rebaseLag<br/>
•	if positive calculate protocol mint amount<br/>
•	change scaling factor, (in/de)flating the supply<br/>


## Governance
VAMP Governance will be timelocked after launch.

# Development
### Building
This repo uses truffle. Ensure that you have truffle installed. 

Then, to build the contracts run:
```
$ truffle compile
```

To run tests, we use the truffle test/ganache-cli setup:
```
$ sh startBlockchain.sh
$ truffle test
```

#### Attributions
Much of this codebase is modified from existing works, including:

[Compound](https://compound.finance) - Jumping off point for token code and governance

[Ampleforth](https://ampleforth.org) - Initial rebasing mechanism, modified to better suit the VAMP protocol

[Synthetix](https://synthetix.io) - Rewards staking contract

[YEarn](https://yearn.finance)/[YFI](https://ygov.finance) - Initial fair distribution implementation
