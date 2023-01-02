// SPDX-License-Identifier: GPL-3.0


   
   //@custom:dev-run-script contracts/Registration.sol

pragma solidity 0.8.7;

contract SimpleStorage {
    string _ownerdetails;
    uint256 public number;

    function setNumber(uint256 _number) public {
      number= _number;
    }

    event ValueChanged(address indexed author, string oldValue, string newValue);

    constructor(string memory value) {
        emit ValueChanged(msg.sender, _ownerdetails, value);
        _ownerdetails= value;
        number = 3;
    }

    function getValue() view public returns (string memory) {
        return _ownerdetails;
    }

    function setValue(string memory value) public {
        emit ValueChanged(msg.sender, _ownerdetails, value);
        _ownerdetails = _ownerdetails;
    }
}
