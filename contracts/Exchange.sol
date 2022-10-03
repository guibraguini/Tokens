//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface token {
    function approve (address _spender, uint256 _value) external view returns (bool);
    function transferFrom (address _from, address _to, uint256 _value) external view returns (bool);
    function transfer (address _to, uint256 _value) external view returns (bool);
}

contract Exchange {
    address owner;
    mapping(address => bool) tokenCheck;
    mapping(address => uint256) balanceOfToken;
    mapping(address => mapping (address => uint256)) Liquidit;
    address [] tokens;

    constructor (address _firstToken) {
        owner = msg.sender;
        balanceOfToken[_firstToken] = 0;
        tokens.push(_firstToken);
        tokenCheck[_firstToken] = true;
    }

    function addToken (address _newToken) public returns (bool sucess) {
        require(tokenCheck[_newToken] == false, "Token Already Registered");
        tokenCheck[_newToken] = true;
        tokens.push(_newToken);
        return true;
    }

    function addLiquidit (address _token, uint256 _value) public returns (bool sucess) {
        require(msg.sender == owner, "Not the Owner");
        recive(_value, _token);
        Liquidit[msg.sender][_token] += _value;
        return true;
    }

    function removeLiquidit (address _token, uint256 _value) public returns (bool sucess) {
        require(msg.sender == owner, "Not the Owner");
        require(Liquidit[msg.sender][_token] >= _value, "Not Enought Tokens");
        Liquidit[msg.sender][_token] -= _value;
        pay(_value, _token);
        return true;
    }

    function recive (uint256 _total, address _tokenAddress) public returns (bool sucess) {
        require(token(_tokenAddress).approve(msg.sender, _total) == true, "Not approved");
        require(token(_tokenAddress).transferFrom(msg.sender, address(this), _total) == true, "No Tokens Transfered");
        balanceOfToken[_tokenAddress] += _total;
        return true;
    }

    function pay (uint256 _total, address _tokenAddress) internal returns (bool sucess) {
        balanceOfToken[_tokenAddress] -= _total;
        require(token(_tokenAddress).transfer(msg.sender, _total) == true, "No Tokens Transfered");
        return true;
    }

    function change (uint256 _firstToken, uint256 _secondToken, uint256 _value) public returns (bool sucess) {
        address _secondTokenAddress = tokens[_secondToken];
        require(balanceOfToken[_secondTokenAddress] >= _value, "Not Enought Tokens on Exchange");
        address _firstTokenAddress = tokens[_firstToken];
        uint256 _total = (balanceOfToken[_firstTokenAddress] * _value) / balanceOfToken[_secondTokenAddress];
        require(recive(_total, _firstTokenAddress) == true, "Token not Recived");
        pay(_value, _secondTokenAddress);
        return true;
    }


}