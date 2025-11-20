// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// 引入 OpenZeppelin 的 IERC20 接口，用于与 ERC20 代币交互
import "@openzeppelin/contracts/interfaces/IERC20.sol";

/// @title StakingRewards 质押奖励合约
/// @notice 用户可以质押代币并获得奖励代币
contract StakingRewards {
    // 质押的 ERC20 代币
    IERC20 public immutable stakingToken;
    // 奖励的 ERC20 代币
    IERC20 public immutable rewardsToken;
    // 合约拥有者
    address public owner;
    // 奖励发放周期（秒）
    uint256 public duration;
    // 当前奖励周期结束时间戳
    uint256 public finishAt;
    // 上次更新奖励的时间戳
    uint256 public updatedAt;
    // 当前奖励速率（每秒奖励数量）
    uint256 public rewardRate;
    // 累计每个代币的奖励
    uint256 public rewardPerTokenStored;

    // 记录每个用户已领取的奖励分配
    mapping(address => uint256) public userRewardPerTokenPaid;
    // 记录每个用户可领取的奖励
    mapping(address => uint256) public rewards;

    // 总质押数量
    uint256 public totalSupply;
    // 每个用户的质押数量
    mapping(address => uint256) public balanceOf;

    /// @dev 仅限合约拥有者调用的修饰器
    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    /// @dev 更新奖励的修饰器，调用相关函数前自动结算奖励
    modifier updateReward(address _account) {
        rewardPerTokenStored = rewardPerToken();
        updatedAt = lastTimeRewardApplicable();

        if (_account != address(0)) {
            rewards[_account] = earned(_account);
            userRewardPerTokenPaid[_account] = rewardPerTokenStored;
        }

        _;
    }

    /// @notice 构造函数，初始化质押和奖励代币地址，设置合约拥有者
    /// @param _stakingToken 质押代币地址
    /// @param _rewardsToken 奖励代币地址
    constructor(address _stakingToken, address _rewardsToken) {
        owner = msg.sender;
        stakingToken = IERC20(_stakingToken);
        rewardsToken = IERC20(_rewardsToken);
    }

    /// @notice 设置奖励发放周期
    /// @param _duration 奖励周期（秒）
    function setRewardsDuration(uint256 _duration) external onlyOwner {
        require(block.timestamp >= finishAt, "Previous rewards period must be complete before changing duration");
        duration = _duration;
    }

    /// @notice 通知合约奖励金额，开始新一轮奖励
    /// @param _amount 新增奖励数量
    function notifyRewardAmount(uint256 _amount)
        external
        onlyOwner
        updateReward(address(0))
    {
        require(_amount > 0, "amount = 0");

        if (block.timestamp > finishAt) {
            rewardRate = _amount / duration;
        } else {
            uint256 remainingRewards = rewardRate * (finishAt - block.timestamp);
            rewardRate = (remainingRewards + _amount) / duration;
        }
        require(rewardRate > 0, "reward rate = 0");
        require(
            rewardRate * duration <= rewardsToken.balanceOf(address(this)),
            "reward amount > balance"
        );
        if (block.timestamp >= finishAt) {
            finishAt = block.timestamp + duration;
        }
    }

    /// @notice 用户质押代币
    /// @param _amount 质押数量
    function stake(uint256 _amount) external updateReward(msg.sender) {
        require(_amount > 0, "amount = 0");
        stakingToken.transferFrom(msg.sender, address(this), _amount);
        balanceOf[msg.sender] += _amount;
        totalSupply += _amount;
    }

    /// @notice 用户取消质押（取回本金）
    /// @param _amount 要提取的质押数量
    function unstake(uint256 _amount) external updateReward(msg.sender) {
        require(_amount > 0, "Cannot unstake 0");
        require(balanceOf[msg.sender] >= _amount, "Insufficient staked balance");
        balanceOf[msg.sender] -= _amount;
        totalSupply -= _amount;
        // 将质押的 Token 转回用户
        stakingToken.transfer(msg.sender, _amount);
    }

    /// @notice 获取当前奖励可用的最后时间
    function lastTimeRewardApplicable() public view returns (uint256) {
        return _min(block.timestamp, finishAt);
    }

    /// @notice 计算每个代币的累计奖励
    function rewardPerToken() public view returns (uint256) {
        if (totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored +
            ((rewardRate * (lastTimeRewardApplicable() - updatedAt)) * 1e18) /
            totalSupply;
    }

    /// @notice 查询用户已赚取的奖励
    /// @param _account 用户地址
    function earned(address _account) public view returns (uint256) {
        return
            (balanceOf[_account] *
                (rewardPerToken() - userRewardPerTokenPaid[_account])) /
            1e18 +
            rewards[_account];
    }

    /// @notice 用户领取奖励
    function getReward() external updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardsToken.transfer(msg.sender, reward);
        }
    }

    /// @dev 求两个数的较小值
    function _min(uint256 x, uint256 y) private pure returns (uint256) {
        return x <= y ? x : y;
    }
}
