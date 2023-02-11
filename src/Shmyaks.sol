// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

}


contract Shmyaks is ERC1155, Ownable{
  IERC20 public token;
  string public baseURI;
  

  uint256 public constant YOUNG = 0;
  uint256 public constant YOUNG_HUNGRY = 1;
  uint256 public constant YOUNG_SAD = 2;
  uint256 public constant YOUNG_FAT = 3;
  uint256 public constant ADULT = 4;
  uint256 public constant ADULT_HUNGRY = 5;
  uint256 public constant ADULT_SAD = 6;
  uint256 public constant ADULT_FAT = 7;
  uint256 public constant OLD = 8;
  uint256 public constant OLD_HUNGRY = 9;
  uint256 public constant OLD_SAD = 10;
  uint256 public constant OLD_FAT = 11;
  uint256 public constant DEAD = 12;

  struct Player {
    address playerAddress; /// @param playerAddress player wallet address
    string petName; /// @param petName pet name; set by player during registration
    uint256 health;
    uint256 hunger;
    uint256 happiness;
  }

    mapping(address => uint256) idInfo;
    mapping(address => uint256) petInfo;
    mapping(address => uint256) timer;
    mapping(address => uint256) genesisTimer;
    Player[] public players; // Array of players

  constructor(address _token, string memory _URI) ERC1155(_URI){
    baseURI = _URI;
    token = IERC20(_token);
  }

  function updateURI(string memory newURI) public onlyOwner {
    baseURI = newURI;
  }

  function mint(address account, uint256 id, uint256 amount, bytes memory data) internal{
    idInfo[msg.sender] = id;
    _mint(account, id, amount, data);
  }


  function burn(address account, uint256 id, uint256 amount) internal{
    _burn(account, id, amount);
  }
   
  function isPlayer() public view returns (bool) {
    if (petInfo[msg.sender] == 0) {
      return false;
    } else {
      return true;
    }
  }
  function createNewPlayer(string memory _petName) public {
    require(msg.sender != address(0));
    require(!isPlayer(), "Player already registered");
    uint256 _id = players.length;
    players.push(Player(msg.sender, _petName, 100, 100, 100));
    petInfo[msg.sender] = _id;
    timer[msg.sender] = block.timestamp;
    genesisTimer[msg.sender] = block.timestamp;
    mint(msg.sender, YOUNG, 1, "");
  }

  function getHealth() external view returns(uint256){
    return players[petInfo[msg.sender]].health;
  }

  function getHunger() external view returns(uint256){
    return players[petInfo[msg.sender]].hunger;
  }

  function getHappiness() external view returns(uint256){
    return players[petInfo[msg.sender]].happiness;
  }

  function getName() external view returns(string memory){
    return players[petInfo[msg.sender]].petName;
  }


  function deletePlayer(address addr) public {
    require(msg.sender == addr, "You can not delete other players accounts");
    require(isPlayer(), "You are not a registered player");
    delete petInfo[msg.sender];
    delete players[petInfo[msg.sender]];
  }

// current stats of pets is updated every 2 seconds due to if (block.timestamp - timer[msg.sender] > 2). To play you need to change it to your choice 
// for example: block.timestamp - timer[msg.sender] > 300 means that stats will be updated every 5 mins. Also you need to change all lines with currentCycle variable
  function updateCycle() external {
    
    if (block.timestamp - timer[msg.sender] > 2) {
      uint256 currentId = idInfo[msg.sender];
      uint currentCycle = block.timestamp - timer[msg.sender];
      timer[msg.sender] = block.timestamp;
      if (players[petInfo[msg.sender]].happiness > currentCycle / 2)  {
        players[petInfo[msg.sender]].happiness -= currentCycle / 2;
      } else {
        players[petInfo[msg.sender]].happiness = 0;
      }
      if  (players[petInfo[msg.sender]].hunger > currentCycle / 2)  {
        players[petInfo[msg.sender]].hunger -= currentCycle / 2;
      } else {
        players[petInfo[msg.sender]].hunger = 0;
      }
      if (players[petInfo[msg.sender]].hunger == 0 && players[petInfo[msg.sender]].health > currentCycle / 2) {
        players[petInfo[msg.sender]].health -= currentCycle / 2;
      }
      
      if (players[petInfo[msg.sender]].health < currentCycle / 2 && idInfo[msg.sender] != DEAD) {
        players[petInfo[msg.sender]].health = 0;
        burn(msg.sender, currentId, 1);
        mint(msg.sender, DEAD, 1, "");
      }
      uint256 happiness = players[petInfo[msg.sender]].happiness;
      uint256 hunger = players[petInfo[msg.sender]].hunger;
      if ((block.timestamp - genesisTimer[msg.sender]) < 60) {
        if (happiness < 50 && currentId != YOUNG_SAD) {
          burn(msg.sender, currentId, 1);
          mint(msg.sender, YOUNG_SAD, 1, "");
        }
        else if (hunger > 100 && currentId != YOUNG_FAT) {
          burn(msg.sender, currentId, 1);
          mint(msg.sender, YOUNG_FAT, 1, "");
        }
        else if (hunger < 50 && currentId != YOUNG_HUNGRY) {
          burn(msg.sender, currentId, 1);
          mint(msg.sender, YOUNG_HUNGRY, 1, "");
        }
        else {
          burn(msg.sender, currentId, 1);
          mint(msg.sender, YOUNG, 1, "");
        }
      }
      else if ((block.timestamp - genesisTimer[msg.sender]) < 60 * 2) {
        
        if (happiness < 50 && currentId != ADULT_SAD) {
          burn(msg.sender, currentId, 1);
          mint(msg.sender, ADULT_SAD, 1, "");
        }
        else if (hunger > 100 && currentId != ADULT_FAT) {
          burn(msg.sender, currentId, 1);
          mint(msg.sender, ADULT_FAT, 1, "");
        }
        else if (hunger < 50 && currentId != ADULT_HUNGRY) {
          burn(msg.sender, currentId, 1);
          mint(msg.sender, ADULT_HUNGRY, 1, "");
        }
        else {
          burn(msg.sender, currentId, 1);
          mint(msg.sender, ADULT, 1, "");
        }
      }
      else if (idInfo[msg.sender] != DEAD) {
        
        if (happiness < 50 && currentId != OLD_SAD) {
          burn(msg.sender, currentId, 1);
          mint(msg.sender, OLD_SAD, 1, "");
        }
        else if (hunger > 100 && currentId != OLD_FAT) {
          burn(msg.sender, currentId, 1);
          mint(msg.sender, OLD_FAT, 1, "");
        }
        else if (hunger < 50 && currentId != OLD_HUNGRY) {
          burn(msg.sender, currentId, 1);
          mint(msg.sender, OLD_HUNGRY, 1, "");
        }
        else {
          burn(msg.sender, currentId, 1);
          mint(msg.sender, OLD, 1, "");
        }
      }
    }
  }

  function getCurrentPet() public view returns(string memory){
    return string(abi.encodePacked(baseURI, uintToStr(idInfo[msg.sender]),'.png'));
  }

  function giveCare() payable external {
    require(msg.value >= 700000 gwei, "It needs to be at least 0.0007 ether to heal your pet");
    require(players[petInfo[msg.sender]].health < 90, "Your pet is in good condition< no need to cure");
    require(players[petInfo[msg.sender]].hunger > 80, "You need to feed your pet first");
    require(players[petInfo[msg.sender]].health > 0, "Your pet is dead");
    players[petInfo[msg.sender]].health += msg.value / 10**15 * 10;
  }

  function feed() payable external {
    require(msg.value >= 700000 gwei, "It needs to be at least 0.0007 ether to feed your pet");
    require(players[petInfo[msg.sender]].health > 0, "Your pet is dead");
    players[petInfo[msg.sender]].hunger = players[petInfo[msg.sender]].hunger + 50;
  }
  function makeHappy() payable external {
    require(msg.value >= 700000 gwei, "It needs to be at least 0.0007 ether to feed your pet");
    require(players[petInfo[msg.sender]].health > 0, "Your pet is dead");
    players[petInfo[msg.sender]].happiness = players[petInfo[msg.sender]].happiness + 50;
  }

  function revive() payable external {
    require(players[petInfo[msg.sender]].health == 0);
    players[petInfo[msg.sender]].hunger = 100;
    players[petInfo[msg.sender]].happiness = 100;
    players[petInfo[msg.sender]].health = 100;
    timer[msg.sender] = block.timestamp;
    genesisTimer[msg.sender] = block.timestamp;
    burn(msg.sender, DEAD, 1);
    mint(msg.sender, YOUNG, 1, "");
  }

  function uintToStr(uint256 _i) internal pure returns (string memory _uintAsString) {
    if (_i == 0) {
      return '0';
    }
    uint256 j = _i;
    uint256 len;
    while (j != 0) {
      len++;
      j /= 10;
    }
    bytes memory bstr = new bytes(len);
    uint256 k = len;
    while (_i != 0) {
      k = k - 1;
      uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
      bytes1 b1 = bytes1(temp);
      bstr[k] = b1;
      _i /= 10;
    }
    return string(bstr);
  }
    
}
