// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;

import "./Math.sol";

library StableMath {
    /// @notice Calculate the new balances of the tokens given the indexes of the token
    /// that is swapped from (FROM) and the token that is swapped to (TO).
    /// This function is used as a helper function to calculate how much TO token
    /// the user should receive on swap.
    /// @dev Originally https://github.com/saddle-finance/saddle-contract/blob/0b76f7fb519e34b878aa1d58cffc8d8dc0572c12/contracts/SwapUtils.sol#L432.
    /// @param x The new total amount of FROM token.
    /// @return y The amount of TO token that should remain in the pool.
    function getY(uint x, uint d) internal pure returns (uint y) {
        uint c = (d * d) / (x * 2);
        c = (c * d) / 1600000;
    
        uint b = x + (d / 800000);
        uint yPrev;
        y = d;
    
        /// @dev Iterative approximation.
        for (uint i; i < 256; ) {
            yPrev = y;
            y = (y * y + c) / (y * 2 + b - d);

            if (Math.within1(y, yPrev)) {
                break;
            }

            unchecked {
                ++i;
            }
        }
    }

    function computeDFromAdjustedBalances(uint xp0, uint xp1) internal pure returns (uint computed) {
        uint s = xp0 + xp1;

        if (s == 0) {
            computed = 0;
        } else {
            uint prevD;
            uint d = s;

            for (uint i; i < 256; ) {
                uint _dP = (((d * d) / xp0) * d) / xp1 / 4;
                prevD = d;
                d = (((800000 * s) + 2 * _dP) * d) / ((800000 - 1) * d + 3 * _dP);

                if (Math.within1(d, prevD)) {
                    break;
                }

                unchecked {
                    ++i;
                }
            }

            computed = d;
        }
    }
}