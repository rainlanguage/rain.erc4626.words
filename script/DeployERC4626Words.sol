// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Script} from "forge-std/Script.sol";
import {ERC4626Words} from "../src/concrete/ERC4626Words.sol";
import {IMetaBoardV1_2} from "rain.metadata/interface/unstable/IMetaBoardV1_2.sol";
import {LibDescribedByMeta} from "rain.metadata/lib/LibDescribedByMeta.sol";

/// @dev Deterministic MetaBoard address deployed via Zoltu factory.
/// https://github.com/rainlanguage/rain.metadata
address constant METABOARD_ADDRESS = 0xfb8437AeFBB8031064E274527C5fc08e30Ac6928;

contract DeployERC4626Words is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYMENT_KEY");
        bytes memory subParserDescribedByMeta = vm.readFileBinary("meta/ERC4626Words.rain.meta");
        IMetaBoardV1_2 metaboard = IMetaBoardV1_2(METABOARD_ADDRESS);

        vm.startBroadcast(deployerPrivateKey);
        ERC4626Words subParser = new ERC4626Words();
        LibDescribedByMeta.emitForDescribedAddress(metaboard, subParser, subParserDescribedByMeta);

        vm.stopBroadcast();
    }
}
