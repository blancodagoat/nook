import type { ExportPayload } from "../types";

export function serializeJson(payload: ExportPayload): string {
    return JSON.stringify(payload, null, 2);
}
