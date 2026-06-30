import { patchChannelMenus } from "./channelMenu";
import { patchMessageSheet } from "./messageSheet";
import { patchSimpleActionSheets } from "./simpleActionSheet";

const unpatches: Array<() => void> = [];

export function areMenuPatchesActive(): boolean {
    return unpatches.length > 0;
}

export function enableMenuPatches(): void {
    if (unpatches.length > 0) return;
    unpatches.push(patchChannelMenus());
    unpatches.push(patchMessageSheet());
    unpatches.push(patchSimpleActionSheets());
}

export function disableMenuPatches(): void {
    while (unpatches.length > 0) {
        unpatches.pop()?.();
    }
}
