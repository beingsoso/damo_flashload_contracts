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

   mapping(address=>address) m_token_valts;


  //通用存款方法，存入的时候如果没有对应的保险柜，则自动创建
  function deposit(address token,uint256 amount) public{
      address valt = m_token_valts[token];
      if(valt == address(0){
        valt = new PureFlashValt();
        m_token_valts[token]  = address(valt);
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
