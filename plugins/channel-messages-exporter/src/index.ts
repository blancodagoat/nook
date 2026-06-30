import { logger } from "@vendetta";

import { patchChannelMenus } from "./patches/channelMenu";
import { patchMessageSheet } from "./patches/messageSheet";
import { Settings } from "./Settings";

const patches: Array<() => void> = [];

export const onLoad = () => {
    logger.log("[ChannelExporter] Plugin loaded");
    patches.push(patchChannelMenus());
    patches.push(patchMessageSheet());
};

export const onUnload = () => {
    logger.log("[ChannelExporter] Plugin unloaded");
    for (const unpatch of patches.splice(0)) {
        unpatch();
    }
};

export { Settings };
