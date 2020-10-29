// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "./@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "./@openzeppelin/contracts/math/SafeMath.sol";
import "./@interface/IPureFlash.sol";

contract PureFlashValt is ERC20{
  using SafeMath  for uint256;
  using SafeERC20 for IERC20;
  
  IERC20 m_token;
  address m_profitpool;
  uint256 m_profit_rate;
  uint256 m_loan_fee;
  uint256 constant MAX_LOAN_FEE = 100*10000;
  constructor(address token,address profitpool,uint256 profitrate,uint256 loadfee) ERC20("",""){
       m_profitpool = profitpool;
       m_profit_rate = profitrate;
       m_loan_fee = loadfee;
  }

   function balance() public view returns(uint256){
        return m_token.balanceOf(address(this));
    }
    
    /**
     * @dev 获取每份基础资产对应的份额
     */
    function getPricePerFullShare() public view returns (uint256) {
        return balance().mul(1e18).div(totalSupply());
    }
  
  function deposit(uint256 amount) public{
 //将amount数量的fea转入当前池子
        m_token.safeTransferFrom(msg.sender, address(this), amount);
        uint256 pool = balance();
         // 份额 = 0
        uint256 shares = 0;
        // 如果当前合约的总量为0,或者总的份额为0(防止合约上有余额)
        if (pool == 0 || totalSupply() == 0) {
            // 份额 = 数额
            shares = amount;
        } else {
            // 份额 = 数额 * 总量 / 池子数量
            shares = (amount.mul(totalSupply())).div(pool);
        }
        // 为调用者铸造份额
        _mint(msg.sender, shares); 
        return shares;
  }

  function withdraw(uint256 amount) public{
 // 当前合约和控制器合约在基础资产的余额 * 份额 / 总量
        uint256 amount = (balance().mul(shares)).div(totalSupply());
        // 销毁份额
        _burn(msg.sender, shares); 
        //打款给用户
        m_token.safeTransfer(msg.sender, amount);
        return true;
  }

  //动态利息算法：千分之三*当前借贷量/池子总量
  function minFee(uint256 amount) public view returns(uint256){
     uint256 balance = m_token.balanceOf(address(this));
    return m_loan_fee.mul(amount).div(balance).div(MAX_LOAN_FEE);
  }

  function pureLoan(address dealer,uint256 amount,bytes calldata data) public{
    uint256 preBalance = m_token.balanceOf(address(this));
    //把借贷的资产转给贷款人
    m_token.safeTransfer(dealer,amount);
    //调用借贷者自己的借贷函数
    IPureFlash(dealer).OnFlashLoan(address(m_token),amount, data);
    //开始检查是否返款
    uint256 curBalance = m_token.balanceOf(address(this));
    uint256 profit = curBalance.sub(preBalance);
    //利润一定要大于当前最低利息
    require(profit>minFee(amount),"NEED_TRANSFER_BACK");
    //利润的10%发送给社区
    uint256 pfProfit = profit.mul(m_profit_rate).div(10000);
    m_token.safeTransfer(m_profitpool,pfProfit);

  }
}
