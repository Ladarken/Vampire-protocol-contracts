# Levers

The expectation is that after the pools receive their VAMPs, there is no longer a founding team or any team to speak of. This is a protocol that is being put out there in a decentralized  way, then walk away. The writer of these contracts or those connected with its inception, are under no obligation and likely won't continue development once it is deployed.

That said, it would be helpful for governance to have a well documented set of levers inside the protocol so if the community wishes to govern, they can.

## VAMP Levers

#### `gov`/`pendingGov`
##### File: `VAMPTokenStorage.sol`
##### Description
address that controls every permissioned function, or is primed to.
##### Setting
###### File: `VAMP.sol`
`_setPendingGov(address)`: sets `pendingGov` to new address. To complete the change of governance, the new governance contract has to call `_acceptGov()`.

<br />
<br />
<br />

#### `rebaser`
##### File: `VAMPTokenStorage.sol`
##### Description
address that controls the rebasing functionality. This contract is one of two contracts that can `mint`. It also tells how much to change `VAMPsScalingFactor`.
##### Setting
###### File: `VAMP.sol`
`_setRebaser(address)`: sets `rebaser` to new address.

<br />
<br />
<br />

#### `incentivizer`
##### File: `VAMPTokenStorage.sol`
##### Description
address that controls the incentivizer pool. This contract is one of two contracts that can `mint`. It is there to promote liquidity for the rebasing functionality to work correctly.
##### Setting
###### File: `VAMP.sol`
`_setIncentivizer(address)`: sets `incentivzer` to new address.

<br />
<br />
<br />

## Rebaser Levers

#### `transactions`
##### File: `VAMPRebaser.sol`
##### Description
Transactions that the rebaser sends after a rebase. Useful for calling `sync()` like functions.
##### init_value: `[]` (empty)
##### Setting
###### File: `VAMPRebaser.sol`
```
addTransaction(address destination, bytes calldata data)
```
 adds a transaction to the list of txs to perform.
<br />
<br />
```
removeTransaction(uint index)
```
removes a transaction to the list of txs.
<br />
<br />
```
setTransactionEnabled(uint index, bool enabled)
```
enables or disables a tx in the `transactions` list.

<br />
<br />
<br />

#### `gov`/`pendingGov`
##### File: `VAMPRebaser.sol`
##### Description
address that controls every permissioned function, or is primed to.
##### Setting
###### File: `VAMPRebaser.sol`
`_setPendingGov(address)`: sets `pendingGov` to new address. To complete the change of governance, the new governance contract has to call `_acceptGov()`.

<br />
<br />
<br />


#### `rebaseLag`
##### File: `VAMPRebaser.sol`
##### Description
rebaseLag spreads out the time it takes to reach the peg. i.e. if the supply is suppose to increase 10% in a particular rebase, that 10% is divided by this rebaseLag to slow it down a bit. Since rebases happen twice daily, a value of 10, slows it down to 5 days (if no further price change).
##### init_value: `10`
##### Setting
###### File: `VAMPRebaser.sol`
```
setRebaseLag(uint256 rebaseLag_)
```

<br />
<br />
<br />

#### `targetRate`
##### File: `VAMPRebaser.sol`
##### Description
The peg the protocol should aim for relative to the reserveToken. i.e. `1e18` means 1:1 between the reserveToken and VAMP.
##### init_value: `1e18`
##### Setting
###### File: `VAMPRebaser.sol`
```
setTargetRate(uint256 targetRate_)
```

<br />
<br />
<br />

#### `rebaseMintPerc`
##### File: `VAMPRebaser.sol`
##### Description
The amount of VAMP that the rebaser mints that is sold to build the protocol's treasury. Decimals: 18. i.e. 1e17 == .1, or 10% of the rebase.
##### init_value: `1e17` or `10%`
##### Setting
###### File: `VAMPRebaser.sol`
```
setRebaseMintPerc(uint256 rebaseMintPerc_)
```


<br />
<br />
<br />

#### `deviationThreshold`
##### File: `VAMPRebaser.sol`
##### Description
The percentage difference between price and peg needed to allow for a change of supply via rebase.
##### init_value: `5*1e16` or `5%`
##### Setting
###### File: `VAMPRebaser.sol`
```
setDeviationThreshold(uint256 deviationThreshold_)
```


<br />
<br />
<br />

#### `minRebaseTimeIntervalSec`
##### File: `VAMPRebaser.sol`
##### Description
Amount of time between rebases.
##### init_value: `12 hours`
##### Setting
###### File: `VAMPRebaser.sol`
```
setRebaseTimingParameters(
    uint256 minRebaseTimeIntervalSec_,
    uint256 rebaseWindowOffsetSec_,
    uint256 rebaseWindowLengthSec_
)
```

<br />
<br />
<br />

#### `rebaseWindowOffsetSec`
##### File: `VAMPRebaser.sol`
##### Description
The number of seconds from the beginning of the rebase interval, where the rebase window begins.
##### init_value: `36000`
##### Setting
###### File: `VAMPRebaser.sol`
```
setRebaseTimingParameters(
    uint256 minRebaseTimeIntervalSec_,
    uint256 rebaseWindowOffsetSec_,
    uint256 rebaseWindowLengthSec_
)
```


<br />
<br />
<br />

#### `rebaseWindowLengthSec`
##### File: `VAMPRebaser.sol`
##### Description
The length of the time window where a rebase operation is allowed to execute, in seconds.
##### init_value: `900` or `15 minutes`
##### Setting
###### File: `VAMPRebaser.sol`
```
setRebaseTimingParameters(
    uint256 minRebaseTimeIntervalSec_,
    uint256 rebaseWindowOffsetSec_,
    uint256 rebaseWindowLengthSec_
)
```


<br />
<br />
<br />

#### `reservesContract`
##### File: `VAMPRebaser.sol`
##### Description
Address of the protocol owned reserves (treasury) contract.
##### init_value: `known at deployment`
##### Setting
###### File: `VAMPRebaser.sol`
```
setReserveContract(address reservesContract_)
```

<br />
<br />
<br />

#### `maxSlippageFactor`
##### File: `VAMPRebaser.sol`
##### Description
Max slippage factor when buying reserve token. Magic number based on the fact that uniswap is a constant product. Therefore, targeting a % max slippage can be achieved by using a single precomputed number. i.e. 2.5% slippage is always equal to some f(maxSlippageFactor, reserves)
##### init_value: `5409258 * 10**10`, targeting max slippage of `10%`
##### Setting
###### File: `VAMPRebaser.sol`
```
setMaxSlippageFactor(uint256 maxSlippageFactor_)
```
