
pragma solidity ^0.7.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IPureValt {
    function deposit(uint256 amount) external returns(bool);
    function withdraw(uint256 amount) external returns(bool);
}