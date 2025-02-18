// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract WETH {
    // 合约的名称、符号、和精度
    string public name = "Wrapped Ether";
    string public symbol = "WETH";
    uint8 public decimals = 18;

    // 事件声明，用于记录和跟踪重要的合约操作
    event Approval(address indexed src, address indexed delegateAds, uint256 amount); // 记录授权委托
    event Transfer(address indexed src, address indexed toAds, uint256 amount); // 记录转账
    event Deposit(address indexed toAds, uint256 amount); // 记录存款
    event Withdraw(address indexed src, uint256 amount); // 记录提取

    // 存储每个地址的余额
    mapping(address => uint256) public balanceOf;
    // 存储每个地址对另一个地址的授权额度
    mapping(address => mapping(address => uint256)) public allowance;

    // 存款函数，允许用户将以太币存入合约，转化为 WETH
    function deposit() public payable {
        balanceOf[msg.sender] += msg.value; // 增加调用者的 WETH 余额
        emit Deposit(msg.sender, msg.value); // 触发存款事件
    }

    // 提款函数，允许用户提取存入合约的 WETH，转回 ETH
    function withdraw(uint256 amount) public {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance"); // 确保用户有足够的 WETH
        balanceOf[msg.sender] -= amount; // 减少用户的 WETH 余额
        payable(msg.sender).transfer(amount); // 将 ETH 转账给用户
        emit Withdraw(msg.sender, amount); // 触发提款事件
    }

    // 获取合约的总供应量，这里就是合约余额
    function totalSupply() public view returns (uint256) {
        return address(this).balance; // 返回合约的余额，也就是总供应量
    }

    // 授权函数，允许用户将一定数量的 WETH 授权给指定地址
    function approve(address delegateAds, uint256 amount) public returns (bool) {
        allowance[msg.sender][delegateAds] = amount; // 设置授权额度
        emit Approval(msg.sender, delegateAds, amount); // 触发授权事件
        return true;
    }

    // 转账函数，用户将一定数量的 WETH 转给其他地址
    function transfer(address toAds, uint256 amount) public returns (bool) {
        return transferFrom(msg.sender, toAds, amount); // 调用 transferFrom 实现转账功能
    }

    // 转账函数，支持委托转账
    function transferFrom(
        address src, // 源地址
        address toAds, // 目标地址
        uint256 amount // 转账数量
    ) public returns (bool) {
        require(balanceOf[src] >= amount, "Insufficient balance"); // 确保源地址余额足够
        if (src != msg.sender) { // 如果是委托转账，需要检查授权额度
            require(allowance[src][msg.sender] >= amount, "Allowance exceeded");
            allowance[src][msg.sender] -= amount; // 减少授权额度
        }
        balanceOf[src] -= amount; // 从源地址减少余额
        balanceOf[toAds] += amount; // 增加目标地址余额
        emit Transfer(src, toAds, amount); // 触发转账事件
        return true;
    }

    // 回退函数，用于处理不匹配的调用
    fallback() external payable {
        deposit(); // 调用存款函数，将收到的 ETH 转换为 WETH
    }

    // 接收函数，允许合约接收 ETH
    receive() external payable {
        deposit(); // 调用存款函数，将收到的 ETH 转换为 WETH
    }
}
