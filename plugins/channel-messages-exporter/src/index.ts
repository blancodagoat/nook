import { logger } from "@vendetta";

import { Settings } from "./Settings";
import { runDiscovery } from "./spike/discovery";

export const onLoad = () => {
    logger.log("[ChannelExporter] Plugin loaded — running Phase 0 discovery");
    try {
        runDiscovery();
    } catch (error) {
        logger.error(
            `[ChannelExporter] Initial discovery failed: ${
                error instanceof Error ? error.message : String(error)
            }`,
        );
    }
};

export const onUnload = () => {
    logger.log("[ChannelExporter] Plugin unloaded");
};

export { Settings };
