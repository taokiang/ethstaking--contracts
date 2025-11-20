# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a Hardhat Ignition module that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat node

```

# 管理员（owner）需要做的操作顺序：

部署 Token1（质押代币）和 Token2（奖励代币），给自己 mint 足够数量。
部署 StakingRewards 合约，参数填入 Token1 和 Token2 的地址。
先调用 setRewardsDuration() 设置奖励周期（如 30 天 = 2592000 秒）。只能在上一轮奖励完全结束后才能设置。
每次想开启/追加一轮奖励时：
先把足够的 Token2（奖励代币）转入 StakingRewards 合约。
调用 notifyRewardAmount(X)，X 是这一轮想发的总奖励数量。
合约会自动计算新的 rewardRate = 总奖励 / duration，并更新 finishAt。

重复第 4 步即可持续发奖励。

# 用户操作流程：

先对 Token1 approve(StakingRewards地址, 数量)
调用 stake(amount) → 质押，自动更新可领奖励
随时调用 getReward() → 领取累计的 Token2 奖励
随时调用 unstake(amount) → 取回本金（会先自动结算奖励）
也可以 stake + getReward 分开操作，奖励会一直累积
