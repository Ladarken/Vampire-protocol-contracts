pragma solidity 0.5.17;

import "../lib/SafeMath.sol";
import "../lib/SafeMathInt.sol";
import "../lib/OwnableExtended.sol";

// Storage for a VAMP token
contract VAMPTokenStorage is OwnableExtended {

    using SafeMath for uint256;
    using SafeMathInt for int256;

    struct Transaction {
        bool enabled;
        address destination;
        bytes data;
    }

    // Stable ordering is not guaranteed.
    Transaction[] public transactions;

    uint256 internal constant DECIMALS = 18;
    uint256 internal constant MAX_UINT256 = ~uint256(0);
    uint256 internal constant INITIAL_FRAGMENTS_SUPPLY = 13750000 * 10 ** DECIMALS;

    // TOTAL_GONS is a multiple of INITIAL_FRAGMENTS_SUPPLY so that _gonsPerFragment is an integer.
    // Use the highest value that fits in a uint256 for max granularity.
    uint256 internal constant TOTAL_GONS = MAX_UINT256 - (MAX_UINT256 % INITIAL_FRAGMENTS_SUPPLY);

    // MAX_SUPPLY = maximum integer < (sqrt(4*TOTAL_GONS + 1) - 1) / 2
    uint256 internal constant MAX_SUPPLY = ~uint128(0);  // (2^128) - 1

    uint256 internal _epoch;

    uint256 internal _totalSupply;
    uint256 internal _gonsPerFragment;
    address internal rebaser;
    mapping(address => uint256) internal _gonBalances;

    // This is denominated in Fragments, because the gons-fragments conversion might change before
    // it's fully paid.
    mapping(address => mapping(address => uint256)) internal _allowedFragments;

}
