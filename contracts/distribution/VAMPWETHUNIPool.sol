/*

                                                                                                      
      _____         ____        _____        ______  _______    ____  _____   ______         _____    
 ____|\    \   ____|\   \   ___|\    \      |      \/       \  |    ||\    \ |\     \    ___|\    \   
|    | \    \ /    /\    \ |    |\    \    /          /\     \ |    | \\    \| \     \  /    /\    \  
|    |______/|    |  |    ||    | |    |  /     /\   / /\     ||    |  \|    \  \     ||    |  |____| 
|    |----'\ |    |__|    ||    |/____/  /     /\ \_/ / /    /||    |   |     \  |    ||    |    ____ 
|    |_____/ |    .--.    ||    |\    \ |     |  \|_|/ /    / ||    |   |      \ |    ||    |   |    |
|    |       |    |  |    ||    | |    ||     |       |    |  ||    |   |    |\ \|    ||    |   |_,  |
|____|       |____|  |____||____| |____||\____\       |____|  /|____|   |____||\_____/||\ ___\___/  /|
|    |       |    |  |    ||    | |    || |    |      |    | / |    |   |    |/ \|   ||| |   /____ / |
|____|       |____|  |____||____| |____| \|____|      |____|/  |____|   |____|   |___|/ \|___|    | / 
  )/           \(      )/    \(     )/      \(          )/       \(       \(       )/     \( |____|/  
  '             '      '      '     '        '          '         '        '       '       '   )/     
                                                                                               '      

   ____            __   __        __   _
  / __/__ __ ___  / /_ / /  ___  / /_ (_)__ __
 _\ \ / // // _ \/ __// _ \/ -_)/ __// / \ \ /
/___/ \_, //_//_/\__//_//_/\__/ \__//_/ /_\_\
     /___/

* Synthetix: VAMPRewards.sol
*
* Docs: https://docs.synthetix.io/
*
*
* MIT License
* ===========
*
* Copyright (c) 2020 Synthetix
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*/
pragma solidity ^0.5.17;

import "../lib/Ownable.sol";
import "../lib/Math.sol";
import "../lib/IERC20.sol";
import "../lib/SafeMath.sol";
import "../lib/Address.sol";
import "../lib/SafeERC20.sol";
import "../lib/IRewardDistributionRecipient.sol";

interface VAMP {
    function scalingFactor() external returns (uint256);
}

contract LPTokenWrapper {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public uni_lp = IERC20(0xA3d853CeFAebCc0C4E7116bf13e5E099eae0302a); //change this to uni pool

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function stake(uint256 amount) public {
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        uni_lp.safeTransferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint256 amount) public {
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        uni_lp.safeTransfer(msg.sender, amount);
    }
}

contract VAMPWETHUNIPOOL is LPTokenWrapper, IRewardDistributionRecipient {
     IERC20 public vamp = IERC20(0x4De8f3F90b1bFBE535a979B94f0eE94132d7072D);
    uint256 public DURATION = 7 days;
    uint256 public generation = 3;
    uint256 public initreward = 176000 ether;
    uint256 public starttime = 1598707259;
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(rewardRate)
                    .mul(1e18)
                    .div(totalSupply())
            );
    }

    function earned(address account) public view returns (uint256) {
        return
            balanceOf(account)
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                .div(1e18)
                .add(rewards[account]);
    }

    // stake visibility is public as overriding LPTokenWrapper's stake() function
    function stake(uint256 amount) public updateReward(msg.sender) checkhalve checkStart{
        require(amount > 0, "Cannot stake 0");
        super.stake(amount);
        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount) public updateReward(msg.sender) checkStart{
        require(amount > 0, "Cannot withdraw 0");
        super.withdraw(amount);
        emit Withdrawn(msg.sender, amount);
    }

    function exit() external {
        withdraw(balanceOf(msg.sender));
        getReward();
    }

    function getReward() public updateReward(msg.sender) checkhalve checkStart{
        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            rewards[msg.sender] = 0;
            vamp.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

     modifier checkhalve() {
   if (block.timestamp >= periodFinish) {
        generation = generation.add(1);
        if (generation == 4) {
            DURATION = 6 days;
            initreward = 256000 ether;
            rewardRate = initreward.div(DURATION);
            periodFinish = block.timestamp.add(DURATION);
            emit RewardAdded(initreward);
        } else if (generation == 5) {
            DURATION = 5 days;
            initreward = 336000 ether;
            rewardRate = initreward.div(DURATION);
            periodFinish = block.timestamp.add(DURATION);
            emit RewardAdded(initreward);
        } else if (generation == 6) {
            DURATION = 3 days;
            initreward = 432000 ether;
            rewardRate = initreward.div(DURATION);
            periodFinish = block.timestamp.add(DURATION);
            emit RewardAdded(initreward);
        } else if (generation > 6) {
            uint256 balance = vamp.balanceOf(address(this));
            require(balance > 0, "Contract is empty, all rewards distributed");
            vamp.safeTransfer(owner(), balance); //transfer any leftover rewards to the owner to be burned or airdropped.
        }

    }
    _;
}
    
    modifier checkStart(){
        require(block.timestamp > starttime,"not start");
        _;
    }

    function notifyRewardAmount()
        external
        onlyRewardDistribution
        updateReward(address(0))
    {
        if (block.timestamp >= periodFinish) {
            rewardRate = initreward.div(DURATION);
        } else {
            uint256 remaining = periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardRate);
            rewardRate = initreward.add(leftover).div(DURATION);
        }
       // vamp.mint(address(this),initreward);
        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(DURATION);
        emit RewardAdded(initreward);
    }
}