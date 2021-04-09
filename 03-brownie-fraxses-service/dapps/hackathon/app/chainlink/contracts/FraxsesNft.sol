pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract FraxsesNft is ERC721{
  constructor() public ERC721("FraxsesNft", "FRX") {}
}
