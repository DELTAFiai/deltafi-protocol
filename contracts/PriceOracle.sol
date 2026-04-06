// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IRedstone {
    function latestAnswer() external view returns (int256);

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

contract PriceOracle is Ownable {
    event FeedSet(uint64 indexed token, address indexed feed);

    mapping(uint64 => address) public priceFeeds;

    constructor() Ownable(msg.sender) {}

    function getTokenPrice(uint64 token) external view returns (uint256 price) {
        address feed = priceFeeds[token];
        // require(feed != address(0), "Feed not set");
        if (feed == address(0)) {
            return 10 ** 8;
        }

        int256 answer = IRedstone(feed).latestAnswer();
        require(answer > 0, "Invalid price");
        return uint256(answer);
    }

    function setPriceFeed(uint64 token, address feed) external onlyOwner {
        priceFeeds[token] = feed;
        emit FeedSet(token, feed);
    }
}
