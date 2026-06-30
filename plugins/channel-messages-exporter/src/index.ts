import { logger } from "@vendetta";

import { getLazyActionSheet } from "./metro/stores";
import { patchChannelMenus } from "./patches/channelMenu";
import { patchMessageSheet } from "./patches/messageSheet";
import { patchSimpleActionSheets } from "./patches/simpleActionSheet";
import { Settings } from "./Settings";

const patches: Array<() => void> = [];

export const onLoad = () => {
    const lazy = getLazyActionSheet();
    logger.log(
        `[ChannelExporter] Plugin loaded (LazyActionSheet: ${lazy?.openLazy ? "ok" : "missing"})`,
    );
    patches.push(patchChannelMenus());
    patches.push(patchMessageSheet());
    patches.push(patchSimpleActionSheets());
};

export const onUnload = () => {
    logger.log("[ChannelExporter] Plugin unloaded");
    for (const unpatch of patches.splice(0)) {
        unpatch();
    }
};

export { Settings };
