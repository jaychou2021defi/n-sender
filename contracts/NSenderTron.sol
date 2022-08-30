// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TransferHelper.sol";
import "./Address.sol";
import "./SafeMath.sol";

contract NSender{

    address public owner;

    uint256 public fees;

    uint256 public ethFee;

    address public fastPay;


    event SendToken(address indexed token, address payer, uint256 orderAmount, uint256 fee);

    event ClaimFee(address claimer, uint256 amount);


    receive() payable external {}

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    constructor(){
        ethFee = 10000000000000000000;
        owner = msg.sender;
    }


    function sendToken(address _token, address[] memory _payees, uint256[] memory _amounts) payable external {

        if(msg.sender != fastPay) {
            require(msg.value >= ethFee);
        }

        uint256 orderAmount = calculatingOrderAmount(_amounts);

        for(uint256 index=0; index < _payees.length; index++) {
            TransferHelper.safeTransferFrom(_token, msg.sender, _payees[index], _amounts[index]);
        }

        if(msg.sender != fastPay) {
            calculatingFee();
            emit SendToken(_token, msg.sender, orderAmount, ethFee);
        } else {
            emit SendToken(_token, msg.sender, orderAmount, 0);
        }

    }

    function sendEth(address[] memory _payees, uint256[] memory _amounts) payable external{

        uint256 orderAmount = calculatingOrderAmount(_amounts);

        uint256 totalAmt = SafeMath.add(orderAmount, ethFee);

        require(totalAmt <= msg.value);

        for(uint256 index=0; index < _payees.length; index++) {
            TransferHelper.safeTransferETH(_payees[index], _amounts[index]);
        }

        calculatingFee();

        emit SendToken(address(0), msg.sender, orderAmount, ethFee);

    }

    function calculatingFee() private {
        if (ethFee > 0) {
            fees = SafeMath.add(fees, ethFee);
        }
    }

    function calculatingOrderAmount(uint256[] memory _amounts) private pure returns(uint256) {
        uint256 totalAmt = 0;
        for(uint256 index=0; index < _amounts.length; index++) {
            totalAmt = SafeMath.add(totalAmt, _amounts[index]);
        }
        return totalAmt;
    }

    function changeEthFee(uint256 _newEthFee) external onlyOwner{
        ethFee = _newEthFee;
    }

    function claimFee(uint256 _amount) external onlyOwner {

        require(_amount > 0);

        require(address(this).balance >= _amount);

        TransferHelper.safeTransferETH(msg.sender, _amount);

        emit ClaimFee(msg.sender, _amount);

    }

    function changeFastPay(address _fastPay) external onlyOwner {
        fastPay = _fastPay;
    }

}
