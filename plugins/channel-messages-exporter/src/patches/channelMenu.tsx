import { React } from "@vendetta/metro/common";
import { after, before } from "@vendetta/patcher";
import { Forms } from "@vendetta/ui/components";
import { getAssetIDByName } from "@vendetta/ui/assets";
import { findInReactTree } from "@vendetta/utils";

import type { RawChannel } from "../export/types";
import { getChannel, getLazyActionSheet } from "../metro/stores";
import { openExportSheet } from "../ui/openExport";

const { FormRow, FormIcon } = Forms;

type Unpatch = () => void;

const CHANNEL_SHEET_KEYS = [
    "ChannelDetailsActionSheet",
    "ChannelInfoActionSheet",
    "ChannelContextActionSheet",
    "ChannelLongPressActionSheet",
];

export function patchChannelMenus(): Unpatch {
    const lazyActionSheet = getLazyActionSheet();
    if (!lazyActionSheet?.openLazy) return () => {};

    return before("openLazy", lazyActionSheet, ([component, key, context]) => {
        if (typeof key !== "string" || !CHANNEL_SHEET_KEYS.some((entry) => key.includes(entry))) {
            return;
        }

        const channel = extractChannel(context);
        if (!channel) return;

        component.then((instance: { default?: unknown }) => {
            const unpatch = after("default", instance, (_args: unknown[], tree: unknown) => {
                React.useEffect(() => () => unpatch(), []);

                const buttons = findInReactTree(
                    tree,
                    (node) => Array.isArray(node) && node[0]?.type?.name === "ButtonRow",
                ) as unknown[] | null;

                if (!buttons) return;
                if (buttons.some((row) => (row as { props?: { label?: string } })?.props?.label === "Export messages")) {
                    return;
                }

                buttons.push(
                    <FormRow
                        label="Export messages"
                        leading={
                            <FormIcon
                                style={{ opacity: 1 }}
                                source={getAssetIDByName("ic_download_24px")}
                            />
                        }
                        onPress={() => {
                            lazyActionSheet.hideActionSheet?.();
                            openExportSheet(channel);
                        }}
                    />,
                );
            });
        });
    });
}

function extractChannel(context: unknown): RawChannel | null {
    if (!context || typeof context !== "object") return null;
    const record = context as Record<string, unknown>;

    const direct = record.channel as RawChannel | undefined;
    if (direct?.id) return direct;

    const channelId = typeof record.channelId === "string" ? record.channelId : undefined;
    if (channelId) return getChannel(channelId);

    const guildChannel = (record.guild as { channel?: RawChannel } | undefined)?.channel;
    if (guildChannel?.id) return guildChannel;

    return null;
}
