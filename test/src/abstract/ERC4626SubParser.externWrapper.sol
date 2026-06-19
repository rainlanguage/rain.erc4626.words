// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {ERC4626Words} from "src/concrete/ERC4626Words.sol";

/// @dev Exposes the internal-virtual extern() as an external function so tests
/// can assert it returns address(this) for the deployed ERC4626Words instance.
contract ERC4626SubParserExternWrapper is ERC4626Words {
    function externPublic() external view returns (address) {
        return extern();
    }
}
