
pragma solidity 0.5.16;


contract ERC20 {
    
    function transfer (address, uint256) external returns (bool);

}

contract Owned {

    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed from, address indexed _to);

    constructor(address _owner) public {
        owner = _owner;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

contract Pausable is Owned {
    event Pause();
    event Unpause();

    bool public paused = false;

    modifier whenNotPaused() {
      require(!paused);
      _;
    }

    modifier whenPaused() {
      require(paused);
      _;
    }

    function pause() onlyOwner whenNotPaused public {
      paused = true;
      emit Pause();
    }

    function unpause() onlyOwner whenPaused public {
      paused = false;
      emit Unpause();
    }
}


/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

}

contract tokenSale is Owned,Pausable {

    using SafeMath for uint256;

    uint256 public teamTokens = 2000000 ether;
    uint256 public advisorTokens = 1000000 ether;
    uint256 public incentiveTokens = 500000 ether;
    uint256 public stockHolders = 460000 ether;
    uint256 public stakingTokens = 4000000;

    uint256 public blockOneTokens = 1000000 ether;
    uint256 public blockTwoTokens = 1500000  ether;  
    uint256 public blockThreeTokens = 2000000 ether;
    uint256 public blockFourTokens = 2500000 ether;

    mapping (address => uint256 )public blockOneVestingTokens;
    mapping (address => uint256) public blockOneVestingReleased;

    mapping (address => uint256 )public blockTwoVestingTokens;
    mapping (address => uint256) public blockTwoVestingReleased;

    mapping (address => uint256 )public blockThreeVestingTokens;
    mapping (address => uint256) public blockThreeVestingReleased;

    mapping (address => uint256 )public blockFourVestingTokens;
    mapping (address => uint256) public blockFourVestingReleased;

    mapping (address => bool) public investor;  

    mapping (address => uint256) teamTokenSent;
    mapping (address => uint256) teamTokenReleased;
    mapping (address  => uint256) teamVestingTime;

    mapping (address => uint256) advisorTokenSent;
    mapping (address => uint256) advisorTokenReleased;
    mapping (address => uint256) advisorVestingTime;

    mapping (address => uint256) incentiveTokenSent;
    mapping (address => uint256) incentiveTokenReleased;
    mapping(address => uint256) incentiveTokenTime;

    mapping (address => uint256) stockHoldersTokenSent;
    mapping (address => uint256) stockHoldersTokenReleased;
    mapping (address => uint256) stockTokenTime; 
    
    uint256 public hardcapInEther = 2000 ether;
    uint256 public etherRaised;
    uint256 public vestingPeriodStartsFrom;

    uint256 public blockOneTokensPerDollar;
    uint256 public blockTwoTokensPerDollar;    
    uint256 public blockThreeTokensPerDollar;
    uint256 public blockFourTokensPerDollar;

    uint256 public ethPrice;
    
    address payable public etherTransferWallet; 
    address public tokenContract; 
    
    
    constructor(address _owner, address _tokenContract) public Owned(_owner) {
        
        tokenContract = tokenContract;

    }

  function setBlocktokensPerDollar (uint256 blockOne, uint256 blockTwo, uint256 blockThree, uint256 blockFour) public onlyOwner returns(bool) 
  {
      blockOneTokensPerDollar = blockOne;
      blockTwoTokensPerDollar = blockTwo;
      blockThreeTokensPerDollar = blockThree;
      blockFourTokensPerDollar = blockFour;
  }


  function sendTeamTokens (address _teamAddress, uint256 value) public onlyOwner returns(bool){

    require(_teamAddress != address(0) && value > 0);
    require(teamTokens >= value);
    teamTokenSent[_teamAddress] = value;
    teamTokens = teamTokens.sub(value);
    teamVestingTime[_teamAddress] = now.add(2592000);
      
  }

  function sendAdvisorTokens (address _advisorAddress, uint256 value) public onlyOwner returns(bool){

    require(_advisorAddress != address(0) && value > 0);
    require(advisorTokens >= value);
    advisorTokenSent[_advisorAddress] = value;
    incentiveTokens = incentiveTokens.sub(value);
    advisorVestingTime[_advisorAddress] = now.add(1209600); 
      
  }


  function sendIncentiveTokens (address _incentiveAddress, uint256 value) public onlyOwner returns(bool){

    require(_incentiveAddress != address(0) && value > 0);
    require(incentiveTokens >= value);
    incentiveTokenSent[_incentiveAddress] = value;
    incentiveTokens = incentiveTokens.sub(value);
    incentiveTokenTime[_incentiveAddress] = now;
      
  }

  function sendStockHoldersTokens (address _stockAddress, uint256 value) public onlyOwner returns(bool){

    require(_stockAddress != address(0) && value > 0);
    require(stockHolders >= value);
    stockHoldersTokenSent[_stockAddress] = value;
    stockHolders = stockHolders.sub(value);
    stockTokenTime[_stockAddress] = now.add(2592000);
      
  }

  function sendStakingTokens (address _stakingAddress, uint256 value) public onlyOwner returns(bool){

    stakingTokens = stakingTokens.sub(value);
    ERC20(tokenContract).transfer(_stakingAddress, value);
    
      
  }

  function buyBlockOneTokens (uint256 value) public payable returns (bool) {
      
    uint256 weiAmount = msg.value;
    require(weiAmount > 0);
    require(!investor[msg.sender]);
    require(ethPrice > 0);
    require(hardcapInEther <= etherRaised.add(weiAmount));    
    uint256 usdCents = weiAmount.mul(ethPrice).div(1 ether);
    uint256 tokens = usdCents.div(100).mul(blockOneTokensPerDollar);
    blockOneVestingTokens[msg.sender] = tokens;
    etherRaised = etherRaised.add(weiAmount);
    investor[msg.sender] = true;
    blockOneVestingTokens[msg.sender] = tokens;
    blockOneTokens = blockOneTokens.sub(tokens);
    
      
  }

  function buyBlockTwoTokens (uint256 value) public payable returns (bool) {
      
    uint256 weiAmount = msg.value;
    require(weiAmount > 0);
    require(!investor[msg.sender]);
    require(ethPrice > 0);
    require(hardcapInEther <= etherRaised.add(weiAmount));
    uint256 usdCents = weiAmount.mul(ethPrice).div(1 ether);
    uint256 tokens = usdCents.div(100).mul(blockTwoTokensPerDollar);
    etherRaised = etherRaised.add(weiAmount);      
    investor[msg.sender] = true;
    blockTwoVestingTokens[msg.sender] = tokens;
    blockTwoTokens = blockTwoTokens.sub(tokens);
  }

  function buyBlockThreeTokens (uint256 value) public payable returns (bool) {
      
    uint256 weiAmount = msg.value;
    require(weiAmount > 0);
    require(!investor[msg.sender]);
    require(ethPrice > 0);
    require(hardcapInEther <= etherRaised.add(weiAmount));
    uint256 usdCents = weiAmount.mul(ethPrice).div(1 ether);
    uint256 tokens = usdCents.div(100).mul(blockThreeTokensPerDollar);
    etherRaised = etherRaised.add(weiAmount);   
    investor[msg.sender] = true;
    blockThreeVestingTokens[msg.sender] = tokens;
    blockThreeTokens = blockThreeTokens.sub(tokens);

  }


  function buyBlockFourTokens (uint256 value) public payable returns (bool) {
      
    uint256 weiAmount = msg.value;
    require(weiAmount > 0);
    require(!investor[msg.sender]);
    require(ethPrice > 0);
    require(hardcapInEther <= etherRaised.add(weiAmount));
    uint256 usdCents = weiAmount.mul(ethPrice).div(1 ether);
    uint256 tokens = usdCents.div(100).mul(blockFourTokensPerDollar);
    etherRaised = etherRaised.add(weiAmount);      
    investor[msg.sender] = true;
    blockFourVestingTokens[msg.sender] = tokens;
    blockFourTokens = blockFourTokens.sub(tokens);
  }

    function getCycleforFirstBlock() public view returns (uint256){
     
     uint256 cycle = now.sub(vestingPeriodStartsFrom);
    
     if(cycle <= 3600)
     {
         return 0;
     }
     else if (cycle > 3600 && cycle < 2592000)
     {     
    
      uint256 secondsToHours = cycle.div(3600);
      return secondsToHours;
         
     }

    else if (cycle >= 2592000)
    {
        return 100;
    }
    
    }


    function claimTokenFirstBlock() public returns (bool) {
  
    require(vestingPeriodStartsFrom > 0); 
    uint256 preSaleCycle = getCycleforFirstBlock();
    uint256 oneHourPercent = blockOneVestingTokens[msg.sender].mul(137).div(1000); //0.137%
    require(blockOneVestingReleased[msg.sender] != blockOneVestingTokens[msg.sender]);
    require(blockOneVestingReleased[msg.sender] != oneHourPercent.mul(preSaleCycle));

    if(blockOneVestingReleased[msg.sender] < oneHourPercent.mul(preSaleCycle))
    {
        uint256 tokenToSend = oneHourPercent.mul(preSaleCycle).sub(blockOneVestingReleased[msg.sender]);
        blockOneVestingReleased[msg.sender] = oneHourPercent.mul(preSaleCycle);
        return ERC20(tokenContract).transfer(msg.sender, tokenToSend);
    }

    }

    function getCycleforSecondBlock() public view returns (uint256){
     
     uint256 cycle = now.sub(vestingPeriodStartsFrom);
    
     if(cycle <= 3600)
     {
         return 0;
     }
     else if (cycle > 3600 && cycle <= 1209600)
     {     
    
      uint256 secondsToHours = cycle.div(3600);
      return secondsToHours;
         
     }

    else if (cycle > 1209600)
    {
        return 337;
    }
    
    }

    function claimTokenSecondBlock() public returns (bool) {
  
    require(vestingPeriodStartsFrom > 0); 
    uint256 preSaleCycle = getCycleforSecondBlock();
    uint256 oneHourPercent = blockTwoVestingTokens[msg.sender].mul(297).div(1000); //0.137%
    require(blockTwoVestingReleased[msg.sender] != blockTwoVestingTokens[msg.sender]);
    require(blockTwoVestingReleased[msg.sender] != oneHourPercent.mul(preSaleCycle));

    if(blockTwoVestingReleased[msg.sender] < oneHourPercent.mul(preSaleCycle))
    {
        uint256 tokenToSend = oneHourPercent.mul(preSaleCycle).sub(blockTwoVestingReleased[msg.sender]);
        blockTwoVestingReleased[msg.sender] = oneHourPercent.mul(preSaleCycle);
        return ERC20(tokenContract).transfer(msg.sender, tokenToSend);
    }

    }


    function getCycleforThirdBlock() public view returns (uint256){
     
     uint256 cycle = now.sub(vestingPeriodStartsFrom);
    
     if(cycle <= 3600)
     {
         return 0;
     }
     else if (cycle > 3600 && cycle <= 604800)
     {     
    
      uint256 secondsToHours = cycle.div(3600);
      return secondsToHours;
         
     }

    else if (cycle > 604800)
    {
        return 169;
    }
    
    }

    function claimTokenThirdBlock() public returns (bool) {
  
    require(vestingPeriodStartsFrom > 0); 
    uint256 preSaleCycle = getCycleforThirdBlock();
    uint256 oneHourPercent = blockThreeVestingTokens[msg.sender].mul(595).div(1000); //0.137%
    require(blockThreeVestingReleased[msg.sender] != blockThreeVestingTokens[msg.sender]);
    require(blockThreeVestingReleased[msg.sender] != oneHourPercent.mul(preSaleCycle));

    if(blockThreeVestingReleased[msg.sender] < oneHourPercent.mul(preSaleCycle))
    {
        uint256 tokenToSend = oneHourPercent.mul(preSaleCycle).sub(blockThreeVestingReleased[msg.sender]);
        blockThreeVestingReleased[msg.sender] = oneHourPercent.mul(preSaleCycle);
        return ERC20(tokenContract).transfer(msg.sender, tokenToSend);
    }

    }

    function claimTokenForthBlock() public returns (bool) {
  
    require(vestingPeriodStartsFrom > 0); 

    require(blockThreeVestingReleased[msg.sender] != blockFourVestingTokens[msg.sender]);

        blockFourVestingReleased[msg.sender] = blockFourVestingTokens[msg.sender];
        return ERC20(tokenContract).transfer(msg.sender, blockFourVestingTokens[msg.sender]);

    }


    function getCycleforTeamTokens() public view returns (uint256){
     
    require(teamVestingTime[msg.sender] > 0 && now > (teamVestingTime[msg.sender]) ); 
     uint256 cycle = now.sub(teamVestingTime[msg.sender]);
    
     if(cycle <= 86400)
     {
         return 0;
     }
     else if (cycle > 86400 && cycle < 94608000)
     {     
    
      uint256 secondsToHours = cycle.div(86400);
      return secondsToHours;
         
     }

    else if (cycle >= 94608000)
    {
        return 109501;
    }
    
    }

    function claimTeamTokens() public returns (bool) {
  
    require(teamVestingTime[msg.sender] > 0 && now > (teamVestingTime[msg.sender]) ); 

    uint256 preSaleCycle = getCycleforTeamTokens();

    uint256 oneDayPercent = teamTokenSent[msg.sender].mul(913242).div(1000000000); //0.000913242 per day after 1month till next 3 years%
    require(teamTokenReleased[msg.sender] != teamTokenSent[msg.sender]);
    require(teamTokenReleased[msg.sender] != oneDayPercent.mul(preSaleCycle));

    if(teamTokenReleased[msg.sender] < oneDayPercent.mul(preSaleCycle))
    {
        uint256 tokenToSend = oneDayPercent.mul(preSaleCycle).sub(teamTokenReleased[msg.sender]);
        teamTokenReleased[msg.sender] = oneDayPercent.mul(preSaleCycle);
        return ERC20(tokenContract).transfer(msg.sender, tokenToSend);
    }

    }

    function getCycleforIncentiveTokens() public view returns (uint256){
     
     uint256 cycle = now.sub(incentiveTokenTime[msg.sender]);
    
     if(cycle <= 1209600)
     {
         return 0;
     }
     else if (cycle > 1209600 && cycle < 60480000)
     {     
    
      uint256 secondsToHours = cycle.div(1209600);
      return secondsToHours;
         
     }

    else if (cycle >= 60480000)
    {
        return 50;
    }
    
    }

    function claimIncentiveTokens() public returns (bool) {
  
    uint256 preSaleCycle = getCycleforIncentiveTokens();

    uint256 oneDayPercent = incentiveTokenSent[msg.sender].mul(2).div(100); //0.000913242 per day after 1month till next 3 years%
    require(incentiveTokenReleased[msg.sender] != incentiveTokenSent[msg.sender]);
    require(incentiveTokenReleased[msg.sender] != oneDayPercent.mul(preSaleCycle));

    if(incentiveTokenReleased[msg.sender] < oneDayPercent.mul(preSaleCycle))
    {
        uint256 tokenToSend = oneDayPercent.mul(preSaleCycle).sub(teamTokenReleased[msg.sender]);
        incentiveTokenReleased[msg.sender] = oneDayPercent.mul(preSaleCycle);
        return ERC20(tokenContract).transfer(msg.sender, tokenToSend);
    }

    }

    function getCycleforAdvisorTokens() public view returns (uint256){
     
    require(advisorVestingTime[msg.sender] > 0 && now > (advisorVestingTime[msg.sender]) ); 
     uint256 cycle = now.sub(advisorVestingTime[msg.sender]);
    
     if(cycle <= 86400)
     {
         return 0;
     }
     else if (cycle > 86400 && cycle < 94608000)
     {     
    
      uint256 secondsToHours = cycle.div(86400);
      return secondsToHours;
         
     }

    else if (cycle >= 94608000)
    {
        return 109501;
    }
    
    }

    function claimAdvisorTokens() public returns (bool) {
  
    require(advisorVestingTime[msg.sender] > 0 && now > (advisorVestingTime[msg.sender]) ); 

    uint256 preSaleCycle = getCycleforAdvisorTokens();

    uint256 oneDayPercent = advisorTokenSent[msg.sender].mul(1369863).div(1000000000); //0.000913242 per day after 1month till next 3 years%
    require(advisorTokenReleased[msg.sender] != advisorTokenSent[msg.sender]);
    require(advisorTokenReleased[msg.sender] != oneDayPercent.mul(preSaleCycle));

    if(advisorTokenReleased[msg.sender] < oneDayPercent.mul(preSaleCycle))
    {
        uint256 tokenToSend = oneDayPercent.mul(preSaleCycle).sub(advisorTokenReleased[msg.sender]);
        advisorTokenReleased[msg.sender] = oneDayPercent.mul(preSaleCycle);
        return ERC20(tokenContract).transfer(msg.sender, tokenToSend);
    }

    }


    function getCycleforStockTokens() public view returns (uint256){
     
    require(stockTokenTime[msg.sender] > 0 && now > (stockTokenTime[msg.sender]) ); 
     uint256 cycle = now.sub(stockTokenTime[msg.sender]);
    
     if(cycle <= 3600)
     {
         return 0;
     }
     else if (cycle > 3600 && cycle < 5184000)
     {     
    
      uint256 secondsToHours = cycle.div(3600);
      return secondsToHours;
         
     }

    else if (cycle >= 5184000)
    {
        return 1440;
    }
    
    }

    function claimStockTokens() public returns (bool) {
  
    require(stockTokenTime[msg.sender] > 0 && now > (stockTokenTime[msg.sender]) ); 

    uint256 preSaleCycle = getCycleforStockTokens();

    uint256 oneDayPercent = stockHoldersTokenSent[msg.sender].mul(69444444).div(1000000000); //0.000913242 per day after 1month till next 3 years%
    require(stockHoldersTokenReleased[msg.sender] != stockHoldersTokenSent[msg.sender]);
    require(stockHoldersTokenReleased[msg.sender] != oneDayPercent.mul(preSaleCycle));

    if(stockHoldersTokenReleased[msg.sender] < oneDayPercent.mul(preSaleCycle))
    {
        uint256 tokenToSend = oneDayPercent.mul(preSaleCycle).sub(stockHoldersTokenReleased[msg.sender]);
        stockHoldersTokenReleased[msg.sender] = oneDayPercent.mul(preSaleCycle);
        return ERC20(tokenContract).transfer(msg.sender, tokenToSend);
    }

    }


    function transferAnyERC20Token(address tokenAddress, uint tokens) public whenNotPaused onlyOwner returns (bool success) {
        require(tokenAddress != address(0));
        return ERC20(tokenAddress).transfer(owner, tokens);
    }}
