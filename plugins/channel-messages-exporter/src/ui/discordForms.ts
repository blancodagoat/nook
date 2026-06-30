import { findByProps } from "@vendetta/metro";
import { React } from "@vendetta/metro/common";

export type DiscordFormComponents = {
    FormSection: React.ElementType;
    FormRow: React.ElementType;
    FormText: React.ElementType;
    FormDivider?: React.ElementType;
};

function isElementType(value: unknown): value is React.ElementType {
    if (typeof value === "string") return true;
    if (typeof value === "function") return true;
    if (value && typeof value === "object") {
        const record = value as { $$typeof?: unknown; render?: unknown };
        return Boolean(record.$$typeof || typeof record.render === "function");
    }
    return false;
}

function pickFormComponent(...candidates: unknown[]): React.ElementType | null {
    for (const candidate of candidates) {
        if (isElementType(candidate)) return candidate;
    }
    return null;
}

export function getDiscordForms(): DiscordFormComponents | null {
    const legacy = findByProps("FormSection", "FormRow", "FormText") as Record<string, unknown> | null;
    const forms = findByProps("Form", "FormSection") as Record<string, unknown> | null;
    const table = findByProps("TableRow", "TableRowGroup") as Record<string, unknown> | null;

    const FormSection = pickFormComponent(
        legacy?.FormSection,
        forms?.FormSection,
        table?.TableRowGroup,
    );
    const FormRow = pickFormComponent(legacy?.FormRow, forms?.FormRow, table?.TableRow);
    const FormText = pickFormComponent(legacy?.FormText, forms?.FormText);
    const FormDivider = pickFormComponent(legacy?.FormDivider, forms?.FormDivider);

    if (!FormSection || !FormRow || !FormText) return null;

    return { FormSection, FormRow, FormText, FormDivider: FormDivider ?? undefined };
}
