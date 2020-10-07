pragma solidity 0.5.17;

import "./VAMPTokenInterface.sol";

/* 
    VAMP.sol

    Elastic Supply ERC20 Token with randomized rebasing.
    
    Forked from Ampleforth: https://github.com/ampleforth/uFragments
    
    GPL 3.0 license.
    
    VAMP.sol - Basic ERC20 Token with rebase functionality
    Rebaser.sol - Handles decentralized, autonomous, random rebasing on-chain. 
    
    Rebaser.sol will be upgraded as the project progresses. Ownership of VAMP.sol can be changed to new versions of Rebaser.sol as they are released.
    
    See github for more info and latest versions: https://github.com/VAMPdefiteam
    
    Once a final version has been agreed, owner address of VAMP.sol will be locked to ensure completely decentralised operation forever.
    
*/

contract VAMPToken is VAMPTokenInterface {

    modifier validRecipient(address to)
    {
        require(to != address(0x0));
        require(to != address(this));
        _;
    }

    modifier onlyRebaser()
    {
        require(msg.sender == rebaser);
        _;
    }

    function setRebaser(address _rebaser) public onlyOwner
    {
        rebaser = _rebaser;
    }

    /**
     * @dev Notifies Fragments contract about a new rebase cycle.
     * @param supplyDelta The number of new fragment tokens to add into circulation via expansion.
     * @return The total number of fragments after the supply adjustment.
     */
    function rebase(int256 supplyDelta) external onlyRebaser returns (uint256)
    {
        _epoch = _epoch.add(1);

        if (supplyDelta == 0) {
            emit LogRebase(_epoch, _totalSupply);
            return _totalSupply;
        }

        if (supplyDelta < 0) {
            _totalSupply = _totalSupply.sub(uint256(supplyDelta.abs()));
        } else {
            _totalSupply = _totalSupply.add(uint256(supplyDelta));
        }

        if (_totalSupply > MAX_SUPPLY) {
            _totalSupply = MAX_SUPPLY;
        }

        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);

        // From this point forward, _gonsPerFragment is taken as the source of truth.
        // We recalculate a new _totalSupply to be in agreement with the _gonsPerFragment
        // conversion rate.
        // This means our applied supplyDelta can deviate from the requested supplyDelta,
        // but this deviation is guaranteed to be < (_totalSupply^2)/(TOTAL_GONS - _totalSupply).
        //
        // In the case of _totalSupply <= MAX_UINT128 (our current supply cap), this
        // deviation is guaranteed to be < 1, so we can omit this step. If the supply cap is
        // ever increased, it must be re-included.
        // _totalSupply = TOTAL_GONS.div(_gonsPerFragment)

        emit LogRebase(_epoch, _totalSupply);

        for (uint i = 0; i < transactions.length; i++) {
            Transaction storage t = transactions[i];
            if (t.enabled) {
                bool result = externalCall(t.destination, t.data);
                if (!result) {
                    emit TransactionFailed(t.destination, i, t.data);
                    revert("Transaction Failed");
                }
            }
        }

        return _totalSupply;
    }

    function mint(address account, uint256 amount) public onlyOwner returns (bool)
    {
        require(amount > 0);
        _mint(account, amount);
        return true;
    }

    function burn(uint256 amount) public onlyOwner returns (bool)
    {
        _burn(msg.sender, amount);
        return true;
    }

    function _mint(address account, uint256 amount) internal
    {
        require(account != address(0), "ERC20: mint to the zero address");
        // uint256 merValue = amount.mul(_gonsPerFragment);
        _totalSupply = _totalSupply.add(amount);
        _gonBalances[account] = _gonBalances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 value) internal
    {
        require(account != address(0));
        // uint256 merValue = value.mul(_gonsPerFragment);
        _totalSupply = _totalSupply.sub(value);
        _gonBalances[account] = _gonBalances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @return The total number of fragments.
     */
    function totalSupply() public view returns (uint256)
    {
        return _totalSupply;
    }

    /**
     * @param who The address to query.
     * @return The balance of the specified address.
     */
    function balanceOf(address who) public view returns (uint256)
    {
        return _gonBalances[who].div(_gonsPerFragment);
    }

    /**
     * @dev Transfer tokens to a specified address.
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     * @return True on success, false otherwise.
     */
    function transfer(address to, uint256 value) public validRecipient(to) returns (bool)
    {
        uint256 merValue = value.mul(_gonsPerFragment);
        _gonBalances[msg.sender] = _gonBalances[msg.sender].sub(merValue);
        _gonBalances[to] = _gonBalances[to].add(merValue);
        emit Transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner has allowed to a spender.
     * @param owner_ The address which owns the funds.
     * @param spender The address which will spend the funds.
     * @return The number of tokens still available for the spender.
     */
    function allowance(address owner_, address spender) public view returns (uint256)
    {
        return _allowedFragments[owner_][spender];
    }

    /**
     * @dev Transfer tokens from one address to another.
     * @param from The address you want to send tokens from.
     * @param to The address you want to transfer to.
     * @param value The amount of tokens to be transferred.
     */
    function transferFrom(address from, address to, uint256 value) public validRecipient(to) returns (bool)
    {
        _allowedFragments[from][msg.sender] = _allowedFragments[from][msg.sender].sub(value);

        uint256 merValue = value.mul(_gonsPerFragment);
        _gonBalances[from] = _gonBalances[from].sub(merValue);
        _gonBalances[to] = _gonBalances[to].add(merValue);
        emit Transfer(from, to, value);

        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of
     * msg.sender. This method is included for ERC20 compatibility.
     * increaseAllowance and decreaseAllowance should be used instead.
     * Changing an allowance with this method brings the risk that someone may transfer both
     * the old and the new allowance - if they are both greater than zero - if a transfer
     * transaction is mined before the later approve() call is mined.
     *
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value) public returns (bool)
    {
        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner has allowed to a spender.
     * This method should be used instead of approve() to avoid the double approval vulnerability
     * described above.
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool)
    {
        _allowedFragments[msg.sender][spender] =
        _allowedFragments[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner has allowed to a spender.
     *
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool)
    {
        uint256 oldValue = _allowedFragments[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] = oldValue.sub(subtractedValue);
        }
        emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
        return true;
    }

    /**
     * @notice Adds a transaction that gets called for a downstream receiver of rebases
     * @param destination Address of contract destination
     * @param data Transaction data payload
     */
    function addTransaction(address destination, bytes calldata data) external onlyOwner
    {
        transactions.push(Transaction({
        enabled : true,
        destination : destination,
        data : data
        }));
    }

    /**
     * @param index Index of transaction to remove.
     *              Transaction ordering may have changed since adding.
     */
    function removeTransaction(uint index) external onlyOwner
    {
        require(index < transactions.length, "index out of bounds");

        if (index < transactions.length - 1) {
            transactions[index] = transactions[transactions.length - 1];
        }

        transactions.length--;
    }

    /**
     * @param index Index of transaction. Transaction ordering may have changed since adding.
     * @param enabled True for enabled, false for disabled.
     */
    function setTransactionEnabled(uint index, bool enabled) external onlyOwner
    {
        require(index < transactions.length, "index must be in range of stored tx list");
        transactions[index].enabled = enabled;
    }

    /**
     * @return Number of transactions, both enabled and disabled, in transactions list.
     */
    function transactionsSize() external view returns (uint256)
    {
        return transactions.length;
    }

    /**
     * @dev wrapper to call the encoded transactions on downstream consumers.
     * @param destination Address of destination contract.
     * @param data The encoded data payload.
     * @return True on success
     */
    function externalCall(address destination, bytes memory data) internal returns (bool)
    {
        bool result;
        assembly {// solhint-disable-line no-inline-assembly
        // "Allocate" memory for output
        // (0x40 is where "free memory" pointer is stored by convention)
            let outputAddress := mload(0x40)

        // First 32 bytes are the padded length of data, so exclude that
            let dataAddress := add(data, 32)

            result := call(
            // 34710 is the value that solidity is currently emitting
            // It includes callGas (700) + callVeryLow (3, to pay for SUB)
            // + callValueTransferGas (9000) + callNewAccountGas
            // (25000, in case the destination address does not exist and needs creating)
            sub(gas, 34710),


            destination,
            0, // transfer value in wei
            dataAddress,
            mload(data), // Size of the input, in bytes. Stored in position 0 of the array.
            outputAddress,
            0  // Output is ignored, therefore the output size is zero
            )
        }
        return result;
    }

}

contract VAMP is VAMPToken {

    constructor() public {

        Ownable.initialize(msg.sender);
        ERC20Detailed.initialize("VAMP", "VAMP", uint8(DECIMALS));

        _totalSupply = INITIAL_FRAGMENTS_SUPPLY;
        _gonBalances[msg.sender] = TOTAL_GONS;
        _gonsPerFragment = TOTAL_GONS.div(_totalSupply);

        emit Transfer(address(0x0), msg.sender, _totalSupply);
    }


}