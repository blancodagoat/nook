import { React } from "@vendetta/metro/common";
import { after, before } from "@vendetta/patcher";
import { Forms } from "@vendetta/ui/components";
import { getAssetIDByName } from "@vendetta/ui/assets";
import { findInReactTree } from "@vendetta/utils";

import { getChannel, getLazyActionSheet } from "../metro/stores";
import { openExportSheet } from "../ui/openExport";

const { FormRow, FormIcon } = Forms;

type Unpatch = () => void;

export function patchMessageSheet(): Unpatch {
    const lazyActionSheet = getLazyActionSheet();
    if (!lazyActionSheet?.openLazy) return () => {};

    return before("openLazy", lazyActionSheet, ([component, key, context]) => {
        const message = (context as { message?: { id?: string; channel_id?: string } } | undefined)
            ?.message;
        if (key !== "MessageLongPressActionSheet" || !message?.id || !message.channel_id) return;

        component.then((instance: { default?: unknown }) => {
            const unpatch = after("default", instance, (_args: unknown[], tree: unknown) => {
                React.useEffect(() => () => unpatch(), []);

                const buttons = findInReactTree(
                    tree,
                    (node) => Array.isArray(node) && node[0]?.type?.name === "ButtonRow",
                ) as unknown[] | null;

                if (!buttons) return;
                if (buttons.some((row) => (row as { props?: { label?: string } })?.props?.label === "Export from here")) {
                    return;
                }

                const channel = getChannel(message.channel_id!);
                if (!channel) return;

                buttons.push(
                    <FormRow
                        label="Export from here"
                        leading={
                            <FormIcon
                                style={{ opacity: 1 }}
                                source={getAssetIDByName("ic_select_manually_24px")}
                            />
                        }
                        onPress={() => {
                            lazyActionSheet.hideActionSheet?.();
                            openExportSheet(channel, { fromMessageId: message.id });
                        }}
                    />,
                );
            });
        });
    });
}
