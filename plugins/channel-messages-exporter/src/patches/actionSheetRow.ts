import { React } from "@vendetta/metro/common";
import { findByProps } from "@vendetta/metro";

type RowElement = {
    type?: unknown;
    props?: Record<string, unknown>;
    key?: string | number;
};

function isRowElement(value: unknown): value is RowElement {
    return Boolean(value && typeof value === "object" && "type" in value && "props" in value);
}

function isElementType(value: unknown): value is React.ElementType {
    if (typeof value === "string") return true;
    if (typeof value === "function") return true;
    if (value && typeof value === "object") {
        const record = value as { $$typeof?: unknown; render?: unknown };
        return Boolean(record.$$typeof || typeof record.render === "function");
    }
    return false;
}

function getFallbackRowType(): React.ElementType | null {
    const sheet = findByProps("ActionSheetRow") as { ActionSheetRow?: unknown } | null;
    if (isElementType(sheet?.ActionSheetRow)) return sheet.ActionSheetRow;

    const legacy = findByProps("FormRow", "FormSection") as { FormRow?: unknown } | null;
    if (isElementType(legacy?.FormRow)) return legacy.FormRow;

    return null;
}

export function createActionSheetRow(
    rows: unknown[],
    label: string,
    onPress: () => void,
): React.ReactElement | null {
    const template = rows.find(isRowElement) ?? null;
    const rowType = template && isElementType(template.type) ? template.type : getFallbackRowType();
    if (!rowType) return null;

    const templateProps = template?.props ?? {};

    return React.createElement(rowType, {
        ...templateProps,
        key: `channel-exporter-${label}`,
        label,
        onPress,
        leading: undefined,
    });
}
