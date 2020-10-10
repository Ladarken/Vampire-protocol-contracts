pragma solidity 0.5.17;

import "./VAMPTokenStorage.sol";

contract VAMPTokenInterface is VAMPTokenStorage {

    event TransactionFailed(address indexed destination, uint index, bytes data);

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);

    /**
     * @notice EIP20 Transfer event
     */
    event Transfer(address indexed from, address indexed to, uint amount);

    /**
     * @notice EIP20 Approval event
     */
    event Approval(address indexed owner, address indexed spender, uint amount);


    // FUNCTIONS
    function setRebaser(address _rebaser) public;

    function rebase(int256 supplyDelta) external returns (uint256);

    function totalSupply() public view returns (uint256);

    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    function allowance(address owner_, address spender) public view returns (uint256);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool);

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool);

    function addTransaction(address destination, bytes calldata data) external;

    function removeTransaction(uint index) external;

    function setTransactionEnabled(uint index, bool enabled) external;

    function transactionsSize() external view returns (uint256);

}
