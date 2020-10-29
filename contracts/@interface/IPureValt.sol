
pragma solidity ^0.7.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IPureValt {
    function deposit(uint256 amount) external returns(bool);
    function withdraw(uint256 amount) external returns(bool);
    function setPool(address valt,address profitpool)  external returns(bool);
    function setProfitRate(address valt,uint256 profitrate)  external returns(bool);
    function setLoanFee(address valt,uint256 loanfee)  external returns(bool);
}