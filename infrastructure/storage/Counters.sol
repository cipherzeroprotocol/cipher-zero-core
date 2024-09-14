// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Provides counters that can be incremented or decremented.
 * This can be used for tracking ids, minting, or other use cases.
 */
library Counters {
    struct Counter {
        uint256 _value;
    }

    /**
     * @dev Returns the current value of the counter.
     */
    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    /**
     * @dev Increments the counter by one.
     */
    function increment(Counter storage counter) internal {
        counter._value += 1;
    }

    /**
     * @dev Decrements the counter by one.
     */
    function decrement(Counter storage counter) internal {
        require(counter._value > 0, "Counter: decrement overflow");
        counter._value -= 1;
    }

    /**
     * @dev Resets the counter to zero.
     */
    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}
