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
  
  function deposit(uint256 amount) public{

  }

  function withdraw(uint256 amount) public{

  }

  //利息费用算法：千分之三*当前借贷量/池子总量
  function minFee(uint256 amount) public view returns(uint256){
     uint256 balance = m_token.balanceOf(address(this));
    return m_loan_fee.mul(amount).div(balance).div(MAX_LOAN_FEE);
  }

  function pureLoan(address dealer,uint256 amount,bytes calldata data) public{
    //address dealer = msg.sender;
    uint256 preBalance = m_token.balanceOf(address(this));
    m_token.safeTransfer(dealer,amount);
    //调用借贷者自己的借贷函数
    IPureFlash(dealer).OnFlashLoan(address(m_token),amount, data);
    uint256 curBalance = m_token.balanceOf(address(this));
    uint256 profit = curBalance.sub(preBalance);
    //利润一定要大于当前最低利息
    require(profit>minFee(amount),"NEED_TRANSFER_BACK");
    //利润的10%发送给社区
    uint256 pfProfit = profit.mul(m_profit_rate).div(10000);
    m_token.safeTransfer(m_profitpool,pfProfit);

  }
}
