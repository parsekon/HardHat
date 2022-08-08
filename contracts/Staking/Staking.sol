// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./IERC20.sol";

contract Staking is Owners {
    IERC20 public stakingToken;
    IERC20 public rewardToken;

    // период начисления
    uint public rewardRate = 10;
    // время последнего обновления rewaerPerTokenStored
    uint public lastUpdateTime;

    // размер вознаграждения за каждый токен, который в данный момент лежит на балансе смарт-контракта
    uint public rewardPerTokenStored;
    // какое вознаграждение уже учтено в rewards для каждого аккаунта
    mapping(address => uint) public userRewardPerTokenPaid;

    // размер вознаграждения для адреса на текущий момент времени
    mapping(address => uint) public rewards;

    // баланс застейканных токенов для адреса
    mapping(address => uint) public _balances;
    // общее кол-во токенов в контракте
    uint public _totalSupply;

    address[] private _accountStaking;

    constructor(address _stakingToken, address _rewardToken) {
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
    }

    // модфикатор проверяет является ли адрес адресом смарт-контракта
    modifier checkToken(address _token) {
        require(_token.code.length > 0, "This is not token");
        _;
    }

    ////////////////////////////////////////////////////////////////////
    modifier updateReward(address _account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;
        rewards[_account] = earned(_account);
        userRewardPerTokenPaid[_account] = rewardPerTokenStored;
        _;
    }

    ////////////////////////////////////////////////////////////////////////////
    // вознаграждение за каждый токен в зависимости от времени и оборота
    function rewardPerToken() public view returns (uint) {
        if (_totalSupply == 0) {
            return 0;
        }

        return rewardPerTokenStored + (
            rewardRate * (block.timestamp - lastUpdateTime)) / _totalSupply;
    }

    function earned(address _account) public view returns (uint) {
        return(_balances[_account] * (rewardPerToken() - userRewardPerTokenPaid[_account])) + rewards[_account];
    }

    // отправляем токены на контракт
    function stake(uint _amount) external updateReward(msg.sender) {
        _totalSupply += _amount;
        _balances[msg.sender] += _amount;
        stakingToken.transferFrom(msg.sender, address(this), _amount);
        _accountStaking.push(msg.sender);
    }

    // выводим токены с контракта
    function withdraw(uint _amount) external updateReward(msg.sender) {
        require(_amount <= _balances[msg.sender], "Not token");
        _totalSupply -= _amount;
        _balances[msg.sender] -= _amount;
        stakingToken.transfer(msg.sender, _amount);
        if(_totalSupply == 0){
            uint reward = rewards[msg.sender];
            rewards[msg.sender] = 0;
            rewardToken.transfer(msg.sender, reward);
        } 
    }

    // забираем вознаграждени
    function getReward() external updateReward(msg.sender) {
        uint reward = rewards[msg.sender];
        rewards[msg.sender] = 0;
        rewardToken.transfer(msg.sender, reward);
    }

    // изменение токенов 
    function setRewardRate(uint _rate) external  onlyOwners {
        rewardRate = _rate;
    }

    function balanceRewardToken() public view returns (uint) {
        return rewardToken.balanceOf(address(this));
    }


    function refundRewardToken(address _account)
        internal
        updateReward(msg.sender)
    {
        require(rewards[_account] > 0, "You dont have reward!");
        uint _reward = rewards[_account];
        rewards[_account] = 0;
        rewardToken.transfer(_account, _reward);
    }

    function refundStakingToken(address _account)
        internal
        updateReward(msg.sender)
    {
        require(_balances[_account] > 0, "You dont have reward!");
        uint _amount = _balances[_account];
        _balances[_account] = 0;
        _totalSupply -= _amount;
        stakingToken.transfer(_account, _amount);
    }

    function withdrawStakingTokenAllAccount() internal {
        for (uint i = 0; i < _accountStaking.length; i++) {
            refundStakingToken(_accountStaking[i]);
        }
    }

    function withdrawRewardTokenAllAccount() internal {
        for (uint i = 0; i < _accountStaking.length; i++) {
            refundRewardToken(_accountStaking[i]);
        }
    }

    // устанавливает и изменяет адрес нового токена для стейкинга
    function setStakingToken(address _stakingToken)
        public
        checkToken(_stakingToken)
        onlyOwners
    {
        if (_totalSupply == 0) {
            stakingToken = IERC20(_stakingToken);
        }
        withdrawStakingTokenAllAccount();
        stakingToken = IERC20(_stakingToken);
    }

    // изменяем и устанавливает адрес нового токена для вознаграждений
    // выводим оставшиеся токены неиспользованные в вознаграждениях
    function setRewardToken(address _rewardToken)
        public
        checkToken(_rewardToken)
        onlyOwners
    {
        if (balanceRewardToken() == 0) {
            rewardToken = IERC20(_rewardToken);
        }
        withdrawRewardTokenAllAccount();
        uint _balanceRewardToken = balanceRewardToken();
        rewardToken.transfer(msg.sender, _balanceRewardToken);
        rewardToken = IERC20(_rewardToken);
    }
}
