pragma solidity ^0.5.0;

import "../lib/StringUtils.sol";
import "../DOSOnChainSDK.sol";

// An example get latest ETH-USD price from Coinbase
contract CoinbaseEthUsd is DOSOnChainSDK {
    using StringUtils for *; //using dos network string lib

    // Struct to hold parsed floating string "123.45"
    // define price data struct
    struct ethusd {
        uint integral; // integer part
        uint fractional; //decimal part
    }
    uint queryId; //id of callback result
    string public price_str;
    ethusd public prices;

    event GetPrice(uint integral, uint fractional); //evm event

    constructor() public {
        // @dev: setup and then transfer DOS tokens into deployed contract
        // as oracle fees.
        // Unused fees can be reclaimed by calling DOSRefund() in the SDK.
        super.DOSSetup(); 
    }

    function check() public {
        queryId = DOSQuery(30, "https://api.coinbase.com/v2/prices/ETH-USD/spot", "$.data.amount");
    }

    function __callback__(uint id, bytes calldata result) external auth {
        require(queryId == id, "Unmatched response"); //if queryId wrong then end func flow

        price_str = string(result);
        prices.integral = price_str.subStr(1).str2Uint(); // get integer part of price data
        uint delimit_idx = price_str.indexOf('.'); //get decimal part of price data
        if (delimit_idx != result.length) { // if have pointer of price data then covert decimal part
            prices.fractional = price_str.subStr(delimit_idx + 1).str2Uint();
        }
        emit GetPrice(prices.integral, prices.fractional); //send evm event 
    }
}
