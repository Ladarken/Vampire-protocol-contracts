pragma solidity 0.5.17;

import "../lib/IERC20.sol";
import "./Initializable.sol";

contract ERC20Detailed is Initializable {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    function initialize( string memory name, string memory symbol, uint8  decimals) internal initializer {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view returns(string memory) {
        return _name;
    }

    function symbol() public view returns(string memory) {
        return _symbol;
    }

    function decimals() public view returns(uint8) {
        return _decimals;
    }

    uint256[50] private ______gap;
}