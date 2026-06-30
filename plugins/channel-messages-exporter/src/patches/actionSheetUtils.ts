import { findInReactTree } from "@vendetta/utils";

interface ActionRow {
    props?: { label?: string; onPress?: () => void };
    type?: { name?: string };
}

function isActionRow(item: unknown): boolean {
    if (!item || typeof item !== "object") return false;
    const row = item as ActionRow;
    return typeof row.props?.label === "string" && typeof row.props?.onPress === "function";
}

function rowTypeName(item: unknown): string | undefined {
    if (!item || typeof item !== "object") return undefined;
    const row = item as { type?: { name?: string; displayName?: string } };
    return row.type?.name ?? row.type?.displayName;
}

function isActionRowArray(node: unknown): node is unknown[] {
    return Array.isArray(node) && node.length > 0 && node.every(isActionRow);
}

export function findMutableActionRows(tree: unknown): unknown[] | null {
    const legacy = findInReactTree(
        tree,
        (node) =>
            Array.isArray(node) &&
            node.length > 0 &&
            (rowTypeName(node[0]) === "ButtonRow" ||
                rowTypeName(node[0]) === "ActionSheetRow" ||
                isActionRow(node[0])),
    );
    if (legacy) return legacy as unknown[];

    const labeled = findInReactTree(tree, (node) => isActionRowArray(node));
    if (labeled) return labeled as unknown[];

    return findButtonsByKnownPaths(tree);
}

function findButtonsByKnownPaths(tree: unknown): unknown[] | null {
    const candidates = walkProps(tree);
    for (const candidate of candidates) {
        if (isActionRowArray(candidate)) return candidate;
    }
    return null;
}

function walkProps(node: unknown, depth = 0): unknown[] {
    if (!node || typeof node !== "object" || depth > 12) return [];

    const results: unknown[] = [];
    const record = node as Record<string, unknown>;

    if (Array.isArray(record.children)) {
        for (const child of record.children) {
            if (isActionRowArray(child)) results.push(child);
            results.push(...walkProps(child, depth + 1));
        }
    } else if (record.children) {
        results.push(...walkProps(record.children, depth + 1));
    }

    for (const value of Object.values(record)) {
        if (value && typeof value === "object") {
            results.push(...walkProps(value, depth + 1));
        }
    }

    return results;
}

export function hasActionLabel(rows: unknown[], label: string): boolean {
    return rows.some((row) => (row as ActionRow)?.props?.label === label);
}
