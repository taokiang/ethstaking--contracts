// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token2 is ERC20 {
    address public immutable owner;
    constructor(uint256 initialSupply) ERC20("Reward Token","REWARD") {
        owner = msg.sender;
        _mint(msg.sender, initialSupply);
    }
    function mint(address to, uint256 amount) public {
        require(msg.sender == owner, "not owner");
        _mint(to, amount);
    }
    /// @notice 合约拥有者回收误转入的 ERC20 代币
    /// @param token 代币合约地址
    /// @param amount 回收数量
    function recoverERC20(address token, uint256 amount) external {
        require(msg.sender == owner, "not owner");
        require(token != address(this), "Cannot recover reward token");
        IERC20(token).transfer(owner, amount);
    }
}
