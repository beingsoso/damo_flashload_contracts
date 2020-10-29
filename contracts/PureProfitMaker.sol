pragma solidity ^0.7.0;
//"SPDX-License-Identifier: UNLICENSED" 

import "./../@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./../@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "./../@openzeppelin/contracts/math/SafeMath.sol"; 
import "./../@Interface/IExchangeProxy.sol";
import "./../@libs/BaseContext.sol"; 

//池子1--社区利润池--用社区的利润，回购市场上流通的Token
//功能：1、社区应得的利润会转入本合约ETH
//     2、社区利润池定期再回购FEA接口
//     3、社区利润池FEA再流通（多签机制）
contract PureProfitMaker is BaseContext{
    //防止算术溢出
    using SafeMath for uint256; 
    using SafeERC20 for IERC20;

    IExchangeProxy public m_exchange_proxy;
     //够着函数
    constructor(address token,address exchange) BaseContext(token) {
       m_exchange_proxy = IExchangeProxy(exchange);
    }

    function changeExchange(address exchange) onlyOwner public returns(bool){
         m_exchange_proxy = IExchangeProxy(exchange);
         return true;
    }

    
     /**社区利润池FEA再流通（多签机制）
     */
     function FTRReFund(uint256 amount) onlyOwner  public returns(bool){
         require(IsStoped()==false,"PROFIT_POOL_STOPED");
         //社区利润回购后的FTR，再次通过任务的方式分配给社区
         address goverance = msg.sender; 
         m_token.safeTransfer(goverance,amount);
     }
     
     //2、社区利润池定期再回购FEA接口
     //exchange 交易所地址，amount，回购的ETH数量
     function BuyFTR(address exchange,address tokenUse,uint256 amountIn,uint256 minOut,uint256 deadline) onlyOwner public returns(uint256){
        address tokenOut = address(m_token);          
        //获取可以换取的量
        uint256 amountOut = m_exchange_proxy.getAmountsOut(exchange,tokenUse,tokenOut,amountIn);
        //根据价格计算需要ETH
        require(amountOut >= minOut,"BELOW_MIN_OUT");  
        //对proxy进行额度授权
        IERC20(tokenUse).safeApprove(address(m_exchange_proxy),0);
        IERC20(tokenUse).safeApprove(address(m_exchange_proxy),amountIn);
        //通过交易所兑换
        //swapToken(address exAddr,address to,address tokenIn,address tokenOut,uint256 amountIn,uint256 amountOutMin,uint256 deadline)
        return m_exchange_proxy.swapTokenIn(exchange,address(this),tokenUse,tokenOut,amountIn,minOut,deadline);
     }

     

}