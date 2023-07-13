// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Seed is ERC20, ERC20Permit, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    uint256 private constant WATER_INTERVAL = 1 days;
    uint256 private constant GROWTH_DURATION = 2 days;
    uint256 private constant TREE_GENERATION_DURATION = 15 days;

    mapping(uint256 => uint256) private _lastWateredTime;
    mapping(uint256 => bool) private _isSapling;
    mapping(uint256 => bool) private _isTree;

    ERC721 private _treeContract;

    event SeedPlanted(uint256 indexed tokenId, address indexed planter);
    event SaplingGrown(uint256 indexed tokenId);
    event TreeGenerated(uint256 indexed tokenId);

    constructor(ERC721 treeContract) ERC20("seed", "SEED") ERC20Permit("seed") {
        _treeContract = treeContract;
        _mint(msg.sender, 1 * 10 ** decimals());
    }

    function plantTheSeed() external {
        require(balanceOf(msg.sender) >= 1, "Insufficient seeds");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _burn(msg.sender, 1);
        _lastWateredTime[tokenId] = block.timestamp;
        _isSapling[tokenId] = false;
        emit SeedPlanted(tokenId, msg.sender);
    }

    function addWater(uint256 tokenId) external {
        require(_treeContract.ownerOf(tokenId) == msg.sender, "Not the owner");
        require(!_isTree[tokenId], "Already a tree");

        if (!_isSapling[tokenId] && block.timestamp >= _lastWateredTime[tokenId] + GROWTH_DURATION) {
            _isSapling[tokenId] = true;
            emit SaplingGrown(tokenId);
        }

        require(_isSapling[tokenId], "Not a sapling");
        require(block.timestamp >= _lastWateredTime[tokenId] + WATER_INTERVAL, "Too soon");

        _lastWateredTime[tokenId] = block.timestamp;

        if (block.timestamp >= _lastWateredTime[tokenId] + TREE_GENERATION_DURATION) {
            _isTree[tokenId] = true;
            emit TreeGenerated(tokenId);
        }
    }

    function isSapling(uint256 tokenId) external view returns (bool) {
        return _isSapling[tokenId];
    }

    function isTree(uint256 tokenId) external view returns (bool) {
        return _isTree[tokenId];
    }

    function getLastWateredTime(uint256 tokenId) external view returns (uint256) {
        return _lastWateredTime[tokenId];
    }

    function getCurrentTime() external view returns (uint256) {
        return block.timestamp;
    }
}
