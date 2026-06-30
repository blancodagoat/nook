import { logger } from "@vendetta";
import { showToast } from "@vendetta/ui/toasts";

import { PLUGIN_BUILD } from "./buildInfo";
import { disableMenuPatches, enableMenuPatches } from "./patches/registry";
import { getSettings } from "./settings/defaults";
import { Settings } from "./Settings";

export { PLUGIN_BUILD } from "./buildInfo";

export const onLoad = () => {
    logger.log(`[ChannelExporter] Loaded (${PLUGIN_BUILD})`);

    if (getSettings().menuPatches) {
        enableMenuPatches();
        logger.log("[ChannelExporter] Menu patches enabled");
    }

    showToast(`Channel Exporter loaded (${PLUGIN_BUILD})`);
};

export const onUnload = () => {
    logger.log("[ChannelExporter] Plugin unloaded");
    disableMenuPatches();
};

export { Settings };
