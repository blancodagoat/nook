import { logger } from "@vendetta";
import { clipboard, ReactNative } from "@vendetta/metro/common";
import { showToast } from "@vendetta/ui/toasts";

const MAX_SHARE_BYTES = 5 * 1024 * 1024;

export async function shareExportContent(
    content: string,
    filename: string,
): Promise<"share" | "clipboard"> {
    if (content.length > MAX_SHARE_BYTES) {
        throw new Error(
            `Export is too large (${Math.round(content.length / 1024)} KB). Lower max messages and try again.`,
        );
    }

    if (ReactNative?.Share?.share) {
        await ReactNative.Share.share({
            title: filename,
            message: content,
        });
        logger.log(`[ChannelExporter] Shared ${filename}`);
        return "share";
    }

    if (clipboard?.setString) {
        clipboard.setString(content);
        logger.log(`[ChannelExporter] Copied ${filename} to clipboard`);
        return "clipboard";
    }

    throw new Error("Neither Share nor clipboard is available on this build");
}

export async function shareExportWithToast(content: string, filename: string): Promise<void> {
    const method = await shareExportContent(content, filename);
    showToast(method === "share" ? `Shared ${filename}` : `Copied ${filename} to clipboard`);
}
