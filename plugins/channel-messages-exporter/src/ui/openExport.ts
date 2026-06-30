import { getLazyActionSheet } from "../metro/stores";
import type { ExportOptions, RawChannel } from "../export/types";
import { showToast } from "@vendetta/ui/toasts";
import ExportSheet from "./ExportSheet";

export function openExportSheet(
    channel: RawChannel | null,
    overrides?: Partial<ExportOptions>,
): void {
    if (!channel?.id) {
        showToast("No channel available to export");
        return;
    }

    const lazyActionSheet = getLazyActionSheet();
    if (!lazyActionSheet?.openLazy) {
        showToast("Could not open export sheet");
        return;
    }

    lazyActionSheet.hideActionSheet?.();
    lazyActionSheet.openLazy(
        () => Promise.resolve({ default: ExportSheet }),
        "ChannelExportSheet",
        { channel, overrides },
    );
}
