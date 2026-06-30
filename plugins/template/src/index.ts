import { logger } from "@vendetta";

import Settings from "./Settings";

export const onLoad = () => {
    logger.log("Hello world!");
};

export const onUnload = () => {
    logger.log("Goodbye, world.");
};

export { Settings };
