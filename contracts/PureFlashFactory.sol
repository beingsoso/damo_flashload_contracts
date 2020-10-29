// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "./@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "./@openzeppelin/contracts/math/SafeMath.sol";
import "./@interface/IPureFlash.sol";
import "./@interface/IPureValt.sol";
import "./@libs/SafeOwnable.sol";



contract PureFlashValt is SafeOwnable{
 
   address[] public m_valts;
   mapping(address=>address) public m_token_valts;
  //保险柜默认参数
  address m_token;
  address m_profit_pool;
  uint256 m_profit_rate;  //基准值：10000
  uint256 m_loan_fee;     //基准值： MAX_LOAN_FEE = 100*10000;
  constructor(address token,address profitpool){
     m_token = token;
     m_profit_pool = profitpool;
     m_profit_rate = 1000; //10%
     m_loan_fee = 100*30;  //千分之3
  }

  //设置创建保险柜的默认参数
  function defaultFee(address profitpool,uint256 profitrate,uint256 loanfee) onlyOwner public{
        m_profit_pool = profitpool;
        m_profit_rate = profitrate;
        m_loan_fee = loanfee;
  }


  function setPool(address valt,address profitpool) onlyOwner public returns(bool){
    address valt = m_token_valts[token];
    require(valt != address(0),"NO_TOKEN_VALT");
    return IPureValt(valt).setPool(profitpool);
  }
  
  function setProfitRate(address valt,uint256 profitrate) onlyOwner public returns(bool){
    address valt = m_token_valts[token];
    require(valt != address(0),"NO_TOKEN_VALT");
    return IPureValt(valt).setProfitRate(profitrate);
  }

  function setLoanFee(address valt,uint256 loanfee) onlyOwner public returns(bool){
    address valt = m_token_valts[token];
    require(valt != address(0),"NO_TOKEN_VALT");
    return IPureValt(valt).setLoanFee(loanfee);
  }


  function valtCount() public view returns(uint256){
    return m_valts.length;
  }
  //通用存款方法，存入的时候如果没有对应的保险柜，则自动创建
  function deposit(address token,uint256 amount) public{
      address valt = m_token_valts[token];
      if(valt == address(0)){
        //constructor(address factory,address token,address profitpool,uint256 profitrate,uint256 loadfee)
        valt = new PureFlashValt(address(this),token,m_profit_pool,m_profit_rate,m_loan_fee);
        address addr =  address(valt);
        m_token_valts[token]  = addr;
        m_valts.push(addr);
      }else{
        IPureValt(valt).deposit(amount);
      }
  }

  
  function withdraw(address token,uint256 amount) public{
    address valt = m_token_valts[token];
    require(valt != address(0),"NO_TOKEN_VALT");
    IPureValt(valt).deposit(amount);
  }

}