// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import './sources/libraries/SafeMath.sol';
import './sources/interfaces/IERC20.sol';
import './sources/token/SafeERC20.sol';
import './sources/access/Ownable.sol';
import "./ThunderToken.sol";
import "hardhat/console.sol";

interface IRouter {
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

// import "@nomiclabs/buidler/console.sol";

// MasterChef is the master of Thunder. He can make Thunder and he is a fair guy.
//
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once THUNDER is sufficiently
// distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.
contract MasterChef is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Info of each user.
    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        //
        // We do some fancy math here. Basically, any point in time, the amount of THUNDERs
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accThunderPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accThunderPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. THUNDERs to distribute per block.
        uint256 lastRewardBlock;  // Last block number that THUNDERs distribution occurs.
        uint256 accThunderPerShare; // Accumulated THUNDERs per share, times 1e12. See below.
    }

    IRouter public router;
    address public weth;
    address public marketing;
    address public liqProvider;

    // The THUNDER TOKEN!
    ThunderToken public thunder;
    // THUNDER tokens created per block - ownerFee.
    uint256 public thunderPerBlock;
    // Bonus muliplier for early thunder makers.
    uint256 public BONUS_MULTIPLIER = 1;

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // Allocation ratio for pool 0
    uint8 public allocRatio = 2;
    // The block number when THUNDER mining starts.
    uint256 public startBlock;
    // Owner fee
    uint256 public constant ownerFee = 2000; // 20%

    mapping (address => bool) public lpTokenAdded;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(
        ThunderToken _thunder,
        uint256 _thunderPerBlock,
        uint256 _startBlock
    ) {
        thunder = _thunder;
        thunderPerBlock = _thunderPerBlock;
        startBlock = _startBlock;

        // staking pool
        poolInfo.push(PoolInfo({
            lpToken: _thunder,
            allocPoint: 1000,
            lastRewardBlock: startBlock,
            accThunderPerShare: 0
        }));

        totalAllocPoint = 1000;
        lpTokenAdded[address(_thunder)] = true;

    }

    function updateMultiplier(uint256 multiplierNumber) public onlyOwner {
        BONUS_MULTIPLIER = multiplierNumber;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(uint256 _allocPoint, IERC20 _lpToken, bool _withUpdate) public onlyOwner {
        require(lpTokenAdded[address(_lpToken)] == false, 'Pool for this token already exists!');
        lpTokenAdded[address(_lpToken)] = true;

        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accThunderPerShare: 0
        }));
        updateStakingPool();
    }

    // Update the given pool's THUNDER allocation point. Can only be called by the owner.
    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 prevAllocPoint = poolInfo[_pid].allocPoint;
        poolInfo[_pid].allocPoint = _allocPoint;
        if (prevAllocPoint != _allocPoint) {
            totalAllocPoint = totalAllocPoint.sub(prevAllocPoint).add(_allocPoint);
            updateStakingPool();
        }
    }

    function updateStakingPool() internal {
        uint256 length = poolInfo.length;
        uint256 points = 0;
        for (uint256 pid = 1; pid < length; ++pid) {
            points = points.add(poolInfo[pid].allocPoint);
        }
        if (points != 0) {
            points = points.div(allocRatio);
            totalAllocPoint = totalAllocPoint.sub(poolInfo[0].allocPoint).add(points);
            poolInfo[0].allocPoint = points;
        }
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        return _to.sub(_from).mul(BONUS_MULTIPLIER);
    }

    // View function to see pending THUNDERs on frontend.
    function pendingThunder(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accThunderPerShare = pool.accThunderPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 thunderReward = multiplier.mul(thunderPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accThunderPerShare = accThunderPerShare.add(thunderReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accThunderPerShare).div(1e12).sub(user.rewardDebt);
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 thunderReward = multiplier.mul(thunderPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        thunder.mint(thunderReward);
        pool.accThunderPerShare = pool.accThunderPerShare.add(thunderReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;

        // Mint fee
        uint minting = thunderReward.mul(ownerFee).div(10000);
        thunder.mint(minting);

        // Calculate path
        address[] memory path = new address[](2);
        path[0] = address(thunder);
        path[1] = address(weth);

        // Transfer 2.5% for LP
        thunder.transfer(liqProvider, minting/8);

        // Sell 2.5% for LP
        thunder.approve(address(router), minting);
        router.swapExactTokensForETH(
        minting/8,
        0,
        path,
        liqProvider,
        block.timestamp + 600);

        // Sell 5% for owner
        router.swapExactTokensForETH(
        minting/4,
        0,
        path,
        owner(),
        block.timestamp + 600);

        // Sell 5% for marketing
        router.swapExactTokensForETH(
        minting/4,
        0,
        path,
        marketing,
        block.timestamp + 600);

        // Burn 5%
        thunder.transfer(0x000000000000000000000000000000000000dEaD, minting/4);
    }

    // Deposit LP tokens to MasterChef for THUNDER allocation.
    function deposit(uint256 _pid, uint256 _amount) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accThunderPerShare).div(1e12).sub(user.rewardDebt);
            if(pending > 0) {
                safeThunderTransfer(msg.sender, pending);
            }
        }
        if (_amount > 0) {
            // Thanks for auditer advice
            uint256 before = pool.lpToken.balanceOf(address(this));
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            uint256 _after = pool.lpToken.balanceOf(address(this));
            _amount = _after.sub(before);
            // Thanks for auditer advice

            user.amount = user.amount.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accThunderPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    // Stake THUNDER tokens to MasterChef
    function enterStaking(uint256 _amount) public {
        deposit(0, _amount);
    }

    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 _pid, uint256 _amount) public {
        
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");

        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accThunderPerShare).div(1e12).sub(user.rewardDebt);
        if(pending > 0) {
            safeThunderTransfer(msg.sender, pending);
        }
        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accThunderPerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    // Withdraw THUNDER tokens from STAKING.
    function leaveStaking(uint256 _amount) public {
        withdraw(0, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        pool.lpToken.safeTransfer(address(msg.sender), amount);
        emit EmergencyWithdraw(msg.sender, _pid, amount);
    }

    // Safe THUNDER transfer function, just in case if rounding error causes pool to not have enough THUNDER.
    function safeThunderTransfer(address _to, uint256 _amount) internal {
        thunder.safeThunderTransfer(_to, _amount);
    }

    // Update pool 0 allocation ratio. Can only be called by the owner.
    function setAllocRatio(uint8 _allocRatio) public onlyOwner {
        require(
            _allocRatio >= 1 && _allocRatio <= 20, 
            "Allocation ratio must be in range 1-20"
        );

        allocRatio = _allocRatio;
    }

    function setThunderPerBlock(uint _value) public onlyOwner {
        thunderPerBlock = _value;
    }

    function setRouter(address _address) public onlyOwner {
        router = IRouter(_address);
    }

    function setWETH(address _address) public onlyOwner {
        weth = _address;
    }

    function setMarketing(address _address) public onlyOwner {
        marketing = _address;
    }
    
    function setLiqProvider(address _address) public onlyOwner {
        liqProvider = _address;
    }
}